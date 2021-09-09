//
//  TLSRoutePolyline.h
//  TencentMapLocusSynchroDemo
//
//  Created by mol on 2021/8/31.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <QMapKit/QMapKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TLSBRoute;

@interface TLSRoutePolyline : QPolyline

@property (nonatomic, readonly) TLSBRoute *route;

@property (nonatomic, assign) BOOL selected;

// 路线的所有分段信息
@property(nonatomic, readonly) NSArray<QSegmentColor *> *segmentColors;

/// 初始化路线polyline
/// @param route 路线数据
- (instancetype)initWithRoute:(TLSBRoute *)route;

/// 初始化路线polyline
/// @param route 路线数据
/// @param selected 是否是当前选中的路线
- (instancetype)initWithRoute:(TLSBRoute *)route selected:(BOOL)selected;

- (void)updateTrafficItems:(TLSBRoute *)route;

@end

NS_ASSUME_NONNULL_END
