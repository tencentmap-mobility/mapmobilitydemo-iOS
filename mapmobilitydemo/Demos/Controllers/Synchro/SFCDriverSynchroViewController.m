//
//  DriverSynchroViewController.m
//  TencentMapLocusSynchroDemo
//
//  Created by Yuchen Wang on 2020/3/9.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "SFCDriverSynchroViewController.h"
#import <TNKNavigationKit/TNKNavigationKit.h>
#import <TencentMapLocusSynchroDriverSDK/TencentMapLocusSynchroDriverSDK.h>
#import "Constants.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import <TencentLBS/TencentLBS.h>

@interface SFCDriverSynchroViewController ()<TNKCarNaviViewDelegate, TNKCarNaviDelegate, TLSDriverManagerDelegate, TencentLBSLocationManagerDelegate>

// 驾车导航
@property (nonatomic, strong) TNKCarNaviManager *carNaviManager;
@property (nonatomic, strong) TNKCarNaviView *carNaviView;

// 司乘同学司机管理类
@property (nonatomic, strong) TLSDriverManager *driverManager;

@property (nonatomic, strong) UIButton *waypoint1GetInButton;
@property (nonatomic, strong) UIButton *waypoint1GetOffButton;

// 当前坐标
@property (nonatomic, assign) CLLocationCoordinate2D currentCoord;

@property (nonatomic, strong) TencentLBSLocationManager *locationManager;
@property (nonatomic, assign) NSTimeInterval lastLocationTimestamp;

@end

@implementation SFCDriverSynchroViewController

- (void)dealloc {
    [self.driverManager stop];
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
    
    // 初始化导航管理器
    self.carNaviManager = [[TNKCarNaviManager alloc] init];
    [self.carNaviManager registerNaviDelegate:self];
    [self.carNaviManager registerUIDelegate:self.carNaviView];
    
    // 初始化司乘同显
    TLSDConfig *dConfig = [[TLSDConfig alloc] init];
    dConfig.driverID = kSynchroDriverID;
    dConfig.key = kSynchroKey;
    
    self.driverManager = [[TLSDriverManager alloc] initWithConfig:dConfig];
    self.driverManager.delegate = self;
    self.driverManager.carNaviView = self.carNaviView;
    self.driverManager.carNaviManger = self.carNaviManager;
    self.driverManager.orderID = kSynchroDriverOrderID;
    self.driverManager.orderType = TLSBOrderTypeHitchRide;
    self.driverManager.orderStatus = TLSBOrderStatusTrip;
    self.driverManager.driverStatus = TLSDDriverStatusServing;
    [self.driverManager start];
    
    // 开启定位SDK
    [self configLocationManager];
    
    // 导航起终点
    TNKSearchNaviPoi *startPOI = [[TNKSearchNaviPoi alloc] init];
    startPOI.coordinate = kSynchroDriverStart;
    TNKSearchNaviPoi *endPOI = [[TNKSearchNaviPoi alloc] init];
    endPOI.coordinate = kSynchroDriverEnd;
    
    // 订单信息
    TLSDSortRequestWayPoint *order1WayPoint = [[TLSDSortRequestWayPoint alloc] init];
    order1WayPoint.pOrderID = kSynchroPassenger1OrderID;
    order1WayPoint.startPoint = kSynchroPassenger1Start;
    order1WayPoint.endPoint = kSynchroPassenger1End;

    TLSDSortRequestWayPoint *order2WayPoint = [[TLSDSortRequestWayPoint alloc] init];
    order2WayPoint.pOrderID = kSynchroPassenger2OrderID;
    order2WayPoint.startPoint = kSynchroPassenger2Start;
    order2WayPoint.endPoint = kSynchroPassenger2End;
  
    NSString *orderIDKey = @"orderID";
    NSString *wayPointTypeKey = @"wayPointType";
    NSString *imageKey = @"image";
    
    NSArray *waypointConfigs = @[@{orderIDKey : kSynchroPassenger1OrderID, wayPointTypeKey : @(1), imageKey : [UIImage imageNamed:@"waypoint1-1"]},
                                 @{orderIDKey : kSynchroPassenger1OrderID, wayPointTypeKey : @(2), imageKey : [UIImage imageNamed:@"waypoint1-2"]},
                                 @{orderIDKey : kSynchroPassenger2OrderID, wayPointTypeKey : @(1), imageKey : [UIImage imageNamed:@"waypoint2-1"]},
                                 @{orderIDKey : kSynchroPassenger2OrderID, wayPointTypeKey : @(2), imageKey : [UIImage imageNamed:@"waypoint2-2"]},
    ];
    
    __weak typeof(self) weakself = self;

    [SVProgressHUD showWithStatus:@"请求接送驾最优顺序"];
    
    // 最优送驾顺序匹配
    [self.driverManager requestBestSortedWayPointsWithStartPoint:startPOI.coordinate endPoint:endPOI.coordinate wayPoints:@[order1WayPoint, order2WayPoint] completion:^(NSArray<TLSDWayPointInfo *> * _Nullable sortedWayPoints, NSError * _Nullable error) {
       
        __strong SFCDriverSynchroViewController *strongself = weakself;
        if (!strongself) {
           return ;
        }
        [SVProgressHUD dismiss];
        
        if (error) {
            NSLog(@"requestBestSortedWayPointsWithStartPoint_error = %@", error);
            [SVProgressHUD showErrorWithStatus:error.description];
            return;
        }

        for (TLSDWayPointInfo *wayPointInfo in sortedWayPoints) {
            NSDictionary *wayPointConfig = [waypointConfigs filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(orderID == %@) AND (wayPointType == %@)", wayPointInfo.pOrderID, @(wayPointInfo.wayPointType)]].firstObject;
            if (wayPointConfig) {
                // 找到途经点的图片
                UIImage *image = wayPointConfig[imageKey];
                wayPointInfo.image = image;
            }
        }
        [strongself searchRouteAndStartNaviWithStart:startPOI end:endPOI wayPoints:sortedWayPoints];
    }];

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
       
        __strong SFCDriverSynchroViewController *strongself = weakself;
        if (!strongself) {
            return ;
        }
        
        if (error) {
            // 处理错误
            return;
        }
        
        [strongself.driverManager uploadRouteWithIndex:0];
        // 开启导航
        [strongself.carNaviManager startSimulateWithIndex:0 locationEntry:nil];
    }];
}

