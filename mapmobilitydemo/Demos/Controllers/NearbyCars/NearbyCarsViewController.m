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

@interface NearbyCarsViewController ()<QMapViewDelegate, TencentLBSLocationManagerDelegate>

@property (nonatomic, strong) QMapView *mapView;
@property (nonatomic, strong) TencentLBSLocationManager *locationManager;

@property (nonatomic, strong) NSString *cityCode;

@property (nonatomic, strong) UISegmentedControl *segmentControl;

@property UISegmentedControl* segment;

@end

@implementation NearbyCarsViewController

#pragma mark - life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self setupMapView];
    [self setupNearbyCar];
    [self setupLocationManager];
    [self startSingleLocation];
    [self setupSelecteVehicleTypesBar];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.segment removeAllSegments];
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
    [self.locationManager setApiKey:@""];

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
    nearbyCarConfig.mock = 1;
    
    nearbyCarConfig.carIconDictionary = @{@(1) : [UIImage imageNamed:@"taxi"], @(2) : [UIImage imageNamed:@"cleanEnergyCar"], @(3) : [UIImage imageNamed:@"comfortCar"], @(4):[UIImage imageNamed:@"luxuryCar"], @(5):[UIImage imageNamed:@"businessCar"], @(6):[UIImage imageNamed:@"economyCar"]};

    CGPoint pinPosition = CGPointMake(0.5, 0.5);
    self.mapView.tmm_pinPosition = pinPosition;
    self.mapView.nearbyCarConfig = nearbyCarConfig;

    [self.mapView setCenterOffset:pinPosition];
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

#pragma mark - LBSLocationDelegate

// 单次定位
- (void)startSingleLocation
{
    [self.locationManager requestLocationWithCompletionBlock:
     ^(TencentLBSLocation *location, NSError *error) {
         NSLog(@"%@, %@, %@", location.location, location.name, location.address);
         dispatch_async(dispatch_get_main_queue(), ^{
             [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(self.mapView.userLocation.location.coordinate.latitude, self.mapView.userLocation.location.coordinate.longitude)];

         });
     }];
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
                didUpdateLocation:(TencentLBSLocation *)location {

    self.cityCode = location.code;
    self.mapView.tmm_cityCode = self.cityCode;
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
    
    [self.mapView removeAllNearbyCars];
    [self.mapView getNearbyCars];
}


@end
