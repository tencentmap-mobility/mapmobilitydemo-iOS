//
//  PassengerSynchroViewController.m
//  TencentMapLocusSynchroDemo
//
//  Created by Yuchen Wang on 2020/3/9.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "KCPassengerSynchroViewController.h"
#import <QMapKit/QMapKit.h>
#import <MapKit/MKGeometry.h>
#import <TencentMapLocusSynchroPassengerSDK/TencentMapLocusSynchroPassengerSDK.h>
#import <TNKNavigationKit/TNKNavigationKit.h>
#import "TrafficPolyline.h"
#import "RouteLocation.h"
#import "Constants.h"
#import "CalloutAnnotationView.h"
#import <TencentLBS/TencentLBS.h>

@interface KCPassengerSynchroViewController ()<QMapViewDelegate,TLSPassengerManagerDelegate,TencentLBSLocationManagerDelegate>

@property (nonatomic, strong) QMapView *mapView;

@property (nonatomic, strong) TLSPassengerManager *passengerManager;

@property (nonatomic, strong) TencentLBSLocationManager *locationManager;

@property (nonatomic, strong) UIBarButtonItem *fetchButtonItem;

@property (nonatomic, strong) UIBarButtonItem *uploadLocationButtonItem;

@property (nonatomic, strong) UILabel *infoLabel;

@property (nonatomic, strong) NSString *currentRouteID;

@property (nonatomic, strong) TrafficPolyline *route;

@property (nonatomic, strong) QPointAnnotation *driverPoint;

@property (nonatomic, strong) QPointAnnotation *bubblePoint;

@property (nonatomic, strong) NSMutableArray<QPointAnnotation *> *wayPointAnnotations;

@property (nonatomic, strong) QTexturePolylineView *trafficOverlayView;

@property (nonatomic, assign) NSTimeInterval lastLocationTimestamp;

@property (nonatomic, assign) CLLocationCoordinate2D currentCoordinate;

@property (nonatomic, strong) NSArray<TLSDDriverPosition *> *tlsLocations;

@property (nonatomic,strong) CalloutAnnotationView *calloutAnnotationView;

@property (nonatomic, strong) NSString *remainingString;

@property (nonatomic, strong) UILabel *label;

@end

@implementation KCPassengerSynchroViewController

UIColor *KCColorWithHex(long hex) {
    float red   = ((float)((hex & 0xFF0000) >> 16)) / 255.0;
    float green = ((float)((hex & 0x00FF00) >> 8))  / 255.0;
    float blue  = ((float)( hex & 0x0000FF))        / 255.0;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:1];
}

// 获取导航SDK默认路况颜色
UIColor *KCRouteTrafficStatusColor(long trafficDataStatus) {
    
    switch (trafficDataStatus)
    {
        case 0:
        {
            return KCColorWithHex(0x05B473);
            break;
        }
        case 1:
        {
            return KCColorWithHex(0xFABB11);
            break;
        }
        case 2:
        {
            return KCColorWithHex(0xE61C3F);
            break;
        }
        case 3:
        {
            return KCColorWithHex(0x6ca4f2);
            break;
        }
        case 4:
        {
            return KCColorWithHex(0x932632);
            break;
        }
        default:
        {
            return KCColorWithHex(0xc2c2c2);
            break;
        }
    }
}

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
        
    [self setupToolbar];
    
    [self setupMap];
    
    [self setupLabel];
    
    [self setupPassengerManager];
    
    [self configLocationManager];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setToolbarHidden:NO animated:animated];
}

