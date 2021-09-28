//
//  DriverSynchroViewController.m
//  TencentMapLocusSynchroDemo
//
//  Created by Yuchen Wang on 2020/3/9.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "KCDriverSynchroViewController.h"
#import <TNKNavigationKit/TNKNavigationKit.h>
#import <TencentMapLocusSynchroDriverSDK/TencentMapLocusSynchroDriverSDK.h>
#import "Constants.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import <TencentLBS/TencentLBS.h>
#import "TrafficPolyline.h"
#import "MathTool.h"
#import "OrderMenuViewController.h"

NSString * const kStartMarkerId = @"startMarker";
NSString * const kDestMarkerId = @"destMarker";

@interface KCDriverSynchroViewController () <
TNKCarNaviViewDelegate, TNKCarNaviDelegate, TNKCarNaviUIDelegate,
TLSDriverManagerDelegate,
QMapViewDelegate,
TencentLBSLocationManagerDelegate,
OrderMenuViewDelegate
>

// 退出页面按钮
@property (nonatomic, strong) UIBarButtonItem *exitItem;
// 菜单按钮
@property (nonatomic, strong) UIBarButtonItem *menuItem;

// 驾车导航管理器
@property (nonatomic, strong) TNKCarNaviManager *carNaviManager;
// 导航地图
@property (nonatomic, strong) TNKCarNaviView *carNaviView;
// 司乘同显司机管理类
@property (nonatomic, strong) TLSDriverManager *driverManager;

// 定位管理类，在非导航状态下获取定位使用
@property (nonatomic, strong) TencentLBSLocationManager *locationManager;

// 起点marker
@property (nonatomic, strong, nullable) QPointAnnotation *startMarker;
// 终点marker
@property (nonatomic, strong, nullable) QPointAnnotation *destMarker;
// 乘客位置
@property (nonatomic, strong, nullable) QPointAnnotation *passengerMarker;

// 路况
@property (nonatomic, strong, nullable) TrafficPolyline *trafficLine;
// 路线结果
@property (nonatomic, strong, nullable) TNKCarRouteSearchResult *routeResult;

// 上次定位更新时间戳
@property (nonatomic, assign) NSTimeInterval lastLocationTimestamp;
// 正在是否在导航中
@property (nonatomic, assign) BOOL isNavigating;

// 当前订单状态
@property (nonatomic, assign) TLSBOrderStatus curOrderStatus;

@end

@implementation KCDriverSynchroViewController

#pragma mark - life cycle
- (void)dealloc {
    
    [self.carNaviManager stop];
    [self.driverManager stop];
    // 结束连续定位
    [self stopSerialLocation];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // 地图初始化
    [self setupCarNaviView];
    // 导航管理类初始化
    [self setupCarNaviManager];
    // 司乘同显初始化
    [self setupSynchroDriverManager];
    
    // 设置toolbar
    [self setupToolbar];
    
    // 启动定位SDK
    [self configLocationManager];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [self.navigationController setToolbarHidden:NO animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

#pragma mark - setups

- (void)setupCarNaviView {
    // 初始化地图
    self.carNaviView = [[TNKCarNaviView alloc] initWithFrame:self.view.bounds];
    self.carNaviView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.carNaviView];
    // 检测导航地图的事件回调
    self.carNaviView.delegate = self;
    // 不展示导航的默认UI元素
    self.carNaviView.showUIElements = NO;
    // 注册地图QMapView的事件回调
    self.carNaviView.naviMapView.delegate = self;
    // 展示当前位置的icon，导航时隐藏
    self.carNaviView.naviMapView.showsUserLocation = YES;
}

// 初始化驾车导航管理类
- (void)setupCarNaviManager {
    
    // 初始化导航管理器
    self.carNaviManager = [[TNKCarNaviManager alloc] init];
    // 使用导航自带tts播报
     self.carNaviManager.enableInternalTTS = YES;
    // 注册接收导航事件变化.
    [self.carNaviManager registerNaviDelegate:self];
    [self.carNaviManager registerUIDelegate:self];
    // 将导航管理器和导航地图关联, 必须
    [self.carNaviManager registerUIDelegate:self.carNaviView];
}

// 初始化司乘同显管理类，并关联导航管理类
- (void)setupSynchroDriverManager {
    
    // 初始化司乘同显
    TLSDConfig *dConfig = [[TLSDConfig alloc] init];
    // 设置司机id
    dConfig.driverID = kSynchroKCDriverAccountID;
    // 设置司乘同显Key
    dConfig.key = kSynchroKey;
    dConfig.secretKey = kSynchroSecretKey;
    
    self.driverManager = [[TLSDriverManager alloc] initWithConfig:dConfig];
    self.driverManager.delegate = self;
    // 导航地图交由司乘同显操作
    self.driverManager.carNaviView = self.carNaviView;
    // 导航管理器交由司乘同显操作
    self.driverManager.carNaviManger = self.carNaviManager;
    
    // 司机状态更改为服务中
    self.driverManager.driverStatus = TLSDDriverStatusServing;
    
    // 允许送驾过程乘客选路
    //self.driverManager.passengerChooseRouteEnable = YES;
    
    self.driverManager.fetchPassengerPositionsEnabled = YES;

    
    //开启司乘同显
    [self.driverManager start];
}

// 设置底部工具栏
- (void)setupToolbar {
    
    UIBarButtonItem *flexble = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                             target:nil
                                                                             action:nil];
    
    self.exitItem = [[UIBarButtonItem alloc] initWithTitle:@"退出界面"
                                                     style:UIBarButtonItemStyleDone
                                                    target:self
                                                    action:@selector(handleExitAction:)];
    
    self.menuItem    = [[UIBarButtonItem alloc] initWithTitle:@"控制菜单"
                                                        style:UIBarButtonItemStyleDone
                                                       target:self
                                                       action:@selector(handleMenuAction:)];
    
    self.toolbarItems = @[flexble,
                          self.exitItem,
                          flexble,
                          self.menuItem,
                          flexble];
}

