//
//  KCPassengerModule.m
//  TencentMapLocusSynchroDemo
//
//  Created by mol on 2021/9/2.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "KCPassengerModule.h"
#import <TencentMapLocusSynchroPassengerSDK/TencentMapLocusSynchroPassengerSDK.h>
#import "Constants.h"
#import "TLSRoutePolyline.h"
#import "MathTool.h"
#import "KCOrderManager.h"
#import "RouteLocation.h"
#import "CarBubbleAnnotationView.h"
#import "SVProgressHUD.h"

@interface KCPassengerModule () <TLSPassengerManagerDelegate>

// 路径规划路线
@property (nonatomic, copy, nullable) NSArray<TLSBRoute *> *routes;

// 当前选中路线index
@property (nonatomic, assign) int curRouteIndex;

// 路线polyline
@property (nonatomic, copy, nullable) NSArray<TLSRoutePolyline *> *routePolylines;

@property (nonatomic, strong) KCMyOrder *order;



// 接力单接驾路线路段
@property (nonatomic, strong, nullable) TLSRoutePolyline *relayRoutePolyline;

// 司机小车Marker
@property (nonatomic, strong, nullable) QPointAnnotation *carMarker;

@property (nonatomic, strong, nullable) QPointAnnotation *carBubbleMarker;

// 地图SDK的路线端点marker
@property (nonatomic, strong, nullable) QPointAnnotation *routeEndPointMarker;

// 地图SDK的接力单路线端点marker
@property (nonatomic, strong, nullable) QPointAnnotation *relayRouteEndPointMarker;

// 小车当前坐标
@property (nonatomic, assign) CLLocationCoordinate2D carCoordinate;
// 小车最近的轨迹
@property (nonatomic, copy, nullable) NSArray<TLSDDriverPosition *> *tlsLocations;

@end

@implementation KCPassengerModule

#pragma mark  - lifecycle

- (instancetype)initWithOrder:(KCMyOrder *)order {
    self = [super init];
    if (self) {
        
        self.order = order;
        _autoVisibleMapRect = YES;
        [self setupPassengerManager];

    }
    
    return self;
}

- (void)dealloc {
    [self removeObserverOnDriverLocation];
}

#pragma mark - setup

// 初始化司乘同显
- (void)setupPassengerManager {
    
    TLSPConfig *pConfig = [[TLSPConfig alloc] init];
    // 乘客id
    pConfig.passengerID = self.order.passengerID;
    pConfig.key = kSynchroKey;
    pConfig.secretKey = kSynchroSecretKey;

    _passengerManager = [[TLSPassengerManager alloc] initWithConfig:pConfig];
    self.passengerManager.delegate = self;
    // 设置订单id
    self.passengerManager.orderID = self.order.orderID;
    self.passengerManager.pOrderID = self.order.orderID;
    // 快车订单
    self.passengerManager.orderType = TLSBOrderTypeNormal;
    // 订单状态为初始状态
    self.passengerManager.orderStatus = self.order.orderStatus;
}

#pragma mark - public

- (void)setOrderStatus:(TLSBOrderStatus)orderStatus {
    _orderStatus = orderStatus;
    
    self.passengerManager.orderStatus = orderStatus;
}

- (void)start {
    [self.passengerManager start];
}

- (void)stop {
    [self.passengerManager stop];
}

// 路径规划并且展示在地图上
- (void)calcRoutesAndShowWithRequest:(TLSPSearchDrivingRequest *)drivingRequest {
        
    __weak typeof(self) weakself = self;
    
    [self.passengerManager queryDrivingWithRequest:drivingRequest completion:^(TLSPSearchDrivingResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error) {
            NSLog(@"乘客算路错误_error=%@", error);
            return;
        }
        
        if (response.status != 0) {
            NSLog(@"乘客算路报错_status=%ld", (long)response.status);
            return;
        }
        
        __strong KCPassengerModule *strongself = weakself;
        if (!strongself) {
            return;
        }

        
        strongself.routes = response.routes;
        strongself.curRouteIndex = 0;
        
        [strongself showRoutes:response.routes selectedIndex:strongself.curRouteIndex];
    }];
}

