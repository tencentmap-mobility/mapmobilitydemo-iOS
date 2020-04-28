//
//  RoutePlanningViewController.m
//  TencentMapMobilityDemo
//
//  Created by 张晓芳 on 2020/4/3.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "RoutePlanningViewController.h"
#import <TencentMapMobilitySDK/TencentMapMobilitySDK.h>
#import <TencentMapMobilitySearchSDK/TMMSearch.h>
#import "TrafficPolyline.h"
#import "MapMathTool.h"

@interface RoutePlanningViewController ()<QMapViewDelegate>

@property (nonatomic, strong) QMapView *mapView;

@property (nonatomic, strong) UISegmentedControl *segment;

@property (nonatomic, assign) CLLocationCoordinate2D from;

@property (nonatomic, assign) CLLocationCoordinate2D to;

@property (nonatomic, strong) QPolyline *routeLine;

@property (nonatomic, strong) TrafficPolyline *trafficLine;

@property (nonatomic, strong) NSMutableArray <TrafficPolyline *>*trafficlines;

@property (nonatomic, strong) NSArray<QSegmentColor *> *segmentColor;

@property (nonatomic, strong) QPointAnnotation *fromAnnotation;

@property (nonatomic, strong) QPointAnnotation *toAnnotation;

@property (nonatomic, assign) NSInteger currentSelectIndex;

@end

@implementation RoutePlanningViewController

#pragma mark - life circle
- (void)dealloc {
    [self.segment removeFromSuperview];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
}

#pragma mark - setup
- (void)setup
{
    [self setupData];
    [self setupMapView];
    [self setupSegment];
    [self setupAnnotationview];
    
}

- (void)setupData
{
    _from = CLLocationCoordinate2DMake(39.908823, 116.39747);
    _to = CLLocationCoordinate2DMake(39.95554343, 116.316719);
}

- (void)setupMapView
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.mapView = [[QMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.autoresizingMask  = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mapView.showsUserLocation = NO;
    self.mapView.delegate = self;
    self.mapView.zoomLevel = 12.5;
    self.mapView.centerCoordinate = CLLocationCoordinate2DMake(39.931625, 116.352976);
    [self.view addSubview:self.mapView];
}

- (void)setupSegment
{
    self.segment = [[UISegmentedControl alloc] initWithItems:@[@"驾车",@"步行"]];
    self.segment.frame = CGRectMake(self.mapView.frame.size.width - 90.0, 8.0f, 80.0f, 30.0f);
    [self.navigationController.navigationBar addSubview:self.segment];
    [self.segment addTarget:self action:@selector(selected:) forControlEvents:UIControlEventValueChanged];
    
    self.segment.selectedSegmentIndex = 0;
    _currentSelectIndex = 0;
    [self showDrivingRoutes];
}

- (void)setupAnnotationview
{
    //起点
    self.fromAnnotation = [[QPointAnnotation alloc] init];
    self.fromAnnotation.coordinate = self.from;
    self.fromAnnotation.title = @"startAnnotation";
    [self.mapView addAnnotation:self.fromAnnotation];
    //终点
    self.toAnnotation = [[QPointAnnotation alloc] init];
    self.toAnnotation.coordinate = self.to;
    self.toAnnotation.title = @"destinationAnnotation";
    [self.mapView addAnnotation:self.toAnnotation];
}

#pragma mark - action

-(void)selected:(id)sender
{    
    UISegmentedControl *control = (UISegmentedControl*)sender;
    NSInteger index = control.selectedSegmentIndex;
    if (index == 0  && index!=_currentSelectIndex)
    {
        [self clearRoute];
        [self showDrivingRoutes];
    }
    
    if (index == 1 && index!=_currentSelectIndex)
    {
        [self clearRoute];
        [self showWalkingRoutes];
    }
    
    _currentSelectIndex = index;
}

#pragma mark - Routes
- (void)showDrivingRoutes
{
    TMMSearchDrivingRequest *drivingRequest = [[TMMSearchDrivingRequest alloc] init];
    drivingRequest.start = [[TMMNaviPOI alloc] init];
    drivingRequest.destination = [[TMMNaviPOI alloc] init];
    
    drivingRequest.start.coordinate = _from;
    drivingRequest.destination.coordinate = _to;
    
    __weak typeof(self) weakSelf = self;
    
    [TMMSearchManager queryDrivingWithRequest:drivingRequest completion:^(TMMSearchDrivingResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error) {
            NSLog(@"error=%@",error);
        }
        
        [weakSelf drawRoutesWithRoute:response.routes.firstObject type:@"driving"];

    }];
}

