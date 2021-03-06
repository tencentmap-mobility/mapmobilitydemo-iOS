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
#import <TencentMapMobilityNearbyCarsSDK/TMMNearbyCars.h>
#import <TencentMapMobilitySearchSDK/TMMSearch.h>
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

@property (nonatomic, strong) TMMNearbyCarsManager *nearbyCarsManager;

@end

@implementation NearbyCarsViewController

#pragma mark - life cycle

- (void)dealloc {
    
    // 关闭定位
    [self stopSerialLocation];
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
    
    // 显示中心点
    self.mapView.tmm_centerPinViewHidden = NO;
    [self.mapView.tmm_centerPinView setCalloutAttribtedText:[[NSAttributedString alloc] initWithString:@"在这里上车" attributes:@{NSForegroundColorAttributeName : [UIColor blackColor], NSFontAttributeName : [UIFont systemFontOfSize:13]}]];
    self.mapView.tmm_centerPinView.calloutViewHidden = NO;

    // 设置大头针的相对位置(0.5, 0.5)为地图中心点
    CGPoint pinPosition = CGPointMake(0.5, 0.5);
    self.mapView.tmm_pinPosition = pinPosition;
    
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

// 设置周边车辆配置
- (void)setupNearbyCar
{
    TMMNearbyCarConfig *nearbyCarConfig = [[TMMNearbyCarConfig alloc] init];
    // 1.模拟数据；2.真是数据
    nearbyCarConfig.mock = 1;
    
    // 配置不同车型不同的图片资源
    TMMNearbyCarTypeConfig *taxiConfig = [[TMMNearbyCarTypeConfig alloc] init];
    taxiConfig.image = [UIImage imageNamed:@"taxi"];
    
    TMMNearbyCarTypeConfig *cleanEnergyCarConfig = [[TMMNearbyCarTypeConfig alloc] init];
    cleanEnergyCarConfig.image = [UIImage imageNamed:@"cleanEnergyCar"];
    
    TMMNearbyCarTypeConfig *comfortCarConfig = [[TMMNearbyCarTypeConfig alloc] init];
    comfortCarConfig.image = [UIImage imageNamed:@"comfortCar"];
    comfortCarConfig.willRotate = NO;
    
    TMMNearbyCarTypeConfig *luxuryCarConfig = [[TMMNearbyCarTypeConfig alloc] init];
    luxuryCarConfig.image = [UIImage imageNamed:@"luxuryCar"];
    
    TMMNearbyCarTypeConfig *businessCarConfig = [[TMMNearbyCarTypeConfig alloc] init];
    businessCarConfig.image = [UIImage imageNamed:@"businessCar"];
    
    TMMNearbyCarTypeConfig *economyCarConfig = [[TMMNearbyCarTypeConfig alloc] init];
    economyCarConfig.image = [UIImage imageNamed:@"economyCar"];
    
    nearbyCarConfig.carTypeConfigDictionary = @{@(1) : taxiConfig, @(2) : cleanEnergyCarConfig, @(3) : comfortCarConfig, @(4): luxuryCarConfig, @(5):businessCarConfig, @(6):economyCarConfig};
    // 轮询请求周边车辆数据
    nearbyCarConfig.requestRepeatedly = YES;
    
    self.nearbyCarsManager = [[TMMNearbyCarsManager alloc] initWithMapView:self.mapView delagate:nil];
    self.nearbyCarsManager.nearbyCarConfig = nearbyCarConfig;
}

// 选择车型控件
- (void)setupSelecteVehicleTypesBar
{
    NSArray *arr = [[NSArray alloc] initWithObjects:@"全部车型", @"出租车", @"新能源",@"舒适型",@"豪华型", nil];
    self.segmentControl = [[UISegmentedControl alloc] initWithItems:arr];
    self.segmentControl.frame = CGRectMake(0, self.mapView.frame.origin.y, self.view.frame.size.width, 44);
    self.segmentControl.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.segmentControl];
    [self.segmentControl addTarget:self action:@selector(selectVehicleTypes:) forControlEvents:UIControlEventValueChanged];
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
            self.nearbyCarsManager.nearbyCarConfig.vehicleTypes = @"";
            break;
        case 1:
            self.nearbyCarsManager.nearbyCarConfig.vehicleTypes = @"1";
            break;
        case 2:
            self.nearbyCarsManager.nearbyCarConfig.vehicleTypes = @"2";
            break;
        case 3:
            self.nearbyCarsManager.nearbyCarConfig.vehicleTypes = @"3";
            break;
        case 4:
            self.nearbyCarsManager.nearbyCarConfig.vehicleTypes = @"4";
            break;
        case 5:
            self.nearbyCarsManager.nearbyCarConfig.vehicleTypes = @"5";
            break;
        case 6:
            self.nearbyCarsManager.nearbyCarConfig.vehicleTypes = @"6";
            break;
        default:
            self.nearbyCarsManager.nearbyCarConfig.vehicleTypes = @"";
            break;
    }
    //移除
    [self.nearbyCarsManager removeAllNearbyCars];
    //添加
    [self.nearbyCarsManager getNearbyCars];
}

#pragma mark - QMapViewDelegate

- (void)mapView:(QMapView *)mapView didUpdateUserLocation:(QUserLocation *)userLocation fromHeading:(BOOL)fromHeading {
    
    // 进入该页面是，将地图中心点移至用户所在位置
    if (!self.hasGotLocation &&
        CLLocationCoordinate2DIsValid(userLocation.location.coordinate) &&
        (userLocation.location.coordinate.latitude != 0 || userLocation.location.coordinate.longitude != 0)) {
        
        [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(self.mapView.userLocation.location.coordinate.latitude, self.mapView.userLocation.location.coordinate.longitude)];
        self.hasGotLocation = YES;
    }
}

- (void)mapView:(QMapView *)mapView regionWillChangeAnimated:(BOOL)animated gesture:(BOOL)bGesture {
    
    [self.mapView.tmm_centerPinView setCalloutAttribtedText:[[NSAttributedString alloc] initWithString:@"拖到路边或小绿点，接驾更快" attributes:@{NSForegroundColorAttributeName : [UIColor blackColor], NSFontAttributeName : [UIFont systemFontOfSize:12]}]];
}


-(void)mapView:(QMapView *)mapView regionDidChangeAnimated:(BOOL)animated gesture:(BOOL)bGesture
{
    [self.mapView.tmm_centerPinView setCalloutAttribtedText:[[NSAttributedString alloc] initWithString:@"在这里上车" attributes:@{NSForegroundColorAttributeName : [UIColor blackColor], NSFontAttributeName : [UIFont systemFontOfSize:13]}]];
}

@end
