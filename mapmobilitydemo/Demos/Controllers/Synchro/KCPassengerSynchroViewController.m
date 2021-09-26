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
#import "RouteLocation.h"
#import "Constants.h"
#import "CarBubbleAnnotationView.h"
#import <TencentLBS/TencentLBS.h>
#import "KCChooseRouteViewController.h"
#import "TLSRoutePolyline.h"
#import "MathTool.h"
#import "KCOrderManager.h"
#import "KCPassengerModule.h"
#import "SVProgressHUD.h"

@interface KCPassengerSynchroViewController () <
QMapViewDelegate,
TencentLBSLocationManagerDelegate,
KCChooseRouteDelegate>

// 地图
@property (nonatomic, strong) QMapView *mapView;
// 定位管理对象
@property (nonatomic, strong) TencentLBSLocationManager *locationManager;

// 恢复视野按钮
@property (nonatomic, strong) UIBarButtonItem *restoreVisableRectButtonItem;

// 上次定位更新的时间戳
@property (nonatomic, assign) NSTimeInterval lastLocationTimestamp;

// 自动视野还是乘客拖动了视野
@property (nonatomic, assign) BOOL autoVisibleMapRect;

@property (nonatomic, strong) KCMyOrder *order;

// 乘客端管理模块
@property (nonatomic, strong) KCPassengerModule *passengerModule;

@end

@implementation KCPassengerSynchroViewController

#pragma mark - life cycle


- (void)viewDidLoad {
    [super viewDidLoad];
        
    KCMyOrder *order = [[KCMyOrder alloc] init];
    order.driverID = kSynchroKCDriverAccountID;
    order.adCode = @"110000";
    order.orderID = kSynchroKCOrder1ID;
    order.passengerID = kSynchroKCPassenger1AccountID;
    order.orderStatus = TLSBOrderStatusTrip;
    
    MyPOI *startPOI = [[MyPOI alloc] init];
    startPOI.coord = kSynchroKCPassenger2Start;
    startPOI.poiName = @"中国化工大厦-西门";
    order.startPOI = startPOI;
    
    // 送驾点
    MyPOI *endPOI = [[MyPOI alloc] init];
    endPOI.coord = kSynchroKCPassenger2End;
    endPOI.poiName = @"仓上小区[公交站]";
    order.endPOI = endPOI;
    
    self.order = order;
    
    [self setupToolbar];
    
    // 设置地图
    [self setupMap];
        
    [self setupPassengerModule];
    
    // 开启定位服务
    [self configLocationManager];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setToolbarHidden:NO animated:animated];
}

- (void)dealloc {
    [self stopSerialLocation];
    [self.passengerModule stop];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark - private

- (void)setupMap {
    
    self.autoVisibleMapRect = YES;
    
    self.mapView = [[QMapView alloc] initWithFrame:self.view.bounds];
    
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    self.mapView.rotateEnabled = NO;
    self.mapView.overlookingEnabled = NO;
    
    [self.view addSubview:self.mapView];
}

- (void)setupPassengerModule {
    self.passengerModule = [[KCPassengerModule alloc] initWithOrder:self.order];
    self.passengerModule.mapView = self.mapView;
    
}

- (void)setupToolbar {
    
    UIBarButtonItem *flexble = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *fetchButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"启动" style:UIBarButtonItemStyleDone target:self action:@selector(handleStartFetch:)];
    UIBarButtonItem *uploadLocationButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"上报定位" style:UIBarButtonItemStyleDone target:self action:@selector(handleStopFetch:)];
    
    UIBarButtonItem *chooseRouteItem = [[UIBarButtonItem alloc] initWithTitle:@"送驾选路" style:UIBarButtonItemStyleDone target:self action:@selector(chooseRoute:)];
    
    UIBarButtonItem *changeDestinationItem = [[UIBarButtonItem alloc] initWithTitle:@"改目的地" style:UIBarButtonItemStyleDone target:self action:@selector(changeDestination:)];
    
    
    self.toolbarItems = @[flexble,
                          fetchButtonItem,
                          flexble,
                          uploadLocationButtonItem,
                          flexble,
                          chooseRouteItem,
                          flexble,
                          changeDestinationItem,
                          flexble
    ];
    
    self.restoreVisableRectButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"恢复视野" style:UIBarButtonItemStylePlain target:self action:@selector(restoreVisableRect:)];
        
    self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)setAutoVisibleMapRect:(BOOL)autoVisiableRect {
    
    _autoVisibleMapRect = autoVisiableRect;
    self.passengerModule.autoVisibleMapRect = autoVisiableRect;
    
    if (autoVisiableRect) {
        // 变为自动调整视野
        self.navigationItem.rightBarButtonItem = nil;
        
    } else {
        // 乘客拖动了地图，不再自动调整视野
        self.navigationItem.rightBarButtonItem = self.restoreVisableRectButtonItem;
    }
}