#pragma mark - actions

- (void)addDestMarker:(CLLocationCoordinate2D)coordinate {
    
    [self.carNaviView.naviMapView removeAnnotation:self.destMarker];

    self.destMarker = [[QPointAnnotation alloc] init];
    self.destMarker.coordinate = coordinate;
    self.destMarker.title = kDestMarkerId;

    [self.carNaviView.naviMapView addAnnotation:self.destMarker];
}

- (void)addStartMarker:(CLLocationCoordinate2D)coordinate {
    
    [self.carNaviView.naviMapView removeAnnotation:self.startMarker];

    self.startMarker = [[QPointAnnotation alloc] init];
    self.startMarker.coordinate = coordinate;
    self.startMarker.title = kStartMarkerId;

    [self.carNaviView.naviMapView addAnnotation:self.startMarker];
}

- (void)handleStartNavi:(BOOL)isSimulation {

    // 隐藏toolbar
    [self.navigationController setToolbarHidden:YES animated:YES];
    // 隐藏地图"我的位置"的icon
    self.carNaviView.naviMapView.showsUserLocation = NO;
    self.carNaviView.dayNightMode = TNKCarNaviDayNightModeAuto;
    self.carNaviView.mode = TNKCarNaviUIMode3DCarTowardsUp;
    
    // 开启导航
    self.isNavigating = YES;
    // 展示默认UI
    self.carNaviView.showUIElements = YES;
    self.carNaviView.hideNavigationPanel = NO;
    
    // 移除导航前的元素
    [self.carNaviView.naviMapView removeOverlay:self.trafficLine];
    [self.carNaviView.naviMapView removeAnnotation:self.destMarker];
    [self.carNaviView.naviMapView removeAnnotation:self.startMarker];
    
    // 需要导航前调用 [self.driverManager uploadRouteWithRouteID:routePlan.routeID];
    // 这样self.driverManager.selectedRouteID的值才会存在
    
    if (isSimulation) {
        //开启模拟导航
        [self.carNaviManager startSimulateWithRouteID:self.driverManager.selectedRouteID locationEntry:nil];
    } else {
        [self.carNaviManager startWithRouteID:self.driverManager.selectedRouteID];
    }
    
    // 送驾接力单事例
    
//    if (TLSBOrderStatusTrip == self.driverManager.orderStatus) {
//
//        // 2秒后接到接力单
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            // 收到接力单
//
//            //接力单接驾点
//            TNKSearchNaviPoi *relayPickupPoint = [[TNKSearchNaviPoi alloc] init];
//            relayPickupPoint.coordinate = kSynchroKCPassenger2Start;
//
//            // 当前订单终点
//            TNKSearchNaviPoi *curTripPoint = [[TNKSearchNaviPoi alloc] init];
//            curTripPoint.coordinate = kSynchroKCPassenger1End;
//
//            __weak typeof(self) weakself = self;
//
//            [self.driverManager setupRelayOrder:kSynchroKCOrder2ID relayPickupPoint:relayPickupPoint curTripPoint:curTripPoint option:nil completion:^(TNKCarRouteSearchResult * _Nonnull result, NSError * _Nullable error) {
//
//                __strong KCDriverSynchroViewController *strongself = weakself;
//                if (!strongself) {
//                    return;
//                }
//
//                if (!error) {
//
//                    // 上报接力单路线
//                    [strongself.driverManager uploadRelayRoute:result.routes.firstObject];
//                }
//            }];
//        });
//
//    }
}

