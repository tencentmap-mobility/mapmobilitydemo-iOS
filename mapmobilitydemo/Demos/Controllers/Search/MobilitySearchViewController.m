//
//  SearchViewController.m
//  mapmobilitydemo
//
//  Created by mol on 2019/12/4.
//  Copyright © 2019 tencent. All rights reserved.
//

#import "MobilitySearchViewController.h"
#import <TencentMapMobilitySDK/TencentMapMobilitySDK.h>
#import <TencentMapMobilitySearchSDK/TMMSearch.h>
#import "TripPanelView.h"
#import "SearchKeywordViewController.h"

@interface MobilitySearchViewController ()<QMapViewDelegate>
// 地图视图
@property (nonatomic, strong) QMapView *mapView;
// 是否已经获得首次定位信息，判断是否需要调整地图中心点
@property (nonatomic, assign) BOOL hasGotLocation;

// 底部行程面板
@property (nonatomic, strong) TripPanelView *tripPanelView;

@property (nonatomic, strong) NSURLSessionTask *regeoTask;

@property (nonatomic, weak) SearchKeywordViewController *searchKeywordViewController;

@property (nonatomic) CLLocationCoordinate2D lastLocationCoordinate;
@end

@implementation MobilitySearchViewController

- (void)dealloc {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupMapView];
    [self setupTripPanel];
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
    self.mapView.tmm_centerPinViewHidden = NO;
    [self.mapView.tmm_centerPinView setCalloutAttribtedText:[[NSAttributedString alloc] initWithString:@"在这里上车" attributes:@{NSForegroundColorAttributeName : [UIColor blackColor], NSFontAttributeName : [UIFont systemFontOfSize:13]}]];

    
    [self.view addSubview:self.mapView];
}

- (void)setupTripPanel {
    
    CGFloat lrMargin = 10.0;
    CGFloat bMargin = 20.0;
    CGFloat panelHeight = 120.0;
    
    self.tripPanelView = [[TripPanelView alloc] initWithFrame:CGRectMake(lrMargin, self.view.bounds.size.height - panelHeight - bMargin, self.view.bounds.size.width - 2 * lrMargin, panelHeight)];
    self.tripPanelView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    [self.view addSubview:self.tripPanelView];
    
    __weak typeof(self) weakself = self;
    [self.tripPanelView setClickInputCallback:^(TripPanelInput panelInput) {
        TMMSSuggestionPolicy suggestionPolicy;
        switch (panelInput) {
            case TripPanelInputStart:
            {
                suggestionPolicy = TMMSSuggestionPolicySource;
            }
                break;
            case TripPanelInputEnd:
            {
                suggestionPolicy = TMMSSuggestionPolicyDestination;
            }
                break;
            default:
                break;
        }
        
        [weakself showSearchKeywordViewControllerWithPolicy:suggestionPolicy];
    }];
}

- (void)showSearchKeywordViewControllerWithPolicy:(TMMSSuggestionPolicy)suggestionPolicy {
    __weak typeof(self) weakself = self;

    SearchKeywordViewController *searchKeywordViewController = [[SearchKeywordViewController alloc] init];
    searchKeywordViewController.locationCoordinate = self.mapView.centerCoordinate;
    searchKeywordViewController.policy = suggestionPolicy;
    
    searchKeywordViewController.poiModelClickCallback = ^(TMMSearchPOIModel * _Nonnull poiModel, TMMSearchPOIModel * _Nullable subPOIModel) {
        __strong MobilitySearchViewController *strongself = weakself;
        if (!strongself) {
            return;
        }
        CLLocationCoordinate2D locationCoordinate;
        
        NSMutableString *address = [NSMutableString stringWithFormat:@"%@", poiModel.title];
        if (subPOIModel) {
            locationCoordinate = subPOIModel.locationCoordinate;
            [address appendString:[NSString stringWithFormat:@"-%@", subPOIModel.title]];
        }else {
            locationCoordinate = poiModel.locationCoordinate;
        }
        switch (suggestionPolicy) {
            case TMMSSuggestionPolicySource:
            {
                strongself.tripPanelView.startAddress = [NSString stringWithFormat:@"%@", address] ;
                [strongself.mapView setCenterCoordinate:locationCoordinate animated:YES];
            }
                break;
            case TMMSSuggestionPolicyDestination:
            {
                strongself.tripPanelView.endAddress = [NSString stringWithFormat:@"%@", address] ;
            }
                break;
            default:
                break;
        }
    };
    searchKeywordViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:searchKeywordViewController animated:YES completion:nil];
    self.searchKeywordViewController = searchKeywordViewController;
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

- (void)mapView:(QMapView *)mapView regionDidChangeAnimated:(BOOL)animated gesture:(BOOL)bGesture {
    
    [self.mapView.tmm_centerPinView setCalloutAttribtedText:[[NSAttributedString alloc] initWithString:@"在这里上车" attributes:@{NSForegroundColorAttributeName : [UIColor blackColor], NSFontAttributeName : [UIFont systemFontOfSize:13]}]];
    
    
    
    if ([TMMMathTool distanceBetweenCoordinate:self.lastLocationCoordinate coordinate:mapView.centerCoordinate] < 0.1) {
        // 基本没有移动，不用发起逆地址解析请求
        return;
    }
    self.lastLocationCoordinate = mapView.centerCoordinate;
    
    [self.regeoTask cancel];
    TMMSearchReGeocodeRequest *request = [[TMMSearchReGeocodeRequest alloc] init];
    request.locationCoordinate = mapView.centerCoordinate;
    
    __weak typeof(self) weakself = self;
    
    self.regeoTask = [TMMSearchManager queryReGeocodeWithRequest:request completion:^(TMMSearchReGeocodeResponse * _Nullable response, NSError * _Nullable error) {
        
        __strong MobilitySearchViewController *strongself = weakself;
        if (!strongself) {
            return;
        }
        if (error) {
            return;
        }
        
        strongself.tripPanelView.startAddress = response.formattedAddress;
    }];
}


@end
