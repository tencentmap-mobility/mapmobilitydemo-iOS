//
//  CarRoutePolyline.h
//  TencentMapLocusSynchroDemo
//
//  Created by mol on 2021/9/2.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <QMapKit/QMapKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TNKCarRouteSearchRoutePlan;

@interface CarRoutePolyline : QPolyline

@property (nonatomic, readonly) TNKCarRouteSearchRoutePlan *routePlan;

@property (nonatomic, assign) BOOL selected;

// 路线的所有分段信息
@property(nonatomic, readonly) NSArray<QSegmentColor *> *segmentColors;

/// 初始化路线polyline
/// @param routePlan 路线数据
- (instancetype)initWithRoute:(TNKCarRouteSearchRoutePlan *)routePlan;

/// 初始化路线polyline
/// @param routePlan 路线数据
/// @param selected 是否是当前选中的路线
- (instancetype)initWithRoute:(TNKCarRouteSearchRoutePlan *)routePlan selected:(BOOL)selected;

@end

NS_ASSUME_NONNULL_END