// 退出
- (void)handleExitAction:(UIBarButtonItem *)sender {
    
    self.isNavigating = NO;
    [self.carNaviManager stop];
    
    [self.navigationController popViewControllerAnimated:YES];
}

// 打开菜单
- (void)handleMenuAction:(UIBarButtonItem *)sender {

    self.modalPresentationStyle = UIModalPresentationCurrentContext;

    OrderMenuViewController *orderMenuVC = [[OrderMenuViewController alloc] init];
    orderMenuVC.delegate = self;
    orderMenuVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
    orderMenuVC.orderStatus = self.curOrderStatus;
    
    [self presentViewController:orderMenuVC animated:NO completion:^{
        [orderMenuVC showMenu];
    }];
}

// 进行接驾路径规划
- (void)searchPickupRoute {
    
    // 导航起点，司机当前位置
    TNKSearchNaviPoi *startPOI = [[TNKSearchNaviPoi alloc] init];
    startPOI.coordinate = self.carNaviView.naviMapView.userLocation.location.coordinate;
    // 导航终点，乘客上车位置
    TNKSearchNaviPoi *endPOI = [[TNKSearchNaviPoi alloc] init];
    endPOI.coordinate = kSynchroKCPassenger1Start;
    
    [self searchRouteAndStartNaviWithStart:startPOI end:endPOI wayPoints:@[]];
}

// 进行送驾路径规划
- (void)searchTripRoute {
    
    // 导航起点，司机当前位置
    TNKSearchNaviPoi *startPOI = [[TNKSearchNaviPoi alloc] init];
    startPOI.coordinate = self.carNaviView.naviMapView.userLocation.location.coordinate;
    // 导航终点，乘客下车位置
    TNKSearchNaviPoi *endPOI = [[TNKSearchNaviPoi alloc] init];
    endPOI.coordinate = kSynchroKCPassenger1End;
    
    [self searchRouteAndStartNaviWithStart:startPOI end:endPOI wayPoints:@[]];
}

// 计算路线展示在地图上的视野
- (QMapRect)visibleMapRectForRoutePlan:(TNKCarRouteSearchRoutePlan *)routePlan {
    
    TNKCarRouteSearchRouteLine *line = routePlan.line;
    
    return [MathTool mapRectFitsPoints:line.coordinatePoints];
}

// 通过路线数据创建Overlay，画到地图上
- (TrafficPolyline *)polylineForRoutePlan:(TNKCarRouteSearchRoutePlan *)routePlan {

    TNKCarRouteSearchRouteLine *line = routePlan.line;
    NSArray<TNKRouteTrafficData *> *trafficDataArray = line.initialTrafficDataArray;
    int count = (int)line.coordinatePoints.count;
    CLLocationCoordinate2D *coordinateArray = (CLLocationCoordinate2D*)malloc(sizeof(CLLocationCoordinate2D)*count);
    for (int i = 0; i < count; ++i)
    {
        coordinateArray[i] = [(TNKCoordinatePoint*)[line.coordinatePoints objectAtIndex:i] coordinate];
    }
    
    NSMutableArray* routeLineArray = [NSMutableArray array];
    for (TNKRouteTrafficData *trafficData in trafficDataArray) {
        QSegmentColor *segmentColor = [[QSegmentColor alloc] init];
        segmentColor.startIndex = (int)trafficData.from;
        segmentColor.endIndex   = (int)trafficData.to;
        segmentColor.color = TNKRouteTrafficStatusColor(trafficData.color);
        [routeLineArray addObject:segmentColor];
    }
    
    // 创建路线,一条路线由一个点数组和线段数组组成
    TrafficPolyline *routeOverlay = [[TrafficPolyline alloc] initWithCoordinates:coordinateArray count:count arrLine:routeLineArray];
    
    free(coordinateArray);
    
    return routeOverlay;
}