- (BOOL)isMyOverlay:(id<QOverlay>)overlay {
    BOOL isMy = [self.routePolylines containsObject:overlay];
    if (!isMy) {
        isMy = self.relayRoutePolyline == overlay;
    }
    return isMy;
}

- (void)handleDidTapOverlay:(id<QOverlay>)overlay {
   
    NSInteger index = [self.routePolylines indexOfObject:overlay];
    if (index == NSNotFound) {
        return;
    }
    
    if (self.curRouteIndex == index) {
        return;
    }
    
    TLSRoutePolyline *curPolyline = self.routePolylines[self.curRouteIndex];
    TLSRoutePolyline *selectedPolyline = overlay;
    
    // 至为备选样式
    curPolyline.selected = NO;
    [self.mapView removeOverlay:curPolyline];
    [self.mapView addOverlay:curPolyline];
    
    selectedPolyline.selected = YES;
    [self.mapView removeOverlay:selectedPolyline];
    [self.mapView addOverlay:selectedPolyline];
    
    self.curRouteIndex = (int)index;
}

// 乘客需要调用该方法上报乘客轨迹点
- (void)uploadPosition:(TLSBPosition *)position {
    
    // 判断乘客是否需要上传乘客定位点
    if (self.passengerManager.isRunning && self.passengerManager.uploadPassengerPositionsEnabled) {
        // 上传定位点
        [self.passengerManager uploadPosition:position];
    }
}

- (void)setAutoVisibleMapRect:(BOOL)autoVisibleMapRect {
    _autoVisibleMapRect = autoVisibleMapRect;
    
    [self adjestVisiableMapRectIfNeeded];
}
#pragma mark - private
// 上报选中的送驾路线
- (void)uploadSelctedRoute {
    if (self.routes.count == 0) {
        return;
    }
    
    [self.passengerManager chooseRouteBeforeTrip:self.routes[self.curRouteIndex]];
}


- (void)showRoutes:(NSArray<TLSBRoute *> *)routes selectedIndex:(int)selectedIndex {
    
    if (self.routePolylines.count > 0) {
        [self.mapView removeOverlays:self.routePolylines];
        self.routePolylines = @[];
    }
    
    self.curRouteIndex = selectedIndex;
    
    // 展示多条路线，首条路线高亮
    
    NSMutableArray<TLSRoutePolyline *> *routePolylines = [NSMutableArray arrayWithCapacity:3];
    TLSRoutePolyline *selectedPolyLine;
    
    
    for (int i = 0; i < self.routes.count; i++) {
        
        TLSBRoute *route = self.routes[i];
        TLSRoutePolyline *polyLine = [[TLSRoutePolyline alloc] initWithRoute:route selected:(i == selectedIndex)];
        if (i == selectedIndex) {
            selectedPolyLine = polyLine;
        } else {
            [self.mapView addOverlay:polyLine];
        }
        [routePolylines addObject:polyLine];

    }
    
    // 选中路线最后添加
    [self.mapView addOverlay:selectedPolyLine];

    self.routePolylines = routePolylines;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self adjestVisiableMapRectIfNeeded];
    });
}

// 调整地图视野
- (void)adjestVisiableMapRectIfNeeded {
    
    if (!self.autoVisibleMapRect) {
        return;
    }
    
    NSMutableArray<id<TLSBLocation>> *allPoints = [NSMutableArray array];

    for (TLSRoutePolyline *polyline in self.routePolylines) {
        [allPoints addObjectsFromArray:polyline.route.points];
    }
    
    if (allPoints.count == 0) {
        return;
    }
    
    // 更新视野
    QMapRect mapRect = [MathTool mapRectFitsLocations:allPoints];
    [self.mapView setVisibleMapRect:mapRect
                        edgePadding:UIEdgeInsetsMake(50, 50, 20, 50)
                           animated:YES];
}