- (void)setupButtons {
    
    CGSize btnSize = CGSizeMake(90, 30);
    CGFloat x = 20;
    CGFloat y = self.view.bounds.size.height - btnSize.height;
    
    self.waypoint1GetInButton = [[UIButton alloc] initWithFrame:CGRectMake(x, y, btnSize.width, btnSize.height)];
    self.waypoint1GetInButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.waypoint1GetInButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.waypoint1GetInButton setTitle:@"接驾到乘客1" forState:UIControlStateNormal];
    self.waypoint1GetInButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.waypoint1GetInButton addTarget:self action:@selector(waypoint1GetInButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.waypoint1GetInButton];
    
    x += CGRectGetMaxX(self.waypoint1GetInButton.frame) + 20;
    
    self.waypoint1GetOffButton = [[UIButton alloc] initWithFrame:CGRectMake(x, y, btnSize.width, btnSize.height)];
    self.waypoint1GetOffButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.waypoint1GetOffButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.waypoint1GetOffButton setTitle:@"送驾到乘客1" forState:UIControlStateNormal];
    self.waypoint1GetOffButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.waypoint1GetOffButton addTarget:self action:@selector(waypoint1GetOffButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.waypoint1GetOffButton];
}

- (void)waypoint1GetInButtonClicked {

    [self.driverManager arrivedPassengerStartPoint:@"1"];
}

- (void)waypoint1GetOffButtonClicked {
    [self.driverManager arrivedPassengerEndPoint:@"1"];
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
}


#pragma mark - TNKCarNaviDelegate
- (void)carNavigationManager:(TNKCarNaviManager *)manager didUpdateLocation:(TNKLocation *)location {
    
    // 记录导航的当前位置
    if (location.matchedIndex >= 0) {
        // 吸附到道路上了
        self.currentCoord = location.matchedCoordinate;
    }else {
        // 吸附失败
        self.currentCoord = location.location.coordinate;
    }
}

#pragma mark - TNKCarNaviViewDelegate
- (void)carNaviViewCloseButtonClicked:(TNKCarNaviView *)carNaviView {
    [self.carNaviManager stop];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - TLSDriverManagerDelegate
- (void)tlsDriverManager:(TLSDriverManager *)driverManager didRemoveWayPointInfo:(TLSDWayPointInfo *)removedWayPointInfo {
    
    TNKSearchNaviPoi *startPOI = [[TNKSearchNaviPoi alloc] init];
    startPOI.coordinate = self.currentCoord;

    // 重新路线规划
    __weak typeof(self) weakself = self;
    [driverManager searchCarRoutesWithStart:startPOI end:driverManager.endPOI wayPoints:driverManager.remainingWayPointInfoArray option:driverManager.searchOption completion:^(TNKCarRouteSearchResult * _Nonnull result, NSError * _Nullable error) {
       
        __strong SFCDriverSynchroViewController *strongself = weakself;
        if (!strongself) {
            return ;
        }
        
        if (error) {
            // 处理错误
            return;
        }
    
        if (![strongself.carNaviManager isStoped]) {
            [strongself.carNaviManager stop];
        }
        
        [strongself.driverManager uploadRouteWithIndex:0];
        [strongself.carNaviManager startSimulateWithIndex:0 locationEntry:nil];
    }];
}

- (void)tlsDriverManager:(TLSDriverManager *)driverManager didFetchData:(TLSDFetchedData *)fetchedData {
    
}
@end
