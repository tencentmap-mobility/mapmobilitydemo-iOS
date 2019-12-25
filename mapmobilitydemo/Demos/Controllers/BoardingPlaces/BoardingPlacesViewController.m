//
//  BoardingPlacesViewController.m
//  TencentMapMobilityDemo
//
//  Created by Yuchen Wang on 2019/11/19.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import "BoardingPlacesViewController.h"
#import <TencentLBS/TencentLBS.h>
#import <TencentMapMobilitySDK/TencentMapMobilitySDK.h>
#import <TencentMapMobilityBoardingPlacesSDK/TMMBoardingPlaces.h>
#import "Constants.h"

@interface BoardingPlacesViewController () <QMapViewDelegate, TencentLBSLocationManagerDelegate, TMMNearbyBoardingPlacesManagerDelegate,
UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) QMapView *mapView;
@property (nonatomic, strong) TencentLBSLocationManager *locationManager;

// 是否已经获得首次定位信息，判断是否需要调整地图中心点
@property (nonatomic, assign) BOOL hasGotLocation;

@property (nonatomic, strong) TMMNearbyBoardingPlacesManager *bpManager;

// 围栏选择器
@property (nonatomic, strong) UIPickerView *subFencePickView;
// 命中围栏时的围栏数据
@property (nonatomic, strong) TMMFenceModel *myFenceModel;

@end


@implementation BoardingPlacesViewController

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
    
    // 配置推荐上车点
    [self setupNearbyBoardingPlaces];

    // 纯数据接口
    //[self queryNearbyBoardingPlaces];
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

- (void)setupNearbyBoardingPlaces
{
    
    TMMNearbyBoardingPlacesConfig *config = [[TMMNearbyBoardingPlacesConfig alloc] init];

    config.minMapZoomLevel = 15;
    
    self.bpManager = [[TMMNearbyBoardingPlacesManager alloc] initWithMapView:self.mapView delagate:self];
    self.bpManager.nearbyBoardingPlacesConfig = config;

}

// 纯数据接口
- (void)queryNearbyBoardingPlaces
{
    
    TMMNearbyBoardingPlacesRequest *request = [[TMMNearbyBoardingPlacesRequest alloc] init];
    request.locationCoordinate = CLLocationCoordinate2DMake(39.9825495,116.3632176);

    [TMMNearbyBoardingPlacesManager queryNearbyBoardingPlacesWith:request callback:^(TMMNearbyBoardingPlacesResponse * _Nullable response, NSError * _Nullable error) {

    }];
    
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
    
    self.mapView.tmm_cityCode = location.code;
}


#pragma mark - QMapViewDelegate
- (void)mapView:(QMapView *)mapView didUpdateUserLocation:(QUserLocation *)userLocation fromHeading:(BOOL)fromHeading {
    
    // 进入该页面时，将地图中心点移至用户所在位置
    if (!self.hasGotLocation &&
        CLLocationCoordinate2DIsValid(userLocation.location.coordinate) &&
        (userLocation.location.coordinate.latitude != 0 || userLocation.location.coordinate.longitude != 0)) {
        
        [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(self.mapView.userLocation.location.coordinate.latitude, self.mapView.userLocation.location.coordinate.longitude)];
        self.hasGotLocation = YES;
        
        // 第一次手动请求推荐上车点
        [self.bpManager getNearbyBoardingPlaces];
    }
}

- (void)mapView:(QMapView *)mapView regionDidChangeAnimated:(BOOL)animated gesture:(BOOL)bGesture {
    
    [self.mapView.tmm_centerPinView setCalloutAttribtedText:[[NSAttributedString alloc] initWithString:@"在这里上车" attributes:@{NSForegroundColorAttributeName : [UIColor blackColor], NSFontAttributeName : [UIFont systemFontOfSize:12]}]];
    
}