- (void)dealloc
{
    [self stopSerialLocation];
    [self.passengerManager stop];
    [self removeObserverOnDriverLocation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark - setters

- (void)setupMap
{
    self.mapView = [[QMapView alloc] initWithFrame:self.view.bounds];
    
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    self.mapView.rotateEnabled = NO;
    self.mapView.overlookingEnabled = NO;
    
    [self.view addSubview:self.mapView];
}

- (void)setupPassengerManager
{
    // 初始化司乘同显
    TLSPConfig *pConfig = [[TLSPConfig alloc] init];
    pConfig.passengerID = kSynchroKCPassengerAccountID;
    pConfig.key = kSynchroKey;
    
    self.passengerManager = [[TLSPassengerManager alloc] initWithConfig:pConfig];
    self.passengerManager.delegate = self;
    self.passengerManager.orderID = kSynchroKCOrderID;
    self.passengerManager.pOrderID = kSynchroKCOrderID;
    self.passengerManager.orderType = TLSBOrderTypeNormal;
    self.passengerManager.orderStatus = TLSBOrderStatusTrip;
}

- (void)setupToolbar
{
    UIBarButtonItem *flexble = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    self.fetchButtonItem    = [[UIBarButtonItem alloc] initWithTitle:@"启动同步" style:UIBarButtonItemStyleDone target:self action:@selector(handleStartFetch:)];
    self.uploadLocationButtonItem     = [[UIBarButtonItem alloc] initWithTitle:@"上报定位" style:UIBarButtonItemStyleDone target:self action:@selector(handleStopFetch:)];
    
    self.toolbarItems = @[flexble, self.fetchButtonItem,
                          flexble, self.uploadLocationButtonItem,
                          flexble];
}

- (void)setupLabel
{
    self.label = [UILabel new];
    self.label.backgroundColor = [UIColor clearColor];
    self.label.numberOfLines = 0;
    self.label.frame = CGRectMake(0, 0, self.view.frame.size.width, 60);
    self.label.textColor = [UIColor blackColor];
    self.label.textAlignment = NSTextAlignmentLeft;
    self.label.text = @"";
}

#pragma mark - location manager
- (void)configLocationManager
{
    self.locationManager = [[TencentLBSLocationManager alloc] init];
 
    [self.locationManager setDelegate:self];
 
    [self.locationManager setApiKey:kMapKey];
 
    [self.locationManager setPausesLocationUpdatesAutomatically:NO];
 
    // 需要后台定位的话，可以设置此属性为YES。
    [self.locationManager setAllowsBackgroundLocationUpdates:YES];
 
    // 如果需要POI信息的话，根据所需要的级别来设定，定位结果将会根据设定的POI级别来返回，如：
    [self.locationManager setRequestLevel:TencentLBSRequestLevelAdminName];
 
    // 申请的定位权限，得和在info.list申请的权限对应才有效
    CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
    if (authorizationStatus == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    [self startSerialLocation];
}
 
// 连续定位
- (void)startSerialLocation {
    //开始定位
    [self.locationManager startUpdatingLocation];
}
 
- (void)stopSerialLocation {
    //停止定位
    [self.locationManager stopUpdatingLocation];
}
 
- (void)tencentLBSLocationManager:(TencentLBSLocationManager *)manager
                 didFailWithError:(NSError *)error {
    CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
    if (authorizationStatus == kCLAuthorizationStatusDenied ||
        authorizationStatus == kCLAuthorizationStatusRestricted) {
 
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                       message:@"定位权限未开启，是否开启？"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"是"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
            if( [[UIApplication sharedApplication]canOpenURL:
                [NSURL URLWithString:UIApplicationOpenSettingsURLString]] ) {
                [[UIApplication sharedApplication] openURL:
                    [NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }
        }]];
 
        [alert addAction:[UIAlertAction actionWithTitle:@"否"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
        }]];
 
        [self presentViewController:alert animated:true completion:nil];
 
    } else {
        // print error
    }
}
 
 
- (void)tencentLBSLocationManager:(TencentLBSLocationManager *)manager
                didUpdateLocation:(TencentLBSLocation *)location {
    //定位结果
    NSLog(@"location:%@", location.location);
    if (self.lastLocationTimestamp == [location.location.timestamp timeIntervalSince1970]) {
        // 时间戳相同，过滤
        return;
    }
    
    self.lastLocationTimestamp = [location.location.timestamp timeIntervalSince1970];

    if (self.passengerManager.isRunning && self.passengerManager.uploadPassengerPositionsEnabled) {
        TLSBPosition *myPosition = [[TLSBPosition alloc] init];
        myPosition.location = location.location;
        myPosition.cityCode = location.code;
        [self.passengerManager uploadPosition:myPosition];
    }
}

# pragma mark - TLSPassengerManagerDelegate

- (void)tlsPassengerManagerDidUploadLocationSuccess:(TLSPassengerManager *)passengerManager
{
    
}

- (void)tlsPassengerManagerDidUploadLocationFail:(TLSPassengerManager *)passengerManager error:(NSError *)error
{
    
}

- (void)tlsPassengerManager:(TLSPassengerManager *)passengerManager didFetchedData:(TLSPFetchedData *)fetchedData
{
    
    // 更新路线需重新绘制.
    if (![self.currentRouteID isEqualToString:fetchedData.route.routeID]) {
        
        // 重新绘制路线.
        [self updateRoute:fetchedData.route];
    }
    // 相同路线更新路况.
    else
    {
        if(fetchedData.route.trafficItems != nil)
        {
            [self updateRouteTraffic:fetchedData.route.trafficItems];
        }
    }
    
    
    // 更新位置.
    [self updateLocation:fetchedData.positions];
    
    [self updateRemainingDistanceAndRemaingingTime:fetchedData.route];
    
    self.calloutAnnotationView = (CalloutAnnotationView *)[self.mapView viewForAnnotation:self.bubblePoint];
    self.calloutAnnotationView.callloutText = self.remainingString;
}

- (void)tlsPassengerManager:(TLSPassengerManager *)passengerManager didFailWithError:(NSError *)error
{
    
}

# pragma mark - QMapViewDelegate

- (QOverlayView *)mapView:(QMapView *)mapView viewForOverlay:(id<QOverlay>)overlay
{
    if ([overlay isKindOfClass:[TrafficPolyline class]])
    {
        TrafficPolyline *trafficPolyline = overlay;
        QTexturePolylineView *polylineRender = [[QTexturePolylineView alloc] initWithPolyline:overlay];
        polylineRender.drawType = QTextureLineDrawType_ColorLine;
        polylineRender.segmentColor = trafficPolyline.arrLine;
        polylineRender.borderColor  = [UIColor colorWithRed:0 green:0.8 blue:0 alpha:0.15];
        polylineRender.lineWidth    = 10;
        polylineRender.borderWidth  = 1;
        //polylineRender.strokeColor  = [UIColor colorWithRed:1 green:0 blue:0 alpha:.248];
        polylineRender.drawSymbol   = YES;
        
        return polylineRender;
    }
    return nil;
}

- (QAnnotationView *)mapView:(QMapView *)mapView viewForAnnotation:(id<QAnnotation>)annotation
{
    if ([annotation isKindOfClass:[QPointAnnotation class]])
    {
        
        if (annotation.title.length == 0) {
            return nil;
        }
        
        QAnnotationView *annotationView = (QAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:annotation.title];
                
        if ([annotation.title isEqualToString:@"driver"]) {
            if (!annotationView) {
                annotationView = [[QAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotation.title];
            }else {
                annotationView.annotation = annotation;
            }
            UIImage *img = [UIImage imageNamed:@"map_icon_driver"];
            annotationView.image = img;
        }
        else if ([annotation.title isEqualToString:@"bubble"]) {
            if (!annotationView) {
                annotationView = [[CalloutAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotation.title];
            }else {
                annotationView.annotation = annotation;
            }
            annotationView.centerOffset = CGPointMake(0, -40);
            annotationView.canShowCallout = NO;
        }
        else if ([annotation.title isEqualToString:@"wayPoint"]) {
            if (!annotationView) {
                annotationView = [[QAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotation.title];
            }else {
                annotationView.annotation = annotation;
            }
            UIImage *image = [UIImage imageNamed:@"route_ic_wayPoint"];
            double height = image.size.height * image.scale / [UIScreen mainScreen].scale / 2.0;
                      
            annotationView.image = image;
            annotationView.centerOffset = CGPointMake(0, -height);
        }
   
        return annotationView;
    }
    
    return nil;
}
# pragma mark - kvo

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    if (object == self.driverPoint && [keyPath isEqualToString:NSStringFromSelector(@selector(coordinate))])
    {
        self.currentCoordinate = self.driverPoint.coordinate; //[[change objectForKey:@"new"] MKCoordinateValue];

        //self.driverPoint = (QPointAnnotation *)object;

        int eraseIndex = [self updatePointIndex:self.tlsLocations fromDriverLocation:self.currentCoordinate];
        
        // 根据获得的pointIndex擦除路线
        [self.trafficOverlayView eraseFromStartToCurrentPoint:self.driverPoint.coordinate searchFrom:eraseIndex toColor:YES];
        
    }
 
}

- (int)updatePointIndex:(NSArray<TLSDDriverPosition *> *)tlsLocations fromDriverLocation:(CLLocationCoordinate2D) driverLocation
{
    double leastDistance = 100.0;
    
    int marker = 0;
    
    for (int i = 0; i < tlsLocations.count; i++)
    {
        double tempDistance =  [TNKMathTool distanceBetweenCoordinate:tlsLocations[i].matchedCoordinate  coordinate:driverLocation];
        
        if ( tempDistance <  leastDistance)
        {
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

- (void)addObserverOnDriverLocation:(QPointAnnotation *)driverPoint
{
    
    [driverPoint addObserver:self
                      forKeyPath:NSStringFromSelector(@selector(coordinate))
                     options:NSKeyValueObservingOptionNew
                     context:NULL];
}

- (void)removeObserverOnDriverLocation
{
    
    QPointAnnotation *driverPoint = self.driverPoint;
    
    if (driverPoint != nil)
    {
        [driverPoint removeObserver:self forKeyPath:NSStringFromSelector(@selector(coordinate))];
    }
}



# pragma mark - Action

- (void)updateLocation:(NSArray <TLSDDriverPosition *> *)locations
{
    if(locations == nil || locations.count == 0)
    {
        return;
    }
    
    self.tlsLocations = locations;
    
    if(self.driverPoint == nil)
    {
        self.driverPoint = [[QPointAnnotation alloc] init];
        self.driverPoint.coordinate = [self driverCoordinate:locations.firstObject];
        self.driverPoint.title = @"driver";
        [self.mapView addAnnotation:self.driverPoint];
        [self addObserverOnDriverLocation:self.driverPoint];
    }
    
    if (self.bubblePoint == nil) {
        self.bubblePoint = [[QPointAnnotation alloc] init];
        self.bubblePoint.coordinate = [self driverCoordinate:locations.firstObject];
        self.bubblePoint.title = @"bubble";
        [self.mapView addAnnotation:self.bubblePoint];
    }
    
    NSMutableArray <RouteLocation *> *locationData = [NSMutableArray new];
    
    RouteLocation *location = [[RouteLocation alloc] init];
    
    QAnnotationViewLayer *layer = (QAnnotationViewLayer *)[self.mapView viewForAnnotation:self.driverPoint].layer;
    
    location.coordinate = CLLocationCoordinate2DMake(layer.coordinate.x, layer.coordinate.y);
    
    for(int i=0;i<locations.count;++i)
    {
        RouteLocation *location = [[RouteLocation alloc] init];
        
        location.coordinate = [self driverCoordinate:locations[i]];
        
        [locationData addObject:location];
    }
    
    
    [QMUAnnotationAnimator translateWithAnnotationView:[self.mapView viewForAnnotation:self.driverPoint] locations:locationData duration:4.95 rotateEnabled:YES];
    
    [QMUAnnotationAnimator translateWithAnnotationView:[self.mapView viewForAnnotation:self.bubblePoint] locations:locationData duration:4.95 rotateEnabled:NO];
    
    // 只有一个定位点，无法监听到坐标变化，无法做路线擦除
    // 所以当只有一个定位点时，这里调用擦除方法
    if (locations.count == 1) {

        int eraseIndex = [self updatePointIndex:self.tlsLocations fromDriverLocation:self.currentCoordinate];
        
        // 根据获得的pointIndex擦除路线
        [self.trafficOverlayView eraseFromStartToCurrentPoint:self.driverPoint.coordinate searchFrom:eraseIndex toColor:YES];
    }
    
}

- (CLLocationCoordinate2D)driverCoordinate:(TLSDDriverPosition *)location
{
    if(location == nil)
    {
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

- (void)updateRoute:(TLSBRoute *)route
{
    if(self.route != nil)
    {
        [self.mapView removeOverlay:self.route];
    }
    
    if (self.wayPointAnnotations != nil) {
        [self.mapView removeAnnotations:self.wayPointAnnotations];
    }
    
    self.currentRouteID = route.routeID;
    
    self.route = [self polylineForRoute:route];
    
    [self.mapView addOverlay:self.route];
    
    // 添加途径点marker
    NSMutableArray<TLSBWayPoint *> *wayPoints = [NSMutableArray arrayWithArray:route.wayPoints];
    
    if (wayPoints.count != 0) {
        
        self.wayPointAnnotations = [NSMutableArray array];
        for (int i = 0; i < wayPoints.count; i++)
        {
            QPointAnnotation * wayPointAnnotation = [[QPointAnnotation alloc] init];
            wayPointAnnotation.coordinate = wayPoints[i].position;
            wayPointAnnotation.title      = @"wayPoint";
            [self.wayPointAnnotations addObject:wayPointAnnotation];
        }
        
        [self.mapView addAnnotations:[self.wayPointAnnotations copy]];
    }
    
    self.trafficOverlayView = (QTexturePolylineView *)[self.mapView viewForOverlay:self.route];
    self.trafficOverlayView.segmentStyle = [self.route.arrLine copy];
    
    // 更新视野
    QMapRect mapRect = [self mapRectFitsPoints:route.points];
    [self.mapView setVisibleMapRect:mapRect edgePadding:UIEdgeInsetsMake(50, 50, 50, 50) animated:NO];
    
}

/** @brief 计算地图适合的正方形点 **/
- (QMapRect)mapRectFitsPoints:(NSArray<id<TLSBLocation>> *)points
{
    NSAssert(points != nil && points.count > 0, @"points array invalid");
    
    QMapPoint firstMapPoint = QMapPointForCoordinate(points[0].coordinate);
    
    CGFloat minX = firstMapPoint.x;
    CGFloat minY = firstMapPoint.y;
    CGFloat maxX = minX;
    CGFloat maxY = minY;
    
    for (int i = 1; i < points.count; i++) {
        
        QMapPoint point = QMapPointForCoordinate(points[i].coordinate);
        
        if (point.x < minX)
        {
            minX = point.x;
        }
        if (point.y < minY)
        {
            minY = point.y;
        }
        if (point.x > maxX)
        {
            maxX = point.x;
        }
        if (point.y > maxY)
        {
            maxY = point.y;
        }
        
    }
    
    CGFloat width  = fabs(maxX - minX);
    CGFloat height = fabs(maxY - minY);
    
    return QMapRectMake(minX, minY, width, height);
    
}

- (TrafficPolyline *)polylineForRoute:(TLSBRoute *)route
{
    CLLocationCoordinate2D polylineCoords[route.points.count];
    
    for(int i=0;i<route.points.count;++i)
    {
        polylineCoords[i].latitude  = route.points[i].coordinate.latitude;
        polylineCoords[i].longitude = route.points[i].coordinate.longitude;
    }

    NSArray *routeTraffic = [self getSegmentColorsWithItems:route.trafficItems];
    
    if (routeTraffic.count == 0) {
        NSMutableArray* routeLineArray = [NSMutableArray array];
        
        QSegmentColor *color = [[QSegmentColor alloc] init];
        
        color.startIndex = 0;
        color.endIndex   = (int)(route.points.count - 1);
        color.color = KCRouteTrafficStatusColor(0);
        
        [routeLineArray addObject:color];
        
        routeTraffic = [routeLineArray copy];
    }
    
    TrafficPolyline *routeOverlay = [[TrafficPolyline alloc] initWithCoordinates:polylineCoords count:route.points.count arrLine:routeTraffic];
    
    return routeOverlay;
}

- (NSArray<QSegmentColor *> *)getSegmentColorsWithItems:(NSArray<TLSBRouteTrafficItem *> *)items
{
    if(items == nil || items.count == 0) return nil;
    
    NSMutableArray *routeStyles = [NSMutableArray new];
    for(int i = 0;i < items.count; ++i)
    {
        TLSBRouteTrafficItem *item = items[i];
        
        QSegmentColor *routeStyle  = [[QSegmentColor alloc] init];
        
        routeStyle.startIndex      = (int)item.from;
        routeStyle.endIndex        = (int)item.to;
        routeStyle.color = KCRouteTrafficStatusColor(item.color);
        
        [routeStyles addObject:routeStyle];
    }
    
    return routeStyles;
}

- (void)updateRouteTraffic:(NSArray<TLSBRouteTrafficItem *> *)data
{
    [self.route.arrLine setArray:[self getSegmentColorsWithItems:data]];
    
    if (self.trafficOverlayView) {
        self.trafficOverlayView.segmentStyle = [self.route.arrLine copy];
    }
}

- (void)updateRemainingDistanceAndRemaingingTime:(TLSBRoute *)route
{
    int remainingDistance;
    int remainingTime;
//    NSString *remainingString;
    
//    if (self.passengerManager.orderStatus == TLSBOrderStatusPickup) {
//
//        if (wayPoint.wayPointType == TLSBWayPointTypeGetIn) {
//            remainingDistance = wayPoint.remainingDistance;
//            remainingTime = wayPoint.remainingTime;
//            self.remainingString = [NSString stringWithFormat:@"剩余时间：%d分，剩余里程：%d米",remainingTime,remainingDistance];
//        }
//
//    }else if (self.passengerManager.orderStatus == TLSBOrderStatusTrip){
//
//        if (wayPoint.wayPointType == TLSBWayPointTypeGetOff) {
//            remainingDistance = wayPoint.remainingDistance;
//            remainingTime = wayPoint.remainingTime;
//            self.remainingString = [NSString stringWithFormat:@"剩余时间：%d分，剩余里程：%d米",remainingTime,remainingDistance];
//        }
//    }else
//    {
//        self.remainingString = [NSString stringWithFormat:@"未在行程中"];
//    }
    remainingTime     = route.remainingTime;
    remainingDistance = route.remainingDistance;
    
    self.remainingString = [NSString stringWithFormat:@"剩余里程：%d米",remainingDistance];
    
//    self.label.text = remainingString;
    
    NSLog(@"%@", self.remainingString );
}

- (void)clearInfoLabel
{
    self.label.text = @"";
}

- (void)handleStartFetch:(UIBarButtonItem *)sender
{
    if (self.passengerManager.isRunning) {
        // 关闭
        [self.passengerManager stop];
    }else {
        [self.passengerManager start];
        
        [self clearInfoLabel];
    }
    
    sender.title = self.passengerManager.isRunning ? @"停止拉取" : @"开启拉取";

}

- (void)handleStopFetch:(UIBarButtonItem *)sender
{
    self.passengerManager.uploadPassengerPositionsEnabled = !self.passengerManager.uploadPassengerPositionsEnabled;
    sender.title = self.passengerManager.uploadPassengerPositionsEnabled ? @"关闭上报定位" : @"开启上报定位";
}

@end