// 路径规划
- (void)searchRouteAndStartNaviWithStart:(TNKSearchNaviPoi *)startPOI
                                     end:(TNKSearchNaviPoi *)endPOI
                               wayPoints:(NSArray<TLSDWayPointInfo *> * _Nullable)wayPoints {
    
    __weak typeof(self) weakself = self;
    
    // 移除当前路线
    [self.carNaviView.naviMapView removeOverlay:self.trafficLine];

    // 司乘同显路径规划接口，内部调用了导航SDK的路径规划服务
    [self.driverManager searchCarRoutesWithStart:startPOI end:endPOI wayPoints:wayPoints option:nil completion:^(TNKCarRouteSearchResult * _Nonnull result, NSError * _Nullable error) {
       
        __strong KCDriverSynchroViewController *strongself = weakself;
        if (!strongself) {
            return ;
        }
        
        if (error) {
            // 处理错误
            return;
        }
        
        // 保存路径规划结果
        strongself.routeResult = result;
        // 先选择首方案
        [strongself selectAndShowRoutePlan:result.routes.firstObject];
    }];
}

- (void)selectAndShowRoutePlan:(TNKCarRouteSearchRoutePlan *)routePlan {

    // 上传路线信息到司乘同显服务
    [self.driverManager uploadRouteWithRouteID:routePlan.routeID];
     
    // 画路线
    if (self.trafficLine) {
        [self.carNaviView.naviMapView removeOverlay:self.trafficLine];
        self.trafficLine = nil;
    }
    self.trafficLine = [self polylineForRoutePlan:routePlan];
    [self.carNaviView.naviMapView addOverlay:self.trafficLine];
    
    // 调整地图视野
    QMapRect mapRect = [self visibleMapRectForRoutePlan:routePlan];
    [self.carNaviView.naviMapView setVisibleMapRect:mapRect
                                              edgePadding:UIEdgeInsetsMake(kNavigationBarHeight + 64, 30, kHomeIndicatorHeight + 124, 30) animated:YES];
}


// 停止导航
- (void)stopNavi {
    
    // 切换至日间模式
    [self.carNaviView setDayNightMode:TNKCarNaviDayNightModeAlwaysDay];
    
    // 结束导航
    self.isNavigating = NO;
    [self.carNaviManager stop];
    self.carNaviView.showUIElements = NO;
    self.carNaviView.hideNavigationPanel = YES;
    
    // 结束导航后清理导航中的元素
    [self.carNaviView clearAllRouteUI];
    
    //再次展示地图SDK，我的位置
    self.carNaviView.naviMapView.showsUserLocation = YES;
    
    // 改回俯仰角
    self.carNaviView.naviMapView.overlooking = 0.0;
    
     [self.navigationController setToolbarHidden:NO animated:YES];
    
}

#pragma mark - location manager
- (void)configLocationManager {
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
    if (self.lastLocationTimestamp == [location.location.timestamp timeIntervalSince1970]) {
        // 时间戳相同，过滤
        return;
    }
    self.lastLocationTimestamp = [location.location.timestamp timeIntervalSince1970];
    self.driverManager.cityCode = location.code;
    
//    if (!self.isNavigating) {
//        // 听单中上报定位点
//        TLSDDriverPosition *myPosition = [[TLSDDriverPosition alloc] init];
//        myPosition.location = location.location;
//        myPosition.cityCode = location.code;
//        [self.driverManager uploadPosition:myPosition];
//    }
}

#pragma mark - 司乘同显相关

// 获取订单，订单设置为接驾状态，司机状态为服务中
- (void)getOrder {
    
    self.curOrderStatus = TLSBOrderStatusPickup;
    // 更新司乘同显信息
    self.driverManager.orderID = kSynchroKCOrder1ID;
    // 订单为快车单
    self.driverManager.orderType = TLSBOrderTypeNormal;
    // 订单状态设置为接驾
    self.driverManager.orderStatus = TLSBOrderStatusPickup;
    
    // 地图展示起终点marker，画出接驾路线
    [self addStartMarker:kSynchroKCPassenger1Start];
    [self addDestMarker:kSynchroKCPassenger1End];
    
    // 接驾路径规划
    [self searchPickupRoute];
}