// 更新路线
- (void)updateRoute:(TLSBRoute *)route {
    
    if(self.routePolylines.count > 0) {
        [self.mapView removeOverlays:self.routePolylines];
        self.routePolylines = @[];
    }

    if (self.routeEndPointMarker) {
        [self.mapView removeAnnotation:self.routeEndPointMarker];
        self.routeEndPointMarker = nil;
    }
     
    if (!route) {
        return;
    }
    
    // 路线
    TLSRoutePolyline *polyline = [self polylineForRoute:route];
    if (!polyline) {
        NSLog(@"路线绘制失败！");
        return;
    }
    self.routePolylines = @[polyline];
    [self.mapView addOverlays:self.routePolylines];
   
    QPointAnnotation *routeEndPointMarker = [[QPointAnnotation alloc] init];
    routeEndPointMarker.coordinate = route.points.lastObject.coordinate;
    routeEndPointMarker.title = @"end_circle";
    [self.mapView addAnnotation:routeEndPointMarker];
    self.routeEndPointMarker = routeEndPointMarker;

}

// 更新路况
- (void)updateRouteTraffic:(TLSBRoute *)route {
    
    for (TLSRoutePolyline *polyline in self.routePolylines) {
        if ([polyline.route.routeID isEqualToString:route.routeID]) {
            // 找到对应的polyline
            [polyline updateTrafficItems:route];
            
            QTexturePolylineView *routePolylineView = (QTexturePolylineView *)[self.mapView viewForOverlay:polyline];
            routePolylineView.segmentColor = [polyline.segmentColors copy];
            break;
        }
    }
}

// 更新接力单路线
- (void)updateRelayRoute:(TLSBRoute *)relayRoute {
    
    if(self.relayRoutePolyline != nil) {
        [self.mapView removeOverlay:self.relayRoutePolyline];
        self.relayRoutePolyline = nil;
    }
    
    if (self.relayRouteEndPointMarker) {
        [self.mapView removeAnnotation:self.relayRouteEndPointMarker];
        self.relayRouteEndPointMarker = nil;
    }
    
    if (!relayRoute) {
        return;
    }
        
    self.relayRoutePolyline = [self polylineForRoute:relayRoute];
    if (self.relayRoutePolyline) {
        [self.mapView addOverlay:self.relayRoutePolyline];
    }
    
    QPointAnnotation *relayRouteEndPointMarker = [[QPointAnnotation alloc] init];
    relayRouteEndPointMarker.coordinate = relayRoute.points.lastObject.coordinate;
    relayRouteEndPointMarker.title = @"end_circle";
    [self.mapView addAnnotation:relayRouteEndPointMarker];
    self.relayRouteEndPointMarker = relayRouteEndPointMarker;
}



- (TLSRoutePolyline *)polylineForRoute:(TLSBRoute *)route {
    
    if (!route) {
        return nil;
    }
    
    return [[TLSRoutePolyline alloc] initWithRoute:route];
}


