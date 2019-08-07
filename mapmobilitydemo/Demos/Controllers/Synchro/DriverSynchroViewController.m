//
//  DriverSynchroViewController.m
//  TLSLocusSynchroDubugging
//
//  Created by 薛程 on 2018/11/27.
//  Copyright © 2018年 tencent. All rights reserved.
//

#import "DriverSynchroViewController.h"
#import <TencentLBS/TencentLBS.h>
#import "RouteLocation.h"
#import "TrafficPolyline.h"
#import "Constants.h"
#import <TNKNavigationKit/TNKNavigationKit.h>
#import "AppDelegate.h"
#import "NavigationBottomBoard.h"
#import "NavigationSpeedInfo.h"
#import "NavigationStatusBar.h"
#import "MathTool.h"

#define kTrafficStatusBarHeight 10

typedef NS_ENUM(NSInteger, NaviStatus)
{
    NaviStatusNone            = 0,    ///< 未知态.
    NaviStatusReady           = 1,    ///< 准备完成.
    NaviStatusStarted         = 2,    ///< 导航已经启动.
    NaviStatusStoped          = 3     ///< 导航已经结束.
};

@interface DriverSynchroViewController ()
<TNKCarNaviDelegate,
TNKCarNaviUIDelegate,
TNKCarNaviViewDelegate,
TNKCarNaviViewDataSource,
QMapViewDelegate,
UIGestureRecognizerDelegate,
TencentLBSLocationManagerDelegate
>

@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGestureGecognizer;

@property (nonatomic, assign) NaviStatus naviStatus;

@property (nonatomic, strong) UIBarButtonItem *startNavi;

@property (nonatomic, strong) UIBarButtonItem *stopNavi;

@property (nonatomic, strong) UIBarButtonItem *synchroFetchSwitch;

@property (nonatomic, assign) BOOL fetchSwitch;

@property (nonatomic, strong) TNKCarRouteSearchRoutePlan *currentRoute;

@property (nonatomic, strong) TLSDriverOrder *order;

@property (nonatomic, strong) TNKCarNaviManager *naviManager;

@property (nonatomic, strong) TNKCarNaviView *naviView;

@property (nonatomic, strong) QPointAnnotation *destAnnotation;

@property (nonatomic, strong) TrafficPolyline *trafficLine;

@property (nonatomic, assign) NSTimeInterval lastLocationTimestamp;

@property (nonatomic, strong) TencentLBSLocationManager *locationManager;

@property (nonatomic, copy) NSString *cityCode;

@property (nonatomic, strong) NavigationBottomBoard *bottomBoard;
@property (nonatomic, strong) NavigationSpeedInfo *speedInfo;
@property (nonatomic, strong) NavigationStatusBar *statusBar;

@end

@implementation DriverSynchroViewController

#pragma mark - Setup

- (void)setupSynchro
{
    TLSDriverConfigPreference *config = [[TLSDriverConfigPreference alloc] init];
    
    config.key = kSynchroKey;
    config.accountID = kSynchroDriverAccountID;
    
    self.fetchSwitch = NO;
    
    self.synchro = [[TLSLocusSynchro alloc] initWithConfigPreference:config];
    
    self.synchro.syncEnabled = self.fetchSwitch;
    self.synchro.delegate = self;
    self.synchro.dataSource = self;
    
    [self.synchro start];
}

- (void)setupOrder
{
    self.order = [[TLSDriverOrder alloc] init];
    self.order.orderID = kSynchroOrderID;
    self.order.orderStatus = 3;
    self.order.status = TLSSynchroDriverStatusServing;
}

- (void)setupNaviManager
{
    self.naviManager = [[TNKCarNaviManager alloc] init];
    
    [self.naviManager registerNaviDelegate:self];
    [self.naviManager registerUIDelegate:self];
}

- (void)setupNaviView
{
    self.naviView = [[TNKCarNaviView alloc] initWithFrame:self.view.bounds];
    self.naviView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.naviView.delegate = self;
    self.naviView.dataSource = self;
    
    self.naviView.externalEdgeInsets = UIEdgeInsetsMake(80, 40, 120, 40);
    self.naviView.dayNightMode = TNKCarNaviDayNightModeAlwaysDay;
    self.naviView.naviMapView.delegate = self;
    self.naviView.naviMapView.showsTraffic = NO;
    self.naviView.naviMapView.showsUserLocation = YES;
    
    [self.view addSubview:self.naviView];
    
    [self.naviManager registerUIDelegate:self.naviView];
}