- (void)showWalkingRoutes
{
    TMMSearchWalkingRequest *walkingRequest = [[TMMSearchWalkingRequest alloc] init];
    walkingRequest.startCoordinate = _from;
    walkingRequest.destinationCoordinate = _to;
    
    [TMMSearchManager queryWalkingWithRequest:walkingRequest completion:^(TMMSearchWalkingResponse * _Nullable response, NSError * _Nullable error) {
        for (TMMCarNaviRoute *route in response.routes)
        {
            [self drawRoutesWithRoute:route type:@"walking"];
        }
    }];
}

- (UIColor *)transformColorIndexArray:(NSInteger)colorIndex
{
    switch (colorIndex)
    {
        case 0:
            return [UIColor colorWithRed:62.0/255.0 green:186.0/255.0 blue:121.0/255.0 alpha:1];
        case 1:
            return [UIColor colorWithRed:244.0/255.0 green:187.0/255.0 blue:69.0/255.0 alpha:1];
        case 2:
            return [UIColor colorWithRed:232.0/255.0 green:88.0/255.0 blue:84.0/255.0 alpha:1];
        case 3:
            return [UIColor colorWithRed:79.0/255.0 green:150.0/255.0 blue:238.0/255.0 alpha:1];
        case 4:
            return [UIColor colorWithRed:175.0/255.0 green:51.0/255.0 blue:61.0/255.0 alpha:1];
        default:
            return [UIColor colorWithRed:79.0/255.0 green:150.0/255.0 blue:238.0/255.0 alpha:1];
    }
}

- (void)drawRoutesWithRoute:(TMMCarNaviRoute *)route type:(NSString *)type
{
    CLLocationCoordinate2D coordinates[route.points.count];
    for (int i = 0; i < route.points.count; i++)
    {
        TMMLocationPoint *point = route.points[i];
        coordinates[i] = point.coordinate;
    }
    
    if ([type isEqualToString:@"driving"])
    {
        NSArray <QSegmentColor *> * colorArray = [self segmentColorWithDrivingRoute:route];
        self.trafficLine = [[TrafficPolyline alloc] initWithCoordinates:coordinates count:route.points.count arrLine:colorArray];
        if (!self.trafficlines)
        {
            self.trafficlines = [[NSMutableArray alloc] init];
        }
        [self.mapView addOverlay:self.trafficLine];
        [self.trafficlines addObject:self.trafficLine];
        
        // 调整地图显示区域
        [self.mapView setVisibleMapRect:[MapMathTool mapRectWithLocationPoints:route.points] edgePadding:UIEdgeInsetsMake(30, 30, 30, 30) animated:YES];
    }
    else if ([type isEqualToString:@"walking"])
    {
        self.routeLine = [QPolyline polylineWithCoordinates:coordinates count:route.points.count];
        [self.mapView addOverlay:self.routeLine];
        // 调整地图显示区域
        [self.mapView setVisibleMapRect:[MapMathTool mapRectWithLocationPoints:route.points] edgePadding:UIEdgeInsetsMake(30, 40, 30, 40) animated:YES];
    }
}


