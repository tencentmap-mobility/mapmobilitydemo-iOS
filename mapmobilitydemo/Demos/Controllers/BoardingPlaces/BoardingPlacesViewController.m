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
#import <TencentMapMobilityBoardingPlacesSDK/TencentMapMobilityBoardingPlacesSDK.h>
#import "Constants.h"

@interface BoardingPlacesViewController () <QMapViewDelegate, TencentLBSLocationManagerDelegate, TMMNearbyBoardingPlacesManagerDelegate,
UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) QMapView *mapView;
@property (nonatomic, strong) TencentLBSLocationManager *locationManager;

@property UISegmentedControl* segment;
// 是否已经获得首次定位信息，判断是否需要调整地图中心点
@property (nonatomic, assign) BOOL hasGotLocation;

@property (nonatomic, strong) TMMNearbyBoardingPlacesManager *bpManager;

@property (nonatomic, strong) UIAlertController *subTrafficHubAlertController;

@property (nonatomic, strong) UIPickerView *subFencePickView;
@property (nonatomic, strong) TMMFenceModel *myFenceModel;

@end


@implementation BoardingPlacesViewController

#pragma mark - life cycle

- (void)dealloc {
    [self stopSerialLocation];
    self.mapView = nil;
    [self.mapView removeFromSuperview];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.mapView = [[QMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.autoresizingMask  = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mapView.rotateEnabled = NO;
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];
    self.mapView.tmm_centerPinViewHidden = NO;
    [self.mapView.tmm_centerPinView setCalloutAttribtedText:[[NSAttributedString alloc] initWithString:@"在这里上车" attributes:@{NSForegroundColorAttributeName : [UIColor blackColor], NSFontAttributeName : [UIFont systemFontOfSize:12]}]];
    
    self.mapView.showsUserLocation = YES;
    
    [self setupNearbyBoardingPlaces];
    [self setupLocationManager];
    [self startSerialLocation];
    [self queryNearbyBoardingPlaces];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.segment removeAllSegments];
}


#pragma mark - setup

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

- (void)queryNearbyBoardingPlaces
{
    
    TMMNearbyBoardingPlacesRequest *request = [[TMMNearbyBoardingPlacesRequest alloc] init];
    request.locationCoordinate = CLLocationCoordinate2DMake(39.9825495,116.3632176);
//    request.limit = 3;

    
//    [self.mapView queryNearbyBoardingPlacesWith:request callback:^(TMMNearbyBoardingPlacesResponse * _Nonnull response, NSError * _Nonnull error) {
//
//    }];
    
}

#pragma mark - LBSLocationDelegate

// 单次定位
- (void)startSingleLocation {
    [self.locationManager requestLocationWithCompletionBlock:
     ^(TencentLBSLocation *location, NSError *error) {
         NSLog(@"%@, %@, %@", location.location, location.name, location.address);
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
//    if (self.subTrafficHubAlertController) {
//        return;
//    }
//
//    self.subTrafficHubAlertController = [UIAlertController alertControllerWithTitle:@"选择二级围栏" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
//
//    __weak typeof(self) weakself = self;
//    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//        weakself.subTrafficHubAlertController = nil;
//    }];
//
//    for (NSUInteger i = 0; i < fenceModel.subFenceModels.count; i++) {
//
//        TMMSubFenceModel *subFenceModel = fenceModel.subFenceModels[i];
//
//        UIAlertActionStyle actionStyle = i == fenceModel.selectedSubFenceIndex ? UIAlertActionStyleDestructive : UIAlertActionStyleDefault;
//
//        UIAlertAction *action = [UIAlertAction actionWithTitle:subFenceModel.title style:actionStyle handler:^(UIAlertAction * _Nonnull action) {
//            // 选中的二级围栏
//            NSLog(@"选中的二级围栏是：%@", subFenceModel.title);
//            weakself.subTrafficHubAlertController = nil;
//            [weakself.bpManager chooseSubFence:subFenceModel];
//        }];
//
//        [self.subTrafficHubAlertController addAction:action];
//
//    }
//
//    [self.subTrafficHubAlertController addAction:cancelAction];
//
//    [self presentViewController:self.subTrafficHubAlertController animated:YES completion:nil];

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
