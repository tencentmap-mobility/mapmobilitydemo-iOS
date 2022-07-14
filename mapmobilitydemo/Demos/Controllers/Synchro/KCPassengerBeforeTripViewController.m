//
//  KCPassengerBeforeTripViewController.m
//  TencentMapLocusSynchroDemo
//
//  Created by mol on 2021/9/1.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "KCPassengerBeforeTripViewController.h"
#import <QMapKit/QMapKit.h>
#import <TencentMapLocusSynchroPassengerSDK/TencentMapLocusSynchroPassengerSDK.h>
#import <TNKNavigationKit/TNKNavigationKit.h>
#import "RouteLocation.h"
#import "Constants.h"
#import "CarBubbleAnnotationView.h"
#import "KCChooseRouteViewController.h"
#import "TLSRoutePolyline.h"
#import "MathTool.h"
#import "KCPassengerModule.h"
#import "KCDriverModule.h"
#import "CarRoutePolyline.h"
#import "KCOrderManager.h"
#import "SVProgressHUD.h"

// 乘客id
NSString * const kChooseRouteBeforeTripPassengerID = @"kc_passenger_chooseroute_beforetrip";
// 司机id
NSString * const kChooseRouteBeforeTripDriverID = @"kc_driver_chooseroute_beforetrip";

@interface KCPassengerBeforeTripViewController () <
QMapViewDelegate,
TLSPassengerManagerDelegate>

// 乘客地图
@property (nonatomic, strong) QMapView *passengerMapView;
@property (nonatomic, strong) KCPassengerModule *passengerModule;
// 地图SDK的路线端点marker
@property (nonatomic, strong, nullable) QPointAnnotation *routeEndPointMarker;

// 司机地图
@property (nonatomic, strong) TNKCarNaviView *driverNaviView;
@property (nonatomic, strong) KCDriverModule *driverModule;

@property (nonatomic, strong) KCMyOrder *order;

@end

@implementation KCPassengerBeforeTripViewController

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
        
    [self setupToolbar];

    // 设置乘客部分
    [self setupPassengerMapView];
    
    // 设置司机部分
    [self setupDriverMapView];
    
    [self setupOrder];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setToolbarHidden:NO animated:animated];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.passengerMapView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height / 2);
    self.driverNaviView.frame = CGRectMake(0, CGRectGetMaxY(self.passengerMapView.frame),
                                           self.view.bounds.size.width,
                                           self.view.bounds.size.height / 2);

}

