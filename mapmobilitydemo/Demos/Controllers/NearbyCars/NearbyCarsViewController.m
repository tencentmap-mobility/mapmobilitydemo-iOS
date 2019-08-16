//
//  NearbyCarsViewController.m
//  TencentMapMobilityDemo
//
//  Created by mol on 2019/8/8.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import "NearbyCarsViewController.h"
#import <TencentLBS/TencentLBS.h>
#import <TencentMapMobilitySDK/TencentMapMobilitySDK.h>
#import <UIKit/UIKit.h>
#import "Constants.h"

@interface NearbyCarsViewController ()<QMapViewDelegate, TencentLBSLocationManagerDelegate>

// 地图视图
@property (nonatomic, strong) QMapView *mapView;
// 定位manager
@property (nonatomic, strong) TencentLBSLocationManager *locationManager;
// 切换车型
@property (nonatomic, strong) UISegmentedControl *segmentControl;
// 是否已经获得首次定位信息，判断是否需要调整地图中心点
@property (nonatomic, assign) BOOL hasGotLocation;
//地图中心的引导点
@property (nonatomic, strong) UIImageView *centerPoint;

@end

@implementation NearbyCarsViewController

#pragma mark - life cycle

- (void)dealloc {
    
    // 关闭定位
    [self.locationManager stopUpdatingLocation];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    // 创建地图
    [self setupMapView];
    // 开启定位服务
    [self setupLocationManager];
    [self startSerialLocation];
    
    // 选择车型控件
    [self setupSelecteVehicleTypesBar];
    
    // 设置周边车辆配置
    [self setupNearbyCar];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    //地图中心引导点
    [self setupDirectPoint];
}

#pragma mark - setup
- (void)setupMapView
{
    self.mapView = [[QMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.autoresizingMask  = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    self.mapView.rotateEnabled = NO;
    self.mapView.zoomLevel = 15;
    self.mapView.overlookingEnabled = NO;
    [self.view addSubview:self.mapView];
}

- (void)setupLocationManager
{
    self.locationManager = [[TencentLBSLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    [self.locationManager setAllowsBackgroundLocationUpdates:YES];
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
}

- (void)setupNearbyCar
{
    self.mapView.nearbyCarsEnabled = YES;

    TMMNearbyCarConfig *nearbyCarConfig = [[TMMNearbyCarConfig alloc] init];
    //mock为1，是模拟数据；0为真实数据，真实数据一定需要设置citycode
    nearbyCarConfig.mock = 1;
    
    nearbyCarConfig.carIconDictionary = @{@(1) : [UIImage imageNamed:@"taxi"], @(2) : [UIImage imageNamed:@"cleanEnergyCar"], @(3) : [UIImage imageNamed:@"comfortCar"], @(4):[UIImage imageNamed:@"luxuryCar"], @(5):[UIImage imageNamed:@"businessCar"], @(6):[UIImage imageNamed:@"economyCar"]};

    // 设置大头针的相对位置(0.5, 0.5)为地图中心点
    CGPoint pinPosition = CGPointMake(0.5, 0.5);
    self.mapView.tmm_pinPosition = pinPosition;
    [self.mapView setCenterOffset:pinPosition];
    
    self.mapView.nearbyCarConfig = nearbyCarConfig;
}

- (void)setupSelecteVehicleTypesBar
{
    NSArray *arr = [[NSArray alloc] initWithObjects:@"全部车型", @"出租车", @"新能源",@"舒适型",@"豪华型", nil];
    self.segmentControl = [[UISegmentedControl alloc] initWithItems:arr];
    self.segmentControl.frame = CGRectMake(0, self.mapView.frame.origin.y, self.view.frame.size.width, 44);
    self.segmentControl.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.segmentControl];
    [self.segmentControl addTarget:self action:@selector(selectVehicleTypes:) forControlEvents:UIControlEventValueChanged];
}

- (void)setupDirectPoint
{
    CGFloat width = 24;
    CGFloat height = 40;
    
    _centerPoint = [[UIImageView alloc] initWithFrame:CGRectMake(self.mapView.frame.size.width/2 - width/2, self.mapView.frame.size.height/2 - height, width, height)];
    [self.mapView addSubview:_centerPoint];
    _centerPoint.image = [UIImage imageNamed:@"marker_green"];
}

#pragma mark - QMapView

-(void)mapView:(QMapView *)mapView regionDidChangeAnimated:(BOOL)animated gesture:(BOOL)bGesture
{
    if(bGesture)
    {
        CGFloat width = 24;
        CGFloat height = 40;
        CGFloat x = self.mapView.frame.size.width/2 - width/2;
        CGFloat y = self.mapView.frame.size.height/2 - height;
        
        __weak typeof(self) weakSelf = self;
        
        __block CGRect startFrame = CGRectMake(x, y - 10, width, height);
        __block CGRect endFrame = CGRectMake(x, y, width, height);
        
        [UIView animateWithDuration:0.5 delay:0.3 options:0 animations:^{
            weakSelf.centerPoint.frame = startFrame;
        } completion:^(BOOL finished) {
            if (finished)
            {
                 weakSelf.centerPoint.frame = endFrame;
            }
        }];
    }
}

#pragma mark - LBSLocationDelegate

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
                didUpdateLocation:(TencentLBSLocation *)location {

    // 获得citycode传入SDK，必须
    self.mapView.tmm_cityCode = location.code;
}

#pragma mark - 周边车辆展示

- (void)selectVehicleTypes:(UISegmentedControl *)control
{
    switch (control.selectedSegmentIndex) {
        case 0:
            self.mapView.nearbyCarConfig.vehicleTypes = @"";
            break;
        case 1:
            self.mapView.nearbyCarConfig.vehicleTypes = @"1";
            break;
        case 2:
            self.mapView.nearbyCarConfig.vehicleTypes = @"2";
            break;
        case 3:
            self.mapView.nearbyCarConfig.vehicleTypes = @"3";
            break;
        case 4:
            self.mapView.nearbyCarConfig.vehicleTypes = @"4";
            break;
        case 5:
            self.mapView.nearbyCarConfig.vehicleTypes = @"5";
            break;
        case 6:
            self.mapView.nearbyCarConfig.vehicleTypes = @"6";
            break;
        default:
            self.mapView.nearbyCarConfig.vehicleTypes = @"";
            break;
    }
    //移除
    [self.mapView removeAllNearbyCars];
    //添加
    [self.mapView getNearbyCars];
}

- (void)mapView:(QMapView *)mapView didUpdateUserLocation:(QUserLocation *)userLocation fromHeading:(BOOL)fromHeading {
    
    // 进入该页面是，将地图中心点移至用户所在位置
    if (!self.hasGotLocation &&
        CLLocationCoordinate2DIsValid(userLocation.location.coordinate) &&
        (userLocation.location.coordinate.latitude != 0 || userLocation.location.coordinate.longitude != 0)) {
        
        [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(self.mapView.userLocation.location.coordinate.latitude, self.mapView.userLocation.location.coordinate.longitude)];
        self.hasGotLocation = YES;
    }
}
@end
