//
//  QMapView+TMMobility.h
//  TencentMapMobilitySDK
//
//  Created by mol on 2019/8/8.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import <QMapKit/QMapKit.h>
#import "TMMNearbyCarConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface QMapView (TMMobility)

/**
 * @brief 当前城市的cityCode
 */
@property (nonatomic, copy, nullable) NSString *tmm_cityCode;

/**
 * @brief 中心点大头针相对位置
 * 默认为地图中心点相对位置（0.5, 0.5），相对位置取值范围均为：[0,1]
 **/
@property(nonatomic, assign) CGPoint tmm_pinPosition;

#pragma mark - 周边车辆

/**
 * @brief 是否展示周边车辆，默认为NO
 **/
@property (nonatomic, assign, getter=isNearbyCarsEnabled) BOOL nearbyCarsEnabled;

/**
 * @brief 周边车辆展示配置
 **/
@property (nonatomic, strong) TMMNearbyCarConfig *nearbyCarConfig;

/**
 * @brief 删除所有周边车辆展示
 **/
- (void)removeAllNearbyCars;

/**
 * @brief 获取周边车辆展示
 **/
- (void)getNearbyCars;


@end

NS_ASSUME_NONNULL_END
