//
//  TMMMathTool.h
//  TMMNavigation
//
//  Created by 薛程 on 2018/5/3.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface TMMMathTool : NSObject

// 两个坐标点之间的直线距离，单位：米
+ (double)distanceBetweenCoordinate:(CLLocationCoordinate2D)coordinate1
                         coordinate:(CLLocationCoordinate2D)coordinate2;


@end