- (void)dealloc {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - private

- (void)setupOrder {
    
    
//    KCMyOrder *order = [[KCMyOrder alloc] init];
//    // 订单id，这里随机生成
//    order.orderID = @"kc_iOS_songJia_test_5";
//
//    // 乘客id
//    order.passengerID = @"kc_passenger_putong_test5";
//    order.driverID = @"kc_driver_iOS_test4";
//
//    //接驾点
//    MyPOI *startPOI = [[MyPOI alloc] init];
//    startPOI.coord = CLLocationCoordinate2DMake(39.969283,116.301937);//(39.988955, 116.410266);
//    startPOI.poiName = @"中国化工大厦-西门";
//    order.startPOI = startPOI;
//
//    // 送驾点
//    MyPOI *endPOI = [[MyPOI alloc] init];
//    endPOI.coord = CLLocationCoordinate2DMake(40.129771, 116.641374);
//    endPOI.poiName = @"仓上小区[公交站]";
//    order.endPOI = endPOI;
//
//    // 北京
//    order.adCode = @"110000";
//    self.order = order;
//    [self setupPassengerModule];
//   
    
    KCMyOrder *order = [[KCMyOrder alloc] init];
    // 订单id，这里随机生成
    order.orderID = [NSUUID UUID].UUIDString;

    // 乘客id
    order.passengerID = kChooseRouteBeforeTripPassengerID;
    order.driverID = kChooseRouteBeforeTripDriverID;

    //接驾点
    MyPOI *startPOI = [[MyPOI alloc] init];
    startPOI.coord = CLLocationCoordinate2DMake(39.988955, 116.410266);
    startPOI.poiName = @"中国化工大厦-西门";
    order.startPOI = startPOI;

    // 送驾点
    MyPOI *endPOI = [[MyPOI alloc] init];
    endPOI.coord = CLLocationCoordinate2DMake(40.113174, 116.658524);
    endPOI.poiName = @"仓上小区[公交站]";
    order.endPOI = endPOI;

    // 北京
    order.adCode = @"110000";

    __weak typeof(self) weakself = self;
    [[KCOrderManager sharedInstance] createOrder:order completion:^(BOOL success, NSError * _Nullable error) {

        __strong KCPassengerBeforeTripViewController *strongself = weakself;
        if (!strongself) {
            return;
        }
        if (!success) {
            NSLog(@"创建订单失败:status=%d, message=%@", error.code, error.userInfo);
        } else {
            strongself.order = order;
            [strongself setupPassengerModule];
        }

    }];
}

- (void)setupPassengerMapView {
    
    self.passengerMapView = [[QMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height / 2)];
    
    self.passengerMapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.passengerMapView.delegate = self;
    self.passengerMapView.showsUserLocation = YES;
    self.passengerMapView.rotateEnabled = NO;
    self.passengerMapView.overlookingEnabled = NO;
    
    [self.view addSubview:self.passengerMapView];
   
}

- (void)setupPassengerModule {
    
    if (self.passengerModule) {
        return;
    }
    self.passengerModule = [[KCPassengerModule alloc] initWithOrder:self.order];
    self.passengerModule.mapView = self.passengerMapView;
}

- (void)setupDriverMapView {
        
    self.driverNaviView = [[TNKCarNaviView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.passengerMapView.frame), self.view.bounds.size.width, self.view.bounds.size.height / 2)];
    
    self.driverNaviView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.driverNaviView.naviMapView.delegate = self;
    [self.view addSubview:self.driverNaviView];
}

- (void)setupDriverModule {
    
    if (self.driverModule) {
        return;
    }
    self.driverModule = [[KCDriverModule alloc] initWithOrder:self.order];
    self.driverModule.carNaviView = self.driverNaviView;
}

- (void)setupToolbar {
    
    UIBarButtonItem *flexble = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *searchButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"1.乘客算路" style:UIBarButtonItemStyleDone target:self action:@selector(passengerSearch:)];
    UIBarButtonItem *uploadRouteButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"2.乘客选路上报" style:UIBarButtonItemStyleDone target:self action:@selector(uploadRoute:)];
    
    UIBarButtonItem *driverSearchItem = [[UIBarButtonItem alloc] initWithTitle:@"3.司机送驾路线" style:UIBarButtonItemStyleDone target:self action:@selector(driverSearch:)];

    self.toolbarItems = @[flexble,
                          searchButtonItem,
                          flexble,
                          uploadRouteButtonItem,
                          flexble,
                          driverSearchItem,
                          flexble
    ];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
}


# pragma mark - QMapViewDelegate

- (QOverlayView *)mapView:(QMapView *)mapView viewForOverlay:(id<QOverlay>)overlay {
    
    if ([overlay isKindOfClass:[TLSRoutePolyline class]])  {
        TLSRoutePolyline *trafficPolyline = overlay;
        QTexturePolylineView *polylineRender = [[QTexturePolylineView alloc] initWithPolyline:overlay];
        polylineRender.drawType = QTextureLineDrawType_ColorLine;
        polylineRender.segmentColor = trafficPolyline.segmentColors;
        polylineRender.borderColor  = [UIColor colorWithRed:0 green:0.8 blue:0 alpha:0.15];
        polylineRender.lineWidth    = 10;
        polylineRender.borderWidth  = 1;
        polylineRender.drawSymbol   = YES;
        
        return polylineRender;
    } else if ([overlay isKindOfClass:[CarRoutePolyline class]]) {
        
        CarRoutePolyline *trafficPolyline = overlay;
        QTexturePolylineView *polylineRender = [[QTexturePolylineView alloc] initWithPolyline:overlay];
        polylineRender.drawType = QTextureLineDrawType_ColorLine;
        polylineRender.segmentColor = trafficPolyline.segmentColors;
        polylineRender.borderColor  = [UIColor colorWithRed:0 green:0.8 blue:0 alpha:0.15];
        polylineRender.lineWidth    = 10;
        polylineRender.borderWidth  = 1;
        polylineRender.drawSymbol   = YES;
        
        return polylineRender;
    }
    
    return nil;
}