// 订单切换至送驾状态
- (void)startTrip {
    //送驾
    self.curOrderStatus = TLSBOrderStatusTrip;

    // 更新司乘同显信息
    self.driverManager.orderID = kSynchroKCOrder1ID;
    // 订单为快车单
    self.driverManager.orderType = TLSBOrderTypeNormal;
    // 订单状态设置为送驾
    self.driverManager.orderStatus = TLSBOrderStatusTrip;
    
    // 地图展示起终点marker，画出接驾路线
    [self addDestMarker:kSynchroKCPassenger1End];
    
    // 接驾路径规划
    [self searchTripRoute];
}

#pragma mark - OrderMenuViewDelegate

// 切换至接驾
- (void)orderMenuViewControllerPickup:(OrderMenuViewController *)orderMenuViewController {
    [self getOrder];
}

// 切换至送驾
- (void)orderMenuViewControllerTrip:(OrderMenuViewController *)orderMenuViewController {
    [self startTrip];
}

// 开启导航
- (void)orderMenuViewControllerStartNavi:(OrderMenuViewController *)orderMenuViewController {
    [self handleStartNavi:NO];
}

// 开启模拟导航
- (void)orderMenuViewControllerStartSimulateNavi:(OrderMenuViewController *)orderMenuViewController {
    [self handleStartNavi:YES];
}

#pragma mark - TNKCarNaviDelegate
// 获取导航过程中的定位信息，包括原始定位于路线吸附数据
- (void)carNavigationManager:(TNKCarNaviManager *)manager didUpdateLocation:(TNKLocation *)location {
    
}

#pragma mark - TNKCarNaviUIDelegate
- (void)carNavigationManagerDidArriveDestination:(TNKCarNaviManager *)manager {
    // 到达目的地, 停止导航
    [self stopNavi];
}


#pragma mark - TNKCarNaviViewDelegate
- (void)carNaviViewCloseButtonClicked:(TNKCarNaviView *)carNaviView {
    
    // 停止导航
    [self stopNavi];
}

#pragma mark - TLSDriverManagerDelegate
- (void)tlsDriverManager:(TLSDriverManager *)driverManager didFetchData:(TLSDFetchedData *)fetchedData {
    
//    if (fetchedData.positions.count > 0) {
//        // 有定位点
//        CLLocation *passengerLocation = fetchedData.positions.lastObject.location;
//        if (self.passengerAnnotation) {
//            [self.carNaviView.naviMapView removeAnnotation:self.passengerAnnotation];
//        }
//        self.passengerAnnotation = [[QPointAnnotation alloc] init];
//        self.passengerAnnotation.title = @"passengerAnnotation";
//        self.passengerAnnotation.coordinate = passengerLocation.coordinate;
//        [self.carNaviView.naviMapView addAnnotation:self.passengerAnnotation];
//    }else {
//        // 没有定位点了
//    }
}

- (void)tlsDriverManagerDidUploadRouteFail:(TLSDriverManager *)driverManager error:(NSError *)error {
    
}


/**
 * @brief 上报定位成功回调
 * @param driverManager 司机manager
 */
- (void)tlsDriverManagerDidUploadLocationSuccess:(TLSDriverManager *)driverManager {
    
}

/**
 * @brief 上报定位失败回调
 * @param driverManager 司机manager
 * @param error 错误信息
 */
- (void)tlsDriverManagerDidUploadLocationFail:(TLSDriverManager *)driverManager error:(NSError *)error {
    
}

/**
 * @brief 上报路线成功回调
 * @param driverManager 司机manager
 */
- (void)tlsDriverManagerDidUploadRouteSuccess:(TLSDriverManager *)driverManager {
    
}

