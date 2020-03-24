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

@end

@implementation KCDriverSynchroViewController

- (void)dealloc {
    
    [self.carNaviManager stop];
    [self.driverManager stop];
    [self stopSerialLocation];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 初始化地图
    self.carNaviView = [[TNKCarNaviView alloc] initWithFrame:self.view.bounds];
    self.carNaviView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.carNaviView];
    self.carNaviView.delegate = self;
    self.carNaviView.showUIElements = YES;
    self.carNaviView.naviMapView.delegate = self;
    
    // 初始化导航管理器
    self.carNaviManager = [[TNKCarNaviManager alloc] init];
    [self.carNaviManager registerNaviDelegate:self];
    [self.carNaviManager registerUIDelegate:self.carNaviView];
    
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
    
    // 启动定位SDK
    [self configLocationManager];
    
    // 导航起终点
    TNKSearchNaviPoi *startPOI = [[TNKSearchNaviPoi alloc] init];
    startPOI.coordinate = kSynchroDriverStart;
    TNKSearchNaviPoi *endPOI = [[TNKSearchNaviPoi alloc] init];
    endPOI.coordinate = kSynchroDriverEnd;
   
    [self searchRouteAndStartNaviWithStart:startPOI end:endPOI wayPoints:@[]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

#pragma mark - actions

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
        // 开始导航
        strongself.isNavigating = YES;
        [strongself.carNaviManager startSimulateWithIndex:0 locationEntry:nil];
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
    
    if (!self.isNavigating) {
        // 听单中上报定位点
        TLSDDriverPosition *myPosition = [[TLSDDriverPosition alloc] init];
        myPosition.location = location.location;
        myPosition.cityCode = location.code;
        [self.driverManager uploadPosition:myPosition];
    }
}


#pragma mark - TNKCarNaviDelegate
- (void)carNavigationManager:(TNKCarNaviManager *)manager didUpdateLocation:(TNKLocation *)location {
    
}

#pragma mark - TNKCarNaviViewDelegate
- (void)carNaviViewCloseButtonClicked:(TNKCarNaviView *)carNaviView {
    [self.carNaviManager stop];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - TLSDriverManagerDelegate
- (void)tlsDriverManager:(TLSDriverManager *)driverManager didFetchData:(TLSDFetchedData *)fetchedData {
    
    if (fetchedData.positions.count > 0) {
        // 有定位点
        CLLocation *passengerLocation = fetchedData.positions.lastObject.location;
        if (self.passengerAnnotation) {
            [self.carNaviView.naviMapView removeAnnotation:self.passengerAnnotation];
        }
        self.passengerAnnotation = [[QPointAnnotation alloc] init];
        self.passengerAnnotation.title = @"passengerAnnotation";
        self.passengerAnnotation.coordinate = passengerLocation.coordinate;
        [self.carNaviView.naviMapView addAnnotation:self.passengerAnnotation];
    }else {
        // 没有定位点了
    }
}

#pragma mark - QMapViewDelegate
- (QAnnotationView *)mapView:(QMapView *)mapView viewForAnnotation:(id<QAnnotation>)annotation {
    
    if ([annotation.title isEqualToString:@"passengerAnnotation"]) {
        
        QAnnotationView *passengerAnnotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"passengerAnnotation"];
        if (!passengerAnnotationView) {
            passengerAnnotationView = [[QAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"passengerAnnotation"];
            UIImage *image = [UIImage imageNamed:@"passenger_location"];
            passengerAnnotationView.image = image;
            double height = image.size.height * image.scale / [UIScreen mainScreen].scale / 2.0;
            passengerAnnotationView.centerOffset = CGPointMake(0, -height);
        }
        
        return passengerAnnotationView;
    }
    return nil;
}

@end