- (QAnnotationView *)mapView:(QMapView *)mapView viewForAnnotation:(id<QAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[QPointAnnotation class]]) {
        
        if (annotation.title.length == 0) {
            return nil;
        }
        
        QAnnotationView *annotationView = (QAnnotationView*)[self.passengerMapView dequeueReusableAnnotationViewWithIdentifier:annotation.title];
                
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
                annotationView = [[CarBubbleAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotation.title];
            }else {
                annotationView.annotation = annotation;
            }
            annotationView.centerOffset = CGPointMake(0, -40);
            annotationView.canShowCallout = NO;
        }
        else if ([annotation.title isEqualToString:@"end_circle"]) {
            if (!annotationView) {
                annotationView = [[QAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotation.title];
            }else {
                annotationView.annotation = annotation;
            }
            UIImage *image = [UIImage imageNamed:@"end_circle"];
            annotationView.image = image;
        }
   
        return annotationView;
    }
    
    return nil;
}

- (void)mapView:(QMapView *)mapView didTapOverlay:(id<QOverlay>)overlay {
    
    if ([self.passengerModule isMyOverlay:overlay]) {
        [self.passengerModule handleDidTapOverlay:overlay];
    }
}

# pragma mark - Action

// 乘客行前选路
- (void)passengerSearch:(UIBarButtonItem *)sender {

    if (!self.order) {
        NSLog(@"订单未创建成功！");
        [SVProgressHUD showErrorWithStatus:@"订单未创建成功！"];
        
        return;
    }
    
    TLSPSearchDrivingRequest *request = [[TLSPSearchDrivingRequest alloc] init];
    // 导航起点，司机当前位置
    TLSBNaviPOI *startPOI = [[TLSBNaviPOI alloc] init];
    startPOI.coordinate = self.order.startPOI.coord;
    // 导航终点，乘客下车位置
    TLSBNaviPOI *endPOI = [[TLSBNaviPOI alloc] init];
    endPOI.coordinate = self.order.endPOI.coord;
    
    request.start = startPOI;
    request.destination = endPOI;
    
    [self.passengerModule calcRoutesAndShowWithRequest:request];
}

// 乘客行前选择送驾路线
- (void)uploadRoute:(UIBarButtonItem *)sender {
    if (!self.order) {
        [SVProgressHUD showErrorWithStatus:@"订单未创建成功！"];
        NSLog(@"订单未创建成功！");
        return;
    }
    
    // 上报选中路线
    [self.passengerModule uploadSelctedRoute];
}

// 司机端送驾算路
- (void)driverSearch:(UIBarButtonItem *)sender {
    if (!self.order) {
        NSLog(@"订单未创建成功！");
        [SVProgressHUD showErrorWithStatus:@"订单未创建成功！"];
        return;
    }

    // 创建司机端司乘同显管理对象
    [self setupDriverModule];

    
    // 导航起点，司机当前位置
    TNKSearchNaviPoi *startPOI = [[TNKSearchNaviPoi alloc] init];
    startPOI.coordinate = self.order.startPOI.coord;
    // 导航终点，乘客下车位置
    TNKSearchNaviPoi *endPOI = [[TNKSearchNaviPoi alloc] init];
    endPOI.coordinate = self.order.endPOI.coord;;
    
    TNKCarRouteSearchOption *option = [[TNKCarRouteSearchOption alloc] init];
    // 送驾参数
    option.navScene = 2;
    
    // 路径规划
    [self.driverModule searchRouteAndStartNaviWithStart:startPOI end:endPOI option:option];
}

@end