/// 乘客选路回调。如果当前正在导航，则路线被自动切换。如果当前还没开启导航，需要开发者重新绘制路线然后使用routePlan中的routeID去开启导航
/// @param driverManager 司机manager
/// @param routePlan 路线数据
/// @param trafficStatus 路况数据
- (void)tlsDriverManager:(TLSDriverManager *)driverManager didPassengerChangeRoute:(TNKCarRouteSearchRoutePlan *)routePlan routeTrafficStatus:(TNKRouteTrafficStatus *)trafficStatus {
    
    [SVProgressHUD showInfoWithStatus:@"乘客发送了送驾路线切换命令！"];

    if (self.carNaviManager.isRunning) {
        // 记录新的导航路线
        return;
    }
    
    //还没开启导航，需要开发者重新绘制送驾路线
    [self selectAndShowRoutePlan:routePlan];
}

/// 乘客修改送驾目的地回调. since 2.3.0. 如果当前正在导航，需要开发者调用TLSDriverManager修改目的地方法changeDestination:type:；如果当前还没开启导航，需要开发者重新进行路径规划。
/// @param driverManager 司机manager
/// @param endNaviPOI 新的目的地
- (void)tlsDriverManager:(TLSDriverManager *)driverManager didPassengerChangeDestinaton:(TLSBNaviPOI *)endNaviPOI {
    
    [SVProgressHUD showInfoWithStatus:@"乘客发送了送驾修改目的地命令！"];

    TNKSearchNaviPoi *naviPOI = [[TNKSearchNaviPoi alloc] init];
    naviPOI.coordinate = endNaviPOI.coordinate;
    naviPOI.uid = endNaviPOI.poiID;
    
    if (self.carNaviManager.isRunning) {
        // 记录新的导航路线
       
        // 修改目的地
        [self.driverManager changeOrderDestination:naviPOI type:2];
    } else {
        
        //还没开启导航，需要开发者重新路径规划
        // 导航起点，司机当前位置
        TNKSearchNaviPoi *startPOI = [[TNKSearchNaviPoi alloc] init];
        startPOI.coordinate = self.carNaviView.naviMapView.userLocation.location.coordinate;
        // 导航终点，乘客下车位置
        
        [self searchRouteAndStartNaviWithStart:startPOI end:naviPOI wayPoints:@[]];
        
    }
}


#pragma mark - QMapViewDelegate
- (QAnnotationView *)mapView:(QMapView *)mapView viewForAnnotation:(id<QAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[QPointAnnotation class]]) {

        // 自定义marker
        
        NSString *identifier = annotation.title;

        NSString *imageName;
        
        if ([identifier isEqualToString:kStartMarkerId]) {
            // 起点、接驾点marker
            imageName = @"ic_start_marker";
        } else if ([identifier isEqualToString:kDestMarkerId]) {
            // 终点、送驾点marker
            imageName = @"ic_end_marker";
        }
        
        // 如果是终点marker
        QPinAnnotationView *annotationView = (QPinAnnotationView *)[self.carNaviView.naviMapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (!annotationView) {
            annotationView = [[QPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        }
        annotationView.image = [UIImage imageNamed:imageName];
        annotationView.animatesDrop = YES;
        
        return annotationView;
    }
    
    return nil;
}


- (QOverlayView *)mapView:(QMapView *)mapView viewForOverlay:(id<QOverlay>)overlay {
    if ([overlay isKindOfClass:[TrafficPolyline class]])
    {
        TrafficPolyline *tl = (TrafficPolyline*)overlay;
        QTexturePolylineView *polylineRender = [[QTexturePolylineView alloc] initWithPolyline:overlay];
        polylineRender.drawType = QTextureLineDrawType_ColorLine;
        polylineRender.segmentColor = tl.arrLine;
        polylineRender.borderColor = [UIColor colorWithRed:0 green:0.8 blue:0 alpha:0.15];
        polylineRender.lineWidth   = 10;
        polylineRender.borderWidth = 1;
        //polylineRender.strokeColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:.248];
        polylineRender.drawSymbol = YES;
        
        return polylineRender;
    }
    else if ([overlay isKindOfClass:[QPolyline class]])
    {
        QPolylineView *polylineRender = [[QPolylineView alloc] initWithPolyline:overlay];
        polylineRender.borderColor = [UIColor colorWithRed:0 green:0.8 blue:0 alpha:0.15];
        polylineRender.lineWidth   = 10;
        polylineRender.borderWidth = 1;
        polylineRender.strokeColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:.248];
        return polylineRender;
    }
    
    return nil;
}

@end
