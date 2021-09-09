//
//  TLSRoutePolyline.m
//  TencentMapLocusSynchroDemo
//
//  Created by mol on 2021/8/31.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TLSRoutePolyline.h"
#import <TencentMapLocusSynchroSDK/TencentMapLocusSynchroSDK.h>

@implementation TLSRoutePolyline

- (instancetype)initWithRoute:(TLSBRoute *)route {
    
    return [self initWithRoute:route selected:YES];
}

- (instancetype)initWithRoute:(TLSBRoute *)route selected:(BOOL)selected {
    
    CLLocationCoordinate2D polylineCoords[route.points.count];
    
    for(int i = 0; i < route.points.count; ++i) {
        polylineCoords[i].latitude = route.points[i].coordinate.latitude;
        polylineCoords[i].longitude = route.points[i].coordinate.longitude;
    }

    self = [super initWithCoordinates:polylineCoords count:route.points.count];
    
    if (self) {
        _selected = selected;
        NSArray<QSegmentColor *> *segmentColors = [self getSegmentColorWithRoute:route];
        _segmentColors = segmentColors;
        _route = route;
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected {
    if (_selected == selected) {
        return;
    }
    
    _selected = selected;
    NSArray<QSegmentColor *> *segmentColors = [self getSegmentColorWithRoute:self.route];
    _segmentColors = segmentColors;
}

- (NSArray<QSegmentColor *> *)getSegmentColorWithRoute:(TLSBRoute *)route {
    
    NSMutableArray *routeColors = [NSMutableArray array];
    NSArray<TLSBRouteTrafficItem *> *trafficItems = route.trafficItems;

    if (trafficItems.count == 0) {
        
        NSMutableArray* routeLineArray = [NSMutableArray array];
        
        QSegmentColor *color = [[QSegmentColor alloc] init];
        
        color.startIndex = 0;
        color.endIndex = (int)(route.points.count - 1);
        if (self.selected) {
            color.color = [self routeTrafficStatusColor:0];
        }else {
            color.color = [self backRouteTrafficStatusColor:0];
        }
        
        [routeLineArray addObject:color];
        
        routeColors = [routeLineArray copy];
    } else {
        
        for (int i = 0; i < trafficItems.count; ++i)  {
            
            TLSBRouteTrafficItem *item = trafficItems[i];
            
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

- (void)updateTrafficItems:(TLSBRoute *)route {
    
    if (![route.routeID isEqualToString:self.route.routeID]) {
        return;
    }
    
    NSArray<QSegmentColor *> *segmentColors = [self getSegmentColorWithRoute:route];
    _segmentColors = segmentColors;
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