- (void)updateLocation:(NSArray <TLSDDriverPosition *> *)locations {
    
    if(locations.count == 0) {
        return;
    }
    
    self.tlsLocations = locations;
    
    if(!self.carMarker) {
        self.carMarker = [[QPointAnnotation alloc] init];
        self.carMarker.coordinate = [self driverCoordinate:locations.firstObject];
        self.carMarker.title = @"driver";
        [self.mapView addAnnotation:self.carMarker];
        [self addObserverOnDriverLocation:self.carMarker];
    }
    
    if (!self.carBubbleMarker) {
        self.carBubbleMarker = [[QPointAnnotation alloc] init];
        self.carBubbleMarker.coordinate = [self driverCoordinate:locations.firstObject];
        self.carBubbleMarker.title = @"bubble";
        [self.mapView addAnnotation:self.carBubbleMarker];
    }
    
    NSMutableArray <RouteLocation *> *locationData = [NSMutableArray new];
    
    RouteLocation *location = [[RouteLocation alloc] init];
    
    QAnnotationViewLayer *layer = (QAnnotationViewLayer *)[self.mapView viewForAnnotation:self.carMarker].layer;
    
    location.coordinate = CLLocationCoordinate2DMake(layer.coordinate.x, layer.coordinate.y);
    
    for(int i = 0; i < locations.count; ++i) {
        RouteLocation *location = [[RouteLocation alloc] init];
        
        location.coordinate = [self driverCoordinate:locations[i]];
        
        [locationData addObject:location];
    }
    
    
    [QMUAnnotationAnimator translateWithAnnotationView:[self.mapView viewForAnnotation:self.carMarker] locations:locationData duration:4.95 rotateEnabled:YES];
    
    [QMUAnnotationAnimator translateWithAnnotationView:[self.mapView viewForAnnotation:self.carBubbleMarker] locations:locationData duration:4.95 rotateEnabled:NO];
    
    if (locations.count == 1 ) {

        self.carCoordinate = locations.firstObject.matchedCoordinate;
        self.carMarker.coordinate = self.carCoordinate;
        self.carBubbleMarker.coordinate = self.carCoordinate;
        
        [self.mapView removeAnnotation:self.carMarker];
        [self.mapView addAnnotation:self.carMarker];
        
        [self.mapView removeAnnotation:self.carBubbleMarker];
        [self.mapView addAnnotation:self.carBubbleMarker];
        
        if (self.self.routePolylines.count == 0) {
            return;
        }
        TLSRoutePolyline *polyline = self.routePolylines.firstObject;
        
        QTexturePolylineView *routePolylineView = (QTexturePolylineView *)[self.mapView viewForOverlay:polyline];
        
        int eraseIndex = [self updatePointIndex:self.tlsLocations fromDriverLocation:self.carCoordinate];
        
        // 根据获得的pointIndex擦除路线
        [routePolylineView eraseFromStartToCurrentPoint:self.carCoordinate searchFrom:eraseIndex toColor:YES];
    }
    
}

- (CLLocationCoordinate2D)driverCoordinate:(TLSDDriverPosition *)location
{
    if(location == nil) {
        return kCLLocationCoordinate2DInvalid;
    }
    
    if(CLLocationCoordinate2DIsValid(location.matchedCoordinate))
    {
        return location.matchedCoordinate;
    }
    else
    {
        return location.location.coordinate;
    }
}

- (void)addObserverOnDriverLocation:(QPointAnnotation *)driverPoint {
    
    [driverPoint addObserver:self
                      forKeyPath:NSStringFromSelector(@selector(coordinate))
                     options:NSKeyValueObservingOptionNew
                     context:NULL];
}

