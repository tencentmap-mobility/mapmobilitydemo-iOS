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

@interface KCDriverSynchroViewController ()<TNKCarNaviViewDelegate, TNKCarNaviDelegate, TLSDriverManagerDelegate, QMapViewDelegate, TencentLBSLocationManagerDelegate>

// 驾车导航
@property (nonatomic, strong) TNKCarNaviManager *carNaviManager;
@property (nonatomic, strong) TNKCarNaviView *carNaviView;

// 司乘同学司机管理类
@property (nonatomic, strong) TLSDriverManager *driverManager;

@property (nonatomic, strong) QPointAnnotation *passengerAnnotation;

@property (nonatomic, strong) TencentLBSLocationManager *locationManager;
@property (nonatomic, assign) NSTimeInterval lastLocationTimestamp;
// 正在导航中
@property (nonatomic, assign) BOOL isNavigating;

//起终bar item
@property (nonatomic, strong) UIBarButtonItem *searchNavi;
@property (nonatomic, strong) UIBarButtonItem *startNavi;
@property (nonatomic, strong) UIBarButtonItem *stopNavi;

@property (nonatomic, strong) TrafficPolyline *trafficLine;
@property (nonatomic, strong) TNKCarRouteSearchResult *routeResult;

@property (nonatomic, strong) QPointAnnotation *destAnnotation;
@property (nonatomic, strong) QPointAnnotation *startAnnotation;
@end

@implementation KCDriverSynchroViewController

#pragma mark - life cycle
- (void)dealloc {
    
    [self.carNaviManager stop];
    [self.driverManager stop];
    [self stopSerialLocation];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupCarNaviView];
    [self setupCarNaviManager];
    [self setupSynchroDriverManager];
    [self setupToolbar];
    
    // 启动定位SDK
    [self configLocationManager];
    self.destAnnotation = [[QPointAnnotation alloc] init];
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

- (void)setupCarNaviView
{
    // 初始化地图
    self.carNaviView = [[TNKCarNaviView alloc] initWithFrame:self.view.bounds];
    self.carNaviView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.carNaviView];
    self.carNaviView.delegate = self;
    self.carNaviView.showUIElements = NO;
    self.carNaviView.naviMapView.delegate = self;
    self.carNaviView.naviMapView.showsUserLocation = YES;
}

- (void)setupCarNaviManager
{
    // 初始化导航管理器
    self.carNaviManager = [[TNKCarNaviManager alloc] init];
     self.carNaviManager.enableInternalTTS = YES;
    [self.carNaviManager registerNaviDelegate:self];
    [self.carNaviManager registerUIDelegate:self.carNaviView];
}

- (void)setupSynchroDriverManager
{
    // 初始化司乘同显
    TLSDConfig *dConfig = [[TLSDConfig alloc] init];
    dConfig.driverID = kSynchroKCDriverAccountID;
    dConfig.key = kSynchroKey;
    
    self.driverManager = [[TLSDriverManager alloc] initWithConfig:dConfig];
    self.driverManager.delegate = self;
    self.driverManager.carNaviView = self.carNaviView;
    self.driverManager.carNaviManger = self.carNaviManager;
    self.driverManager.orderID = kSynchroKCOrderID;
    self.driverManager.orderType = TLSBOrderTypeNormal;
    self.driverManager.orderStatus = TLSBOrderStatusTrip;
    self.driverManager.driverStatus = TLSDDriverStatusServing;
    self.driverManager.fetchPassengerPositionsEnabled = YES;
    [self.driverManager start];
}

- (void)setupToolbar
{
    UIBarButtonItem *flexble = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    self.searchNavi   = [[UIBarButtonItem alloc] initWithTitle:@"路线规划" style:UIBarButtonItemStyleDone target:self action:@selector(handleNaviSearch:)];
    self.startNavi    = [[UIBarButtonItem alloc] initWithTitle:@"开始导航" style:UIBarButtonItemStyleDone target:self action:@selector(handleStartNavi:)];
    self.stopNavi     = [[UIBarButtonItem alloc] initWithTitle:@"退出界面" style:UIBarButtonItemStyleDone target:self action:@selector(handleStopNavi:)];
    
    self.toolbarItems = @[flexble, self.searchNavi,
                          flexble, self.startNavi,
                          flexble, self.stopNavi,
                          flexble];
}
#pragma mark - actions

- (void)addDestAnnotation:(CLLocationCoordinate2D)coordinate
{
    [self.carNaviView.naviMapView removeAnnotation:self.destAnnotation];

    self.destAnnotation = [[QPointAnnotation alloc] init];
    self.destAnnotation.coordinate = coordinate;
    self.destAnnotation.title = @"destAnnotation";

    [self.carNaviView.naviMapView addAnnotation:self.destAnnotation];
}

- (void)handleNaviSearch:(UIBarButtonItem *)sender
{
    self.isNavigating = NO;
    [self.carNaviManager stop];
    self.carNaviView.showUIElements = NO;
    self.carNaviView.hideNavigationPanel = YES;
    [self.carNaviView clearAllRouteUI];
    
    [self searchRoutePlanning];
}