- (void)mapView:(QMapView *)mapView regionWillChangeAnimated:(BOOL)animated gesture:(BOOL)bGesture {
    
    if (bGesture) {
        [self.mapView.tmm_centerPinView setCalloutAttribtedText:[[NSAttributedString alloc] initWithString:@"拖到路边或小绿点，接驾更快" attributes:@{NSForegroundColorAttributeName : [UIColor blackColor], NSFontAttributeName : [UIFont systemFontOfSize:12]}]];
        
    }
}

- (void)mapView:(QMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    self.myFenceModel = nil;
    [self.subFencePickView removeFromSuperview];
    self.subFencePickView = nil;
}

#pragma mark - TMMNearbyBoardingPlacesManagerDelegate

- (void)TMMNearbyBoardingPlaceManager:(TMMNearbyBoardingPlacesManager *)manager didReceivedFence:(nonnull TMMFenceModel *)fenceModel {
    NSLog(@"didReceivedSubTrafficHubs=%ld", fenceModel.subFenceModels.count);
    
    if (fenceModel.subFenceModels.count == 0) {
        return;
    }
    
    BOOL needReloadPickView = YES;
    
    if (self.myFenceModel && self.myFenceModel == fenceModel) {
        needReloadPickView = NO;
    }
    
    self.myFenceModel = fenceModel;
    
    CGFloat pickViewHeight = 200.0;
    if (!self.subFencePickView) {
        
        self.subFencePickView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - pickViewHeight, self.view.bounds.size.width, pickViewHeight)];
        self.subFencePickView.backgroundColor = [UIColor whiteColor];
        self.subFencePickView.showsSelectionIndicator = YES;
 
        [self.view addSubview:self.subFencePickView];
        self.subFencePickView.delegate = self;
        self.subFencePickView.dataSource = self;
    }
    
    if (needReloadPickView) {
        [self.subFencePickView reloadAllComponents];
    }
    
    [self.subFencePickView selectRow:fenceModel.selectedSubFenceIndex inComponent:0 animated:NO];
}

- (void)TMMNearbyBoardingPlaceManagerDidMoveOutOfFence:(TMMNearbyBoardingPlacesManager *)manager {
    NSLog(@"TMMNearbyBoardingPlaceManagerDidMoveOutOfFence");
    
    self.myFenceModel = nil;
    [self.subFencePickView removeFromSuperview];
    self.subFencePickView = nil;
}

- (void)TMMNearbyBoardingPlaceManager:(TMMNearbyBoardingPlacesManager *)manager didAbsorbedToBoardingPlaceModel:(nonnull TMMNearbyBoardingPlaceModel *)absorbedBoardingPlaceModel {
    
    NSLog(@"didAbsorbedToBoardingPlaceModel=%@", absorbedBoardingPlaceModel.title);

}

- (void)TMMNearbyBoardingPlaceManager:(TMMNearbyBoardingPlacesManager *)manager didReceivedNearbyBoardingPlaces:(NSArray<TMMNearbyBoardingPlaceModel *> *)nearbyBoardingPlaces {
    
    NSLog(@"didReceivedNearbyBoardingPlaces=%ld", nearbyBoardingPlaces.count);
}



- (void)TMMNearbyBoardingPlaceManager:(TMMNearbyBoardingPlacesManager *)manager didFailReceivedNearbyBoardingPlacesWithError:(NSError *)error {
    NSLog(@"didFailReceivedNearbyBoardingPlacesWithError=%@", error);

}


- (void)TMMNearbyBoardingPlaceManager:(TMMNearbyBoardingPlacesManager *)manager didRegeocodeReceivedLocationName:(NSString *)locationName
{
    
    
    NSLog(@"didRegeocodeReceivedLocationName: %@", locationName);
    
    
}

#pragma mark - UIPickViewDelegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.myFenceModel.subFenceModels.count;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 40.0;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [self.bpManager chooseSubFence:self.myFenceModel.subFenceModels[row]];
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    NSString *title = self.myFenceModel.subFenceModels[row].title;
    
    return [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName : [UIColor blackColor],
                                                                         NSFontAttributeName : [UIFont systemFontOfSize:16]
                                                                         }];
}





@end
