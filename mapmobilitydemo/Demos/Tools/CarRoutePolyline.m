//
//  CarRoutePolyline.m
//  TencentMapLocusSynchroDemo
//
//  Created by mol on 2021/9/2.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "CarRoutePolyline.h"
#import <TNKNavigationKit/TNKNavigationKit.h>

@implementation CarRoutePolyline

- (instancetype)initWithRoute:(TNKCarRouteSearchRoutePlan *)routePlan {
    
    return [self initWithRoute:routePlan selected:YES];
}

- (instancetype)initWithRoute:(TNKCarRouteSearchRoutePlan *)routePlan selected:(BOOL)selected {
    
    CLLocationCoordinate2D polylineCoords[routePlan.line.coordinatePoints.count];
    
    for(int i = 0; i < routePlan.line.coordinatePoints.count; ++i) {
        polylineCoords[i].latitude = routePlan.line.coordinatePoints[i].coordinate.latitude;
        polylineCoords[i].longitude = routePlan.line.coordinatePoints[i].coordinate.longitude;
    }

    self = [super initWithCoordinates:polylineCoords count:routePlan.line.coordinatePoints.count];
    
    if (self) {
        _selected = selected;
        NSArray<QSegmentColor *> *segmentColors = [self getSegmentColorWithRoute:routePlan];
        _segmentColors = segmentColors;
        _routePlan = routePlan;
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected {
    if (_selected == selected) {
        return;
    }
    
    _selected = selected;
    NSArray<QSegmentColor *> *segmentColors = [self getSegmentColorWithRoute:self.routePlan];
    _segmentColors = segmentColors;
}

- (NSArray<QSegmentColor *> *)getSegmentColorWithRoute:(TNKCarRouteSearchRoutePlan *)routePlan {
    
    NSMutableArray *routeColors = [NSMutableArray array];
    NSArray<TNKRouteTrafficData *> *trafficItems = routePlan.line.initialTrafficDataArray;

    if (trafficItems.count == 0) {
        
        NSMutableArray* routeLineArray = [NSMutableArray array];
        
        QSegmentColor *color = [[QSegmentColor alloc] init];
        
        color.startIndex = 0;
        color.endIndex = (int)(routePlan.line.coordinatePoints.count - 1);
        if (self.selected) {
            color.color = [self routeTrafficStatusColor:0];
        }else {
            color.color = [self backRouteTrafficStatusColor:0];
        }
        
        [routeLineArray addObject:color];
        
        routeColors = [routeLineArray copy];
    } else {
        
        for (int i = 0; i < trafficItems.count; ++i)  {
            
            TNKRouteTrafficData *item = trafficItems[i];
            
            QSegmentColor *segmentColor = [[QSegmentColor alloc] init];
            
            segmentColor.startIndex = (int)item.from;
            segmentColor.endIndex = (int)item.to;
            if (self.selected) {
                segmentColor.color = [self routeTrafficStatusColor:item.color];
            } else {
                segmentColor.color = [self backRouteTrafficStatusColor:item.color];
            }
            
            [routeColors addObject:segmentColor];
        }
    }
    
    return routeColors;
}

- (UIColor *)colorWithHex:(long)hex {
    float red   = ((float)((hex & 0xFF0000) >> 16)) / 255.0;
    float green = ((float)((hex & 0x00FF00) >> 8))  / 255.0;
    float blue  = ((float)( hex & 0x0000FF))        / 255.0;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:1];
}

// 获取导航SDK默认路况颜色
- (UIColor *)routeTrafficStatusColor:(int)trafficDataStatus {
    
    switch (trafficDataStatus)
    {
        case 0:
        {
            return [self colorWithHex:0x05B473];
            break;
        }
        case 1:
        {
            return [self colorWithHex:0xFABB11];
            break;
        }
        case 2:
        {
            return [self colorWithHex:0xE61C3F];
            break;
        }
        case 3:
        {
            return [self colorWithHex:0x6ca4f2];
            break;
        }
        case 4:
        {
            return [self colorWithHex:0x932632];
            break;
        }
        default:
        {
            return [self colorWithHex:0xc2c2c2];
            break;
        }
    }
}

// 获取导航SDK备选路况颜色
- (UIColor *)backRouteTrafficStatusColor:(int)trafficDataStatus {
    
    switch (trafficDataStatus)
    {
        case 0:
        {
            return [self colorWithHex:0xa5dab6];
            break;
        }
        case 1:
        {
            return [self colorWithHex:0xF6D28B];
            break;
        }
        case 2:
        {
            return [self colorWithHex:0xDEADA6];
            break;
        }
        case 3:
        {
            return [self colorWithHex:0xA8C5FB];
            break;
        }
        case 4:
        {
            return [self colorWithHex:0xCA99A2];
            break;
        }
        
    }
    
    return [self colorWithHex:0xc2c2c2];
}


@end