- (void)setupToolbar
{
    UIBarButtonItem *flexble = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    self.startNavi    = [[UIBarButtonItem alloc] initWithTitle:@"开始导航" style:UIBarButtonItemStyleDone target:self action:@selector(handleStartNavi:)];
    self.stopNavi     = [[UIBarButtonItem alloc] initWithTitle:@"结束导航" style:UIBarButtonItemStyleDone target:self action:@selector(handleStopNavi:)];
    self.synchroFetchSwitch  = [[UIBarButtonItem alloc] initWithTitle:@"拉取:关" style:UIBarButtonItemStyleDone target:self action:@selector(handleFetchAction:)];
    
    self.toolbarItems = @[flexble, self.startNavi,
                          flexble, self.stopNavi,
                          flexble, self.synchroFetchSwitch,
                          flexble];
}

- (void)setupBottomBar {
    
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height - 130;
  
    CGFloat bottomBoardHeight = 46;
    CGFloat margin = 5;
    
    self.bottomBoard = [[NavigationBottomBoard alloc] initWithFrame:CGRectMake(margin, height - bottomBoardHeight - kHomeIndicatorHeight - kTrafficStatusBarHeight, width - 2 * margin, bottomBoardHeight)];
    self.bottomBoard.nightMode = self.naviView.dayNightStatus;
    [self.view addSubview:self.bottomBoard];
    
    CGFloat speedInfoHeight = 46;
    CGFloat speedInfoWidth = width/3 * 2;
    
    self.speedInfo = [[NavigationSpeedInfo alloc] initWithFrame:CGRectMake(width/6, CGRectGetMinY(self.bottomBoard.frame) - margin - speedInfoHeight, speedInfoWidth, speedInfoHeight)];
    [self.view addSubview:self.speedInfo];
    
    CGRect trafficBarFrame;
    if(KISIphoneX)
    {
        trafficBarFrame = CGRectMake(margin, CGRectGetMaxY(self.bottomBoard.frame), width - 2 * margin, kTrafficStatusBarHeight);
    }
    else
    {
        trafficBarFrame = CGRectMake(0, CGRectGetMaxY(self.bottomBoard.frame), width, kTrafficStatusBarHeight);
    }
    self.statusBar = [[NavigationStatusBar alloc] initWithFrame:trafficBarFrame];
    self.statusBar.orientation = NavigationStatusBarDisplayOrientationLeftToRight;
    
    [self.view addSubview:self.statusBar];
}

- (void)setDashboardHidden:(BOOL)hidden {
    
    self.statusBar.hidden = hidden;
    self.speedInfo.hidden = hidden;
    self.bottomBoard.hidden = hidden;
}

- (void)setupGestures
{
    self.longPressGestureGecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    self.longPressGestureGecognizer.delegate = self;
    self.longPressGestureGecognizer.minimumPressDuration = 1;
    
    [self.view addGestureRecognizer:self.longPressGestureGecognizer];
}

#pragma mark - lbs location

- (void)configLocationManager
{
    self.locationManager = [[TencentLBSLocationManager alloc] init];
    
    [self.locationManager setDelegate:self];
    
    [self.locationManager setApiKey:kSynchroKey];
    
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
        
        
    }
}


- (void)tencentLBSLocationManager:(TencentLBSLocationManager *)manager
                didUpdateLocation:(TencentLBSLocation *)location {
    //定位结果
    NSLog(@"location:%@", location.location);
    
    self.cityCode = location.code;
    
    if(self.naviStatus != NaviStatusStarted)
    {
        NSTimeInterval timestamp = [location.location.timestamp timeIntervalSince1970];
        
        if(timestamp == self.lastLocationTimestamp)
        {
            return;
        }
        
        TLSLocation *location = [[TLSLocation alloc] init];
        location.location = location.location;
        location.cityCode = self.cityCode;
        
        [self.synchro updateLocation:location];
        
        self.lastLocationTimestamp = timestamp;
    }
}

- (void)updateBottomBoardInfo:(TNKCarNavigationData *)data
{
    [self.bottomBoard updateInfoLabelWithTotalDistanceLeft:data.totalDistanceLeftString distanceUnit:data.totalDistanceLeftUnit totalTimeLeft:[NSString stringWithFormat:@"%d",data.totalTimeLeft]];
}

- (void)updateSpeedInfo:(TNKCarNavigationData *)data
{
    [self.speedInfo updateCurrentSpeed:data.currentSpeed
                            limitSpeed:data.limitSpeed
                       currentRoadName:data.currentRoadName];
}