#pragma mark - location manager
- (void)configLocationManager {
    self.locationManager = [[TencentLBSLocationManager alloc] init];
 
    [self.locationManager setDelegate:self];
 
    // 设置key
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
    //NSLog(@"location:%@", location.location);
//    if (self.lastLocationTimestamp == [location.location.timestamp timeIntervalSince1970]) {
//        // 时间戳相同，过滤
//        return;
//    }
    
    self.lastLocationTimestamp = [location.location.timestamp timeIntervalSince1970];

    TLSBPosition *myPosition = [[TLSBPosition alloc] init];
    myPosition.location = location.location;
    myPosition.cityCode = location.code;
    [self.passengerModule uploadPosition:myPosition];
}




# pragma mark - QMapViewDelegate

- (QOverlayView *)mapView:(QMapView *)mapView viewForOverlay:(id<QOverlay>)overlay {
    if ([overlay isKindOfClass:[TLSRoutePolyline class]])
    {
        TLSRoutePolyline *trafficPolyline = overlay;
        QTexturePolylineView *polylineRender = [[QTexturePolylineView alloc] initWithPolyline:overlay];
        polylineRender.drawType = QTextureLineDrawType_ColorLine;
        polylineRender.segmentColor = trafficPolyline.segmentColors;
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

- (void)mapView:(QMapView *)mapView regionWillChangeAnimated:(BOOL)animated gesture:(BOOL)bGesture {
    
    if (!bGesture) {
        return;
    }
    
    //手势移动, 出现恢复视野按钮
    self.autoVisibleMapRect = NO;
}

# pragma mark - kvo

#pragma mark - KCChooseRouteDelegate
// 取消选路
- (void)kcChooseRouteDidCancel:(KCChooseRouteViewController *)chooseRouteViewController {
    
}

// 确认选路
- (void)kcChooseRouteDidConfirm:(KCChooseRouteViewController *)chooseRouteViewController selectedRoute:(nonnull TLSBRoute *)selectedRoute {
    
    if ([self.passengerModule.curFetchedData.route.routeID isEqualToString:selectedRoute.routeID]) {
        // 选择的就是当前在走的路，不用切换
        return;
    }
    
    BOOL matchedBackupRoutes = NO;
    for (TLSBRoute *route in self.passengerModule.curFetchedData.backupRoutes) {
        if ([route.routeID isEqualToString:selectedRoute.routeID]) {
            matchedBackupRoutes = YES;
            break;
        }
    }
    
    if (!matchedBackupRoutes) {
        // 选中路线已过期，无法切换
        [SVProgressHUD showErrorWithStatus:@"选中路线已过期，无法切换!"];
        NSLog(@"选中路线已过期，无法切换");
        return;
    }
    
    [self.passengerModule.passengerManager chooseRouteWhenTrip:selectedRoute];
    
}




# pragma mark - Action



- (void)handleStartFetch:(UIBarButtonItem *)sender {
    if (self.passengerModule.passengerManager.isRunning) {
        // 关闭
        [self.passengerModule.passengerManager stop];
    }else {
        [self.passengerModule.passengerManager start];
    }
    
    sender.title = self.passengerModule.passengerManager.isRunning ? @"停止" : @"开启";

}

- (void)handleStopFetch:(UIBarButtonItem *)sender {
    self.passengerModule.passengerManager.uploadPassengerPositionsEnabled = !self.passengerModule.passengerManager.uploadPassengerPositionsEnabled;
    sender.title = self.passengerModule.passengerManager.uploadPassengerPositionsEnabled ? @"关闭上报" : @"上报定位";
}

- (void)chooseRoute:(UIBarButtonItem *)sender {
    
    if (self.passengerModule.passengerManager.orderStatus != TLSBOrderStatusTrip) {
        NSLog(@"送驾过程可以使用如下方法，行前选路请看KCPassengerBeforeTripViewController中的代码");
        return;
    }
    if (self.passengerModule.curFetchedData.backupRoutes.count == 0) {
        NSLog(@"没有备选的路线， 不能选路");
        return;
    }
    
    KCChooseRouteViewController *chooseRouteVC = [[KCChooseRouteViewController alloc] initWithFetchedData:self.passengerModule.curFetchedData];
    chooseRouteVC.delegate = self;

    [self.navigationController pushViewController:chooseRouteVC animated:YES];
}

- (void)changeDestination:(UIBarButtonItem *)sender {
    
    if (self.passengerModule.passengerManager.orderStatus != TLSBOrderStatusTrip) {
        NSLog(@"送驾过程才可修改目的地");
        return;
    }
    
    TLSBNaviPOI *point = [[TLSBNaviPOI alloc] init];
    point.coordinate = CLLocationCoordinate2DMake(39.894592, 116.321526);
    
    [self.passengerModule.passengerManager changeDestinationWhenTrip:point];
}


// 恢复视野
- (void)restoreVisableRect:(UIBarButtonItem *)sender {
  
    self.autoVisibleMapRect = YES;
}

@end