- (NSArray <QSegmentColor *> *)segmentColorWithDrivingRoute:(TMMCarNaviRoute *)route
{
    NSMutableArray<QSegmentColor *> *colorArray = [NSMutableArray array];
    
    for (TMMTrafficItem *item in route.trafficItems)
    {
        QSegmentColor *segColorLine = [[QSegmentColor alloc] init];
        segColorLine.startIndex = (int)item.from;
        segColorLine.endIndex   = (int)item.to;
        segColorLine.color  = [self transformColorIndexArray:item.color];
        
        [colorArray addObject:segColorLine];
    }
    
    return [colorArray copy];
}

- (void)clearRoute
{
    if (self.routeLine)
    {
        [self.mapView removeOverlay:self.routeLine];
    }
    
    if (self.trafficlines.count > 0)
    {
        for (int i = 0;i < self.trafficlines.count;i++)
        {
            self.trafficLine = self.trafficlines[i];
            [self.mapView removeOverlay:self.trafficLine];
        }
        
    }
    self.routeLine = nil;
}

#pragma mark - mapviewDelegate

- (QOverlayView *)mapView:(QMapView *)mapView viewForOverlay:(id<QOverlay>)overlay
{
    if ([overlay isKindOfClass:[TrafficPolyline class]])
    {
        TrafficPolyline *trafficPolyLine = (TrafficPolyline *)overlay;
        
        QTexturePolylineView *polylineView = [[QTexturePolylineView alloc] initWithPolyline:overlay];
        polylineView.borderColor  = [UIColor blackColor];
        polylineView.lineWidth    = 13;
        polylineView.borderWidth  = 1;
        polylineView.segmentColor = trafficPolyLine.arrLine;
        polylineView.drawType     = QTextureLineDrawType_ColorLine;
        polylineView.drawSymbol   = YES;
        //        polylineView.symbolImage  = [UIImage imageNamed:@"color_arrow_texture.png"];
        polylineView.symbolGap    = 100;
        
        return polylineView;
    }
    else
    {
        QSegmentStyle *style = [[QSegmentStyle alloc] init];
        style.startIndex = 0;
        style.endIndex = (int)((QPolyline *)overlay).pointCount - 1;
        style.colorImageIndex = 4;
        
        QTexturePolylineView *polylineView = [[QTexturePolylineView alloc] initWithPolyline:overlay];
        polylineView.segmentStyle = @[style];
        
        polylineView.lineWidth = 12;
        polylineView.drawSymbol = YES;
        
        return polylineView;
    }
    
    return nil;
}

- (QAnnotationView *)mapView:(QMapView *)mapView viewForAnnotation:(id<QAnnotation>)annotation
{
    if ([annotation isKindOfClass:[QPointAnnotation class]])
    {
        if ([annotation.title isEqualToString:@"destinationAnnotation"])
        {
            NSString *identifier = @"destination";
            QAnnotationView *annotationView = [self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
            if (!annotationView)
            {
                annotationView = [[QAnnotationView alloc] init];
            }
            annotationView.image = [UIImage imageNamed:@"ic_end"];
            return annotationView;
        }
        else if ([annotation.title isEqualToString:@"startAnnotation"])
        {
            NSString *identifier = @"start";
            QAnnotationView *annotationView = [self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
            if (!annotationView)
            {
                annotationView = [[QAnnotationView alloc] init];
            }
            annotationView.image = [UIImage imageNamed:@"ic_start"];
            return annotationView;
        }
        else
        {
            static NSString *pointReuseIndetifier = @"pointReuseIndetifier";
            QPinAnnotationView *annotationView = (QPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndetifier];
            
            if (annotationView == nil)
            {
                annotationView = [[QPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndetifier];
            }
            
            annotationView.canShowCallout   = NO;
            annotationView.pinColor = QPinAnnotationColorRed;
            annotationView.animatesDrop = YES;
            
            return annotationView;
        }
    }
    
    return nil;
}


@end