- (void)updateStatusBarInfo:(TNKCarNavigationData *)data
{
    [self.statusBar updateRemainingDistance:data.totalDistanceLeft];
}


#pragma mark - Navi Delegate

// 同步路线统一在这里进行.
- (void)carNavigationManager:(TNKCarNaviManager *)manager updateRouteTrafficStatus:(TNKRouteTrafficStatus *)status
{
    TLSRoute *route = [self prepareRouteWithRoutePlan:self.currentRoute];
    
    route.routeTraffic = [self prepareRouteTrafficData:status];
    
    self.order.routeID = self.currentRoute.routeID;
    
    [self.synchro updateRoute:route];
    
    [self.statusBar updateStatusBar:status];
}

- (void)carNaviView:(TNKCarNaviView *)carNaviView didChangeDayNightStatus:(TNKCarNaviDayNightStatus)status {
    self.bottomBoard.nightMode = status;
}

- (void)carNavigationManager:(TNKCarNaviManager *)manager updateNavigationData:(TNKCarNavigationData *)data
{
    self.order.leftDistance = data.totalDistanceLeft;
    self.order.leftTime = data.totalTimeLeft;
    
    [self updateBottomBoardInfo:data];
    [self updateSpeedInfo:data];
    [self updateStatusBarInfo:data];
}

- (void)carNavigationManager:(TNKCarNaviManager *)manager didUpdateLocation:(TNKLocation *)location
{
    if(self.naviStatus == NaviStatusStarted)
    {
        TLSLocation *uploadLocation = [[TLSLocation alloc] init];
        
        uploadLocation.location          = location.location;
        uploadLocation.matchedCoordinate = location.matchedCoordinate;
        uploadLocation.matchedCourse     = location.matchedCourse;
        uploadLocation.matchedIndex      = location.matchedIndex;
        uploadLocation.extraInfo         = @"test";
        // 需要传坐标所在城市的编码
        uploadLocation.cityCode = self.cityCode;
        //NSLog(@"location %@ matched course %f index %ld",uploadLocation,location.matchedCourse,(long)location.matchedIndex);
        
        [self.synchro updateLocation:uploadLocation];
    }
}

- (void)carNavigationManager:(TNKCarNaviManager *)manager
   didSuccessRecaculateRoute:(TNKCarNaviManagerRecaculateType)type
                      result:(nonnull TNKCarRouteSearchResult *)result
{
    self.currentRoute = result.routes[0];
}

#pragma mark - Map Delegate