- (void)handleStartNavi:(UIBarButtonItem *)sender
{

    [self.navigationController setToolbarHidden:YES animated:YES];
    self.carNaviView.naviMapView.showsUserLocation = NO;
    // 开启导航
    self.isNavigating = YES;
    self.carNaviView.showUIElements = YES;
    self.carNaviView.hideNavigationPanel = NO;
    [self.carNaviView.naviMapView removeOverlay:self.trafficLine];
    [self.carNaviView.naviMapView removeAnnotation:self.destAnnotation];
    [self.carNaviManager startSimulateWithIndex:0 locationEntry:nil];
}

- (void)handleStopNavi:(UIBarButtonItem *)sender
{
    self.isNavigating = NO;
    [self.carNaviManager stop];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)searchRoutePlanning
{
     // 导航起终点
     TNKSearchNaviPoi *startPOI = [[TNKSearchNaviPoi alloc] init];
     startPOI.coordinate = self.carNaviView.naviMapView.userLocation.location.coordinate;
     // startPOI.coordinate = kSynchroDriverStart;
     TNKSearchNaviPoi *endPOI = [[TNKSearchNaviPoi alloc] init];
     endPOI.coordinate = kSynchroDriverEnd;
    [self addDestAnnotation:endPOI.coordinate];
     [self searchRouteAndStartNaviWithStart:startPOI end:endPOI wayPoints:@[]];
}

- (QMapRect)visibleMapRectForNaviResult:(TNKCarRouteSearchResult *)result
{
    NSAssert(result.routes.count != 0, @"route count 0 error");
    
    TNKCarRouteSearchRoutePlan *plan = result.routes[0];
    TNKCarRouteSearchRouteLine *line = plan.line;
    
    return [MathTool mapRectFitsPoints:line.coordinatePoints];
}

- (TrafficPolyline *)polylineForRoutePlan :(TNKCarRouteSearchRoutePlan *)routePlan
{

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

- (void)searchRouteAndStartNaviWithStart:(TNKSearchNaviPoi *)startPOI
                                     end:(TNKSearchNaviPoi *)endPOI
                               wayPoints:(NSArray<TLSDWayPointInfo *> * _Nullable)wayPoints {
    
    __weak typeof(self) weakself = self;

    [self.driverManager searchCarRoutesWithStart:startPOI end:endPOI wayPoints:wayPoints option:nil completion:^(TNKCarRouteSearchResult * _Nonnull result, NSError * _Nullable error) {
       
        __strong KCDriverSynchroViewController *strongself = weakself;
        if (!strongself) {
            return ;
        }
        
        if (error) {
            // 处理错误
            return;
        }
        
        [strongself.driverManager uploadRouteWithIndex:0];
        weakself.routeResult = result;
        
        strongself.trafficLine = [strongself polylineForRoutePlan:result.routes.firstObject];
        [strongself.carNaviView.naviMapView addOverlay:strongself.trafficLine];
        
        QMapRect mapRect = [weakself visibleMapRectForNaviResult:result];
        [weakself.carNaviView.naviMapView setVisibleMapRect:mapRect edgePadding:UIEdgeInsetsMake(kNavigationBarHeight + 64, 30, kHomeIndicatorHeight + 64 + 80, 30) animated:YES];
    }];
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
    self.driverManager.cityCode = location.code;
    
//    if (!self.isNavigating) {
//        // 听单中上报定位点
//        TLSDDriverPosition *myPosition = [[TLSDDriverPosition alloc] init];
//        myPosition.location = location.location;
//        myPosition.cityCode = location.code;
//        [self.driverManager uploadPosition:myPosition];
//    }
}


#pragma mark - TNKCarNaviDelegate
- (void)carNavigationManager:(TNKCarNaviManager *)manager didUpdateLocation:(TNKLocation *)location {
    
}

#pragma mark - TNKCarNaviViewDelegate
- (void)carNaviViewCloseButtonClicked:(TNKCarNaviView *)carNaviView {
    self.isNavigating = NO;
    [self.carNaviManager stop];
    self.carNaviView.showUIElements = NO;
    self.carNaviView.hideNavigationPanel = YES;
    [self.carNaviView clearAllRouteUI];
    self.carNaviView.naviMapView.showsUserLocation = YES;
    
     [self.navigationController setToolbarHidden:NO animated:YES];
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

#pragma mark - QMapViewDelegate
- (QAnnotationView *)mapView:(QMapView *)mapView viewForAnnotation:(id<QAnnotation>)annotation {
    
        if ([annotation isKindOfClass:[QPointAnnotation class]])
        {
            static NSString *pointReuseIndetifier = @"pointReuseIndetifier";
            QPinAnnotationView *annotationView = (QPinAnnotationView *)[self.carNaviView.naviMapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndetifier];
            
            if (annotationView == nil)
            {
                annotationView = [[QPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndetifier];
            }
            
            if ([annotation.title isEqualToString:@"destAnnotation"])
            {
                NSString *identifier = @"destination";
                QAnnotationView *annotationView = [self.carNaviView.naviMapView dequeueReusableAnnotationViewWithIdentifier:identifier];
                if (!annotationView)
                {
                    annotationView = [[QAnnotationView alloc] init];
                }
                annotationView.image = [UIImage imageNamed:@"ic_end"];
                return annotationView;
            }
            
            annotationView.animatesDrop = YES;
            
            return annotationView;
        }
    return nil;
}


- (QOverlayView *)mapView:(QMapView *)mapView viewForOverlay:(id<QOverlay>)overlay
{
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
