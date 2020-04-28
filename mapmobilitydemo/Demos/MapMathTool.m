//
//  MapMathTool.m
//  mapmobilitydemo
//
//  Created by mol on 2020/4/28.
//  Copyright © 2020 tencent. All rights reserved.
//

#import "MapMathTool.h"
#import <TencentMapMobilitySearchSDK/TMMSearch.h>

@implementation MapMathTool

+ (QMapRect)mapRectWithLocationPoints:(NSArray<TMMLocationPoint *> *)locationPoints {
    
    if (locationPoints.count == 0) {
        return QMapRectMake(0, 0, 0, 0);
    }
    
    QMapPoint firstMapPoint = QMapPointForCoordinate(locationPoints.firstObject.coordinate);
    
    CGFloat minX = firstMapPoint.x;
    CGFloat minY = firstMapPoint.y;
    CGFloat maxX = minX;
    CGFloat maxY = minY;
    
    for (int i = 1; i < locationPoints.count; i++)
    {
        QMapPoint point = QMapPointForCoordinate(locationPoints[i].coordinate);
        
        if (point.x < minX)
        {
            minX = point.x;
        }
        
        if (point.x > maxX)
        {
            maxX = point.x;
        }
        
        if (point.y < minY)
        {
            minY = point.y;
        }
        
        if (point.y > maxY)
        {
            maxY = point.y;
        }
    }
    
    CGFloat width  = fabs(maxX - minX);
    CGFloat height = fabs(maxY - minY);
    
    return QMapRectMake(minX, minY, width, height);
}
@end
