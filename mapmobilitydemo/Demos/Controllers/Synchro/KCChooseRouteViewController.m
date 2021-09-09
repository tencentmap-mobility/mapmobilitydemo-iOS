//
//  KCChooseRouteViewController.m
//  TencentMapLocusSynchroDemo
//
//  Created by mol on 2021/8/31.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "KCChooseRouteViewController.h"
#import <TencentMapLocusSynchroSDK/TencentMapLocusSynchroSDK.h>
#import <TencentMapLocusSynchroPassengerSDK/TencentMapLocusSynchroPassengerSDK.h>

#import <QMapKit/QMapKit.h>
#import "TLSRoutePolyline.h"
#import "MathTool.h"

@interface KCChooseRouteViewController ()<QMapViewDelegate>

@property (nonatomic, strong) TLSPFetchedData *fetchedData;

// 地图
@property (nonatomic, strong) QMapView *mapView;

// 多路线polyline
@property (nonatomic, copy) NSArray<TLSRoutePolyline *> *routePolylines;

// 司机小车Marker
@property (nonatomic, strong) QPointAnnotation *carMarker;

@end

@implementation KCChooseRouteViewController

- (instancetype)initWithFetchedData:(TLSPFetchedData *)fetchedData {
    
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.fetchedData = fetchedData;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 初始化toolbar
    [self setupToolbar];
    
    // 初始化地图
    [self setupMap];
    
    [self showMultiRoutes];
    
    [self showCarMarker];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

#pragma mark - private

- (void)setupToolbar {
    
    UIBarButtonItem *flexble = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(cancel:)];
    UIBarButtonItem *confirmButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleDone target:self action:@selector(confirm:)];
        
    self.toolbarItems = @[flexble,
                          cancelButtonItem,
                          flexble,
                          confirmButtonItem,
                          flexble,
    ];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)setupMap {
        
    self.mapView = [[QMapView alloc] initWithFrame:self.view.bounds];
    
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = NO;
    self.mapView.rotateEnabled = NO;
    self.mapView.overlookingEnabled = NO;
    
    [self.view addSubview:self.mapView];
}

// 展示多路线
- (void)showMultiRoutes {
    
    NSMutableArray *routePolylines = [NSMutableArray arrayWithCapacity:3];
    
    for (TLSBRoute *route in self.fetchedData.backupRoutes) {
        
        TLSRoutePolyline *polyLine = [[TLSRoutePolyline alloc] initWithRoute:route selected:NO];
        [self.mapView addOverlay:polyLine];
        [routePolylines addObject:polyLine];
    }
    
    TLSBRoute *curRoute = self.fetchedData.route;
    TLSRoutePolyline *polyLine = [[TLSRoutePolyline alloc] initWithRoute:curRoute];
    [self.mapView addOverlay:polyLine];
    [routePolylines addObject:polyLine];
    
    self.routePolylines = routePolylines;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self adjestVisiableMapRectIfNeeded];
    });
    
}

- (void)showCarMarker {
    
    if (self.fetchedData.positions.count == 0) {
        return;
    }
    self.carMarker = [[QPointAnnotation alloc] init];
    self.carMarker.coordinate = self.fetchedData.positions.firstObject.matchedCoordinate;
    self.carMarker.title = @"driver";
    [self.mapView addAnnotation:self.carMarker];
}

- (void)adjestVisiableMapRectIfNeeded {
    
    NSMutableArray<id<TLSBLocation>> *allPoints = [NSMutableArray array];
    [allPoints addObjectsFromArray:self.fetchedData.route.points];
    
    for (TLSBRoute *route in self.fetchedData.backupRoutes) {
        [allPoints addObjectsFromArray:route.points];
    }
    
    // 更新视野
    QMapRect mapRect = [MathTool mapRectFitsLocations:allPoints];
    
    [self.mapView setVisibleMapRect:mapRect
                        edgePadding:UIEdgeInsetsMake(50, 50, 50, 50)
                           animated:YES];
}

- (void)chooseRoute:(TLSBRoute *)route {
    
    TLSRoutePolyline *selectedPolyline = [self.routePolylines filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"selected=%d", YES]].firstObject;
    if (selectedPolyline.route == route) {
        return;
    }
    
    // 至为备选样式
    selectedPolyline.selected = NO;
    [self.mapView removeOverlay:selectedPolyline];
    [self.mapView addOverlay:selectedPolyline];
    
    // 新选中路线，置为选中样式
    TLSRoutePolyline *polyline = [self.routePolylines filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"route=%@", route]].firstObject;
    polyline.selected = YES;
    [self.mapView removeOverlay:polyline];
    [self.mapView addOverlay:polyline];
}

#pragma mark - actions
- (void)cancel:(UIBarButtonItem *)item {
    
    [self.delegate kcChooseRouteDidCancel:self];
    //[self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)confirm:(UIBarButtonItem *)item {
    
    // 回调
    TLSRoutePolyline *selectedPolyline = [self.routePolylines filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"selected=%d", YES]].firstObject;
    [self.delegate kcChooseRouteDidConfirm:self selectedRoute:selectedPolyline.route];
    
    [self.navigationController popViewControllerAnimated:YES];
}
 
#pragma mark - QMapViewDelegate

- (QAnnotationView *)mapView:(QMapView *)mapView viewForAnnotation:(id<QAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[QPointAnnotation class]])  {
        
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
        } else if ([annotation.title isEqualToString:@"end_circle"]) {
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

- (QOverlayView *)mapView:(QMapView *)mapView viewForOverlay:(id<QOverlay>)overlay {
    if ([overlay isKindOfClass:[TLSRoutePolyline class]]) {
        
        TLSRoutePolyline *trafficPolyline = overlay;
        QTexturePolylineView *polylineRender = [[QTexturePolylineView alloc] initWithPolyline:overlay];
        polylineRender.drawType = QTextureLineDrawType_ColorLine;
        polylineRender.segmentColor = trafficPolyline.segmentColors;
        polylineRender.borderColor  = [UIColor colorWithRed:0 green:0.8 blue:0 alpha:0.15];
        polylineRender.lineWidth    = 10;
        polylineRender.borderWidth  = 1;
        polylineRender.drawSymbol   = YES;
        
        return polylineRender;
    }
    return nil;
}

- (void)mapView:(QMapView *)mapView didTapOverlay:(id<QOverlay>)overlay {
    
    if ([self.routePolylines containsObject:overlay]) {
        // 点选路线路线
        TLSBRoute *route = [(TLSRoutePolyline *)overlay route];
        [self chooseRoute:route];
    }
}

@end