- (QAnnotationView *)mapView:(QMapView *)mapView viewForAnnotation:(id<QAnnotation>)annotation
{
    if ([annotation isKindOfClass:[QPointAnnotation class]])
    {
        static NSString *pointReuseIndetifier = @"pointReuseIndetifier";
        QPinAnnotationView *annotationView = (QPinAnnotationView *)[self.naviView.naviMapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndetifier];
        
        if (annotationView == nil)
        {
            annotationView = [[QPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndetifier];
        }
        
        annotationView.canShowCallout   = NO;
        annotationView.pinColor = QPinAnnotationColorRed;
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
        polylineRender.segmentStyle = tl.arrLine;
        polylineRender.borderColor = [UIColor colorWithRed:0 green:0.8 blue:0 alpha:0.15];
        polylineRender.lineWidth   = 10;
        polylineRender.borderWidth = 1;
        polylineRender.strokeColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:.248];
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

#pragma mark - Synchro Delegate

- (void)locusSynchro:(TLSLocusSynchro *)synchro didUpdateSyncData:(TLSSyncData *)data
{
    // 更新乘客位置.
}

- (void)locusSynchroDidUploadRouteSuccess:(TLSLocusSynchro *)synchro
{
    //NSLog(@"%s",__FUNCTION__);
}

- (void)locusSynchro:(TLSLocusSynchro *)synchro didUploadRouteFailWithError:(TLSError *)error
{
    //NSLog(@"%s",__FUNCTION__);
}

- (void)locusSynchroDidUploadLocationSuccess:(TLSLocusSynchro *)synchro
{
    //NSLog(@"%s",__FUNCTION__);
}

- (void)locusSynchro:(TLSLocusSynchro *)synchro didUploadLocationFailWithError:(TLSError *)error
{
    //NSLog(@"%s",__FUNCTION__);
}

#pragma mark - Synchro DataSource

- (TLSOrder *)orderForLocusSynchro:(TLSLocusSynchro *)synchro
{
    return self.order;
}

#pragma mark - Tools

- (void)addDestAnnotation:(CLLocationCoordinate2D)coordinate
{
    [self.naviView.naviMapView removeAnnotation:self.destAnnotation];
    [self.naviView.naviMapView removeOverlay:self.trafficLine];
    
    self.destAnnotation = [[QPointAnnotation alloc] init];
    self.destAnnotation.coordinate = coordinate;
    
    [self.naviView.naviMapView addAnnotation:self.destAnnotation];
}

- (TrafficPolyline *)polylineForNaviResult:(TNKCarRouteSearchResult *)result
{
    if (result.routes.count == 0)
    {
        NSLog(@"route.count = 0");
        return nil;
    }
    
    TNKCarRouteSearchRoutePlan *plan = result.routes[0];
    TNKCarRouteSearchRouteLine *line = plan.line;
    NSArray<TNKCarRouteSearchRouteSegmentStyle*> *steps = line.segmentStyles;
    int count = (int)line.coordinatePoints.count;
    CLLocationCoordinate2D *coordinateArray = (CLLocationCoordinate2D*)malloc(sizeof(CLLocationCoordinate2D)*count);
    for (int i = 0; i < count; ++i)
    {
        coordinateArray[i] = [(TNKCoordinatePoint*)[line.coordinatePoints objectAtIndex:i] coordinate];
    }
    
    NSMutableArray* routeLineArray = [NSMutableArray array];
    for (TNKCarRouteSearchRouteSegmentStyle *seg in steps) {
        QSegmentStyle *subLine = [[QSegmentStyle alloc] init];
        subLine.startIndex = (int)seg.startNum;
        subLine.endIndex   = (int)seg.endNum;
        subLine.colorImageIndex = [self transformColorIndex:seg.colorIndex];
        [routeLineArray addObject:subLine];
    }
    
    // 创建路线,一条路线由一个点数组和线段数组组成
    TrafficPolyline *routeOverlay = [[TrafficPolyline alloc] initWithCoordinates:coordinateArray count:count arrLine:routeLineArray];
    
    free(coordinateArray);
    
    return routeOverlay;
}

- (int)transformColorIndex:(NSUInteger)index
{
    switch (index)
    {
        case 0:
            return 4;
        case 1:
            return 3;
        case 2:
            return 2;
        case 3:
            return 1;
        case 4:
            return 9;
        default:
            return 1;
    }
}

- (void)searchFrom:(RouteLocation *)from to:(RouteLocation *)to
{
    TNKSearchNaviPoi *start = [[TNKSearchNaviPoi alloc] init];
    start.coordinate = from.coordinate;
    
    TNKSearchNaviPoi *dest = [[TNKSearchNaviPoi alloc] init];
    dest.coordinate = to.coordinate;
    
    TNKCarRouteSearchOption *option = [[TNKCarRouteSearchOption alloc] init];
    option.avoidTrafficJam = YES;
    
    TNKCarRouteSearchRequest *request = [[TNKCarRouteSearchRequest alloc] init];
    request.startPoint = start;
    request.destinationPoint = dest;
    request.searchOption = option;
    
    __weak __typeof(self) weakSelf = self;
    
    [self.naviManager  searchNavigationRoutesWithRequest:request completion:^(TNKCarRouteSearchResult *result, NSError *error) {
        
        [weakSelf enterIntoStatus:NaviStatusReady];
        
        weakSelf.trafficLine = [weakSelf polylineForNaviResult:result];
        
        [weakSelf.naviView.naviMapView addOverlay:weakSelf.trafficLine];
        
        weakSelf.currentRoute = result.routes[0];
    }];
}

- (TLSRoute *)prepareRouteWithRoutePlan:(TNKCarRouteSearchRoutePlan *)plan
{
    if(plan == nil)
    {
        return nil;
    }
    
    TLSRoute *route = [[TLSRoute alloc] init];
    
    route.routeID = plan.routeID;
    
    NSMutableArray *points = [NSMutableArray new];
    
    for(int i=0;i<plan.line.coordinatePoints.count;++i)
    {
        RouteLocation *point = [[RouteLocation alloc] init];
        point.coordinate = plan.line.coordinatePoints[i].coordinate;
        
        [points addObject:point];
    }
    
    route.routePoints = points;
    
    return route;
}

- (NSArray<TLSRouteTrafficItem *> *)prepareRouteTrafficData:(TNKRouteTrafficStatus *)status
{
    NSMutableArray *array = [NSMutableArray new];
    
    for(int i=0;i<status.trafficDataArray.count;++i)
    {
        TNKRouteTrafficData *data = status.trafficDataArray[i];
        
        if(data.from < 0)
        {
            continue;
        }
        
        TLSRouteTrafficItem *item = [[TLSRouteTrafficItem alloc] init];
        
        item.from  = data.from;
        item.to    = data.to;
        item.color = data.color;
        
        [array addObject:item];
    }
    
    return array;
}

#pragma mark - Navi Status

- (void)enterIntoStatus:(NaviStatus)status
{
    // 更新数据.
    self.naviStatus = status;
    
    // 更新UI.
    [self updateUIWithStatus:self.naviStatus];
}

- (void)updateUIWithStatus:(NaviStatus)status
{
    switch (status)
    {
            // 未知态.
        case NaviStatusNone:
        {
            self.startNavi.enabled = NO;
            self.stopNavi.enabled = NO;
            
            [self.naviView.naviMapView setShowsUserLocation:YES];
            
            break;
        }
            // 准备完成.
        case NaviStatusReady:
        {
            self.startNavi.enabled = YES;
            self.stopNavi.enabled = NO;
            
            [self.naviView clearAllRouteUI];
            
            break;
        }
            // 导航已经启动.
        case NaviStatusStarted:
        {
            self.startNavi.enabled = NO;
            self.stopNavi.enabled = YES;
            
            [self.naviView.naviMapView removeAnnotation:self.destAnnotation];
            [self.naviView.naviMapView removeOverlay:self.trafficLine];
            [self.naviView.naviMapView setShowsUserLocation:NO];
            
            break;
        }
            // 导航已经结束.
        case NaviStatusStoped:
        {
            self.startNavi.enabled = YES;
            self.stopNavi.enabled = NO;
            
            break;
        }
            
        default:
        {
            break;
        }
    }
}

#pragma mark - Actions

- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture
{
    if (gesture.state != UIGestureRecognizerStateBegan)
    {
        return;
    }
    
    if (self.naviStatus == NaviStatusStarted)
    {
        return;
    }
    
    [self enterIntoStatus:NaviStatusNone];
    
    CGPoint location  = [gesture locationInView:self.naviView.naviMapView];
    CLLocationCoordinate2D coordinate = [self.naviView.naviMapView convertPoint:location toCoordinateFromView:self.naviView.naviMapView];
    
    [self addDestAnnotation:coordinate];
    
    RouteLocation *from = [[RouteLocation alloc] init];
    from.coordinate = self.naviView.naviMapView.userLocation.location.coordinate;
    
    RouteLocation *to = [[RouteLocation alloc] init];
    to.coordinate = self.destAnnotation.coordinate;
    
    [self searchFrom:from to:to];
}

- (void)handleStartNavi:(UIBarButtonItem *)sender
{
    self.naviView.mode = TNKCarNaviUIMode3DCarTowardsUp;
    self.naviView.hideNavigationPanel = NO;
    
    [self.naviManager startSimulateWithIndex:0 locationEntry:nil];
    
    [self enterIntoStatus:NaviStatusStarted];
    
    [self setDashboardHidden:NO];
}

- (void)handleStopNavi:(UIBarButtonItem *)sender
{
    self.naviView.mode = TNKCarNaviUIModeOverview;
    self.naviView.hideNavigationPanel = YES;
    
    [self.naviManager stop];
    
    [self enterIntoStatus:NaviStatusStoped];
    
    [self setDashboardHidden:YES];
}

- (void)handleFetchAction:(UIBarButtonItem *)sender
{
    self.fetchSwitch = !self.fetchSwitch;
    
    self.synchro.syncEnabled = self.fetchSwitch;
    
    if(self.fetchSwitch)
    {
        self.synchroFetchSwitch.title = @"拉取:开";
    }
    else
    {
        self.synchroFetchSwitch.title = @"拉取:关";
    }
}

#pragma mark - Life Circle

- (void)dealloc {
    [self stopSerialLocation];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupToolbar];
    
    [self setupOrder];
    
    [self setupSynchro];
    
    [self setupNaviManager];
    
    [self setupNaviView];
    
    [self setupGestures];
    
    [self setupBottomBar];
    [self setDashboardHidden:YES];
    
    // 定位SDK
    [self configLocationManager];
    [self startSerialLocation];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setToolbarHidden:NO animated:animated];
    
    [self enterIntoStatus:NaviStatusNone];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
