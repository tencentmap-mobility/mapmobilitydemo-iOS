//
//  MapMathTool.h
//  mapmobilitydemo
//
//  Created by mol on 2020/4/28.
//  Copyright © 2020 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QMapKit/QMapKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TMMLocationPoint;
@interface MapMathTool : NSObject


/// 计算地图包含一系列坐标点的最小平面投影矩形
/// @param locationPoints 坐标点数组
+ (QMapRect)mapRectWithLocationPoints:(NSArray<TMMLocationPoint *> *)locationPoints;
@end

NS_ASSUME_NONNULL_END
