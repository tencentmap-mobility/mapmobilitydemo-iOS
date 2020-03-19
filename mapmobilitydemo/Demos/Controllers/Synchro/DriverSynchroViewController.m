//
//  DriverSynchroViewController.m
//  TLSLocusSynchroDubugging
//
//  Created by 薛程 on 2018/11/27.
//  Copyright © 2018年 tencent. All rights reserved.
//

#import "DriverSynchroViewController.h"
#import <TencentLBS/TencentLBS.h>
#import "Constants.h"
#import <TNKNavigationKit/TNKNavigationKit.h>
#import "AppDelegate.h"
#import "MathTool.h"
#import <TencentMapLocusSynchroDriverSDK/TencentMapLocusSynchroDriverSDK.h>

@interface DriverSynchroViewController ()
<TNKCarNaviDelegate,
TNKCarNaviUIDelegate,
TNKCarNaviViewDelegate,
TNKCarNaviViewDataSource,
QMapViewDelegate,
TencentLBSLocationManagerDelegate,
TLSDriverManagerDelegate
>

@property (nonatomic, strong) TNKCarNaviManager *naviManager;

@property (nonatomic, strong) TNKCarNaviView *naviView;

@property (nonatomic, assign) NSTimeInterval lastLocationTimestamp;

@property (nonatomic, strong) TencentLBSLocationManager *locationManager;

@property (nonatomic, copy) NSString *cityCode;

@property (nonatomic, strong) TLSDriverManager *driverManager;
@end

@implementation DriverSynchroViewController

#pragma mark - Life Circle

- (void)dealloc {
    [self stopSerialLocation];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    [self setupNaviManager];

    [self setupNaviView];
      
    [self setupSynchro];
     
    // 定位SDK
    [self configLocationManager];
    [self startSerialLocation];
    
    // 开启导航
    [self startNavi];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - Setup


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

- (void)setupSynchro
{
    TLSDConfig *config = [[TLSDConfig alloc] init];
    
    config.key = kSynchroKey;
    config.driverID = kSynchroDriverAccountID;
    self.driverManager = [[TLSDriverManager alloc] initWithConfig:config];
    self.driverManager.delegate = self;
    self.driverManager.carNaviManger = self.naviManager;
    self.driverManager.carNaviView = self.naviView;
    
    self.driverManager.orderID = kSynchroOrderID;
    self.driverManager.orderStatus = TLSBOrderStatusTrip;
    self.driverManager.driverStatus = TLSDDriverStatusServing;
    self.driverManager.orderType = TLSBOrderTypeNormal;

    
    [self.driverManager start];
}

- (void)startNavi {
    
    // 导航起终点
    TNKSearchNaviPoi *startPOI = [[TNKSearchNaviPoi alloc] init];
    startPOI.coordinate = CLLocationCoordinate2DMake(39.938962,116.375685);
    TNKSearchNaviPoi *endPOI = [[TNKSearchNaviPoi alloc] init];
    endPOI.coordinate = CLLocationCoordinate2DMake(39.911975,116.351395);
    
    __weak typeof(self) weakself = self;

    [self.driverManager searchCarRoutesWithStart:startPOI end:endPOI wayPoints:nil option:nil completion:^(TNKCarRouteSearchResult * _Nonnull result, NSError * _Nullable error) {
        
        __strong DriverSynchroViewController *strongself = weakself;
        if (!strongself) {
            return ;
        }
        
        if (error) {
            // 处理错误
            return;
        }
        strongself.naviView.showUIElements = YES;
        [strongself.driverManager uploadRouteWithIndex:0];
        [strongself.naviManager startSimulateWithIndex:0 locationEntry:nil];
    }];
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
    
    self.driverManager.cityCode = location.code;
    
    if (self.naviManager.isStoped) {
        NSTimeInterval timestamp = [location.location.timestamp timeIntervalSince1970];

        if(timestamp == self.lastLocationTimestamp)
        {
            return;
        }
        
        TLSDDriverPosition *position = [[TLSDDriverPosition alloc] init];
        position.location = location.location;
        [self.driverManager uploadPosition:position];
    }
}

#pragma mark - Navi Delegate

// 同步路线统一在这里进行.
- (void)carNavigationManager:(TNKCarNaviManager *)manager updateRouteTrafficStatus:(TNKRouteTrafficStatus *)status
{

}

- (void)carNaviView:(TNKCarNaviView *)carNaviView didChangeDayNightStatus:(TNKCarNaviDayNightStatus)status {
}

- (void)carNavigationManager:(TNKCarNaviManager *)manager updateNavigationData:(TNKCarNavigationData *)data
{
 
}

- (void)carNavigationManager:(TNKCarNaviManager *)manager didUpdateLocation:(TNKLocation *)location
{
}

- (void)carNavigationManager:(TNKCarNaviManager *)manager
   didSuccessRecaculateRoute:(TNKCarNaviManagerRecaculateType)type
                      result:(nonnull TNKCarRouteSearchResult *)result
{
}

- (void)carNaviViewCloseButtonClicked:(TNKCarNaviView *)carNaviView {
    
    [self.naviManager stop];
    [self.driverManager stop];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - TLSDriverManagerDelegate
- (void)tlsDriverManager:(TLSDriverManager *)driverManager didRemoveWayPointInfo:(TLSDWayPointInfo *)removedWayPointInfo {
    
}



@end