- (void)removeObserverOnDriverLocation {
    
    QPointAnnotation *driverPoint = self.carMarker;
    
    if (driverPoint != nil) {
        [driverPoint removeObserver:self forKeyPath:NSStringFromSelector(@selector(coordinate))];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (object == self.carMarker && [keyPath isEqualToString:NSStringFromSelector(@selector(coordinate))]) {
        self.carCoordinate = self.carMarker.coordinate; //[[change objectForKey:@"new"] MKCoordinateValue];

        
        if (self.self.routePolylines.count == 0) {
            return;
        }
        
        int eraseIndex = [self updatePointIndex:self.tlsLocations fromDriverLocation:self.carCoordinate];

        TLSRoutePolyline *polyline = self.routePolylines.firstObject;
        QTexturePolylineView *routePolylineView = (QTexturePolylineView *)[self.mapView viewForOverlay:polyline];

        // 根据获得的pointIndex擦除路线
        [routePolylineView eraseFromStartToCurrentPoint:self.carMarker.coordinate searchFrom:eraseIndex toColor:YES];
    }
 
}

- (int)updatePointIndex:(NSArray<TLSDDriverPosition *> *)tlsLocations fromDriverLocation:(CLLocationCoordinate2D) driverLocation
{
    double leastDistance = 100.0;
    
    int marker = 0;
    
    for (int i = 0; i < tlsLocations.count; i++) {
        double tempDistance = QMetersBetweenCoordinates(tlsLocations[i].matchedCoordinate, driverLocation);
        
        if ( tempDistance <  leastDistance) {
            leastDistance = tempDistance;
            
            marker = i;
        }
        else
        {
            break;
        }

    }
    
    return [tlsLocations objectAtIndex:marker].matchedIndex;
    
}

// 更新预估剩余时间和里程
- (void)updateRemainingDistance:(int)remainingDistance remaingingTime:(int)remainingTime {
    
    CarBubbleAnnotationView *carBubbleAnnotationView = (CarBubbleAnnotationView *)[self.mapView viewForAnnotation:self.carBubbleMarker];
    [carBubbleAnnotationView setRemainingDistance:remainingDistance remainingTime:remainingTime];
}

# pragma mark - TLSPassengerManagerDelegate

- (void)tlsPassengerManagerDidUploadLocationSuccess:(TLSPassengerManager *)passengerManager {
    
}

- (void)tlsPassengerManagerDidUploadLocationFail:(TLSPassengerManager *)passengerManager error:(NSError *)error {
    
}


- (void)tlsPassengerManager:(TLSPassengerManager *)passengerManager didFailWithError:(NSError *)error {
    
}

- (void)tlsPassengerManager:(TLSPassengerManager *)passengerManager didFetchedData:(TLSPFetchedData *)fetchedData {
  
    BOOL routeDidChange = NO;
    if (![self.curFetchedData.route.routeID isEqualToString:fetchedData.route.routeID]) {
        // 路线id相同
        routeDidChange = YES;
    }
    
    
    TLSBRoute *tmpRoute = fetchedData.route;
    // 更新路线需重新绘制.
    if (routeDidChange) {
        
        // 重新绘制路线.
        [self updateRoute:tmpRoute];
    } else {
        // 相同路线只更新路况
        if(fetchedData.route.trafficItems.count > 0) {
            [self updateRouteTraffic:tmpRoute];
        }
    }
    
    //判断接力单
    // 接力路线发生变化
    BOOL relayRouteDidChange = NO;
    if (![_curFetchedData.relayRoute.routeID isEqualToString:fetchedData.relayRoute.routeID]) {
        relayRouteDidChange = YES;
    }
    
    if (relayRouteDidChange) {
        // 接力路线不相同了，需要更新
        [self updateRelayRoute:fetchedData.relayRoute];
    }
    
    _curFetchedData = fetchedData;
    
    // 更新位置.
    [self updateLocation:fetchedData.positions];

    
    if (self.curFetchedData.route) {
        int remainingDistance = self.curFetchedData.route.remainingDistance;
        int remainingTime = self.curFetchedData.route.remainingTime;
        
        // 如果是接力单，乘客显示的剩余时间和剩余距离要加上接力路段
        if (self.curFetchedData.relayRoute) {
            remainingDistance += self.curFetchedData.relayRoute.remainingDistance;
            remainingTime += self.curFetchedData.relayRoute.remainingTime;
        }

        // 更新预估剩余时间和里程
        [self updateRemainingDistance:remainingDistance remaingingTime:remainingTime];
    }
    
    // 调整视野
    [self adjestVisiableMapRectIfNeeded];
}

- (void)tlsPassengerManagerDidSendRouteRequestSuccess:(TLSPassengerManager *)passengerManager {
    [SVProgressHUD showSuccessWithStatus:@"乘客选路指令发送成功！"];
}

- (void)tlsPassengerManagerDidSendRouteRequestFail:(TLSPassengerManager *)passengerManager error:(NSError *)error {
    NSString *errorDes = [NSString stringWithFormat:@"乘客选路失败error:%@", error];
    [SVProgressHUD showErrorWithStatus:errorDes];
}

@end
