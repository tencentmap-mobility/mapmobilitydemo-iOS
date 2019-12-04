//
//  QMapView+TMMobility.h
//  TencentMapMobilitySDK
//
//  Created by mol on 2019/8/8.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import <QMapKit/QMapKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TMMDCenterPinView;

@interface QMapView (TMMobility)

/**
 * @brief 当前城市的cityCode
 */
@property (nonatomic, copy, nullable) NSString *tmm_cityCode;

/**
 * @brief 中心点大头针相对位置
 * 默认为地图中心点相对位置（0.5, 0.5），相对位置取值范围均为：[0,1]
 */
@property (nonatomic, assign) CGPoint tmm_pinPosition;

/**
 * @brief 是否展示中心点大头针
 */
@property (nonatomic, assign) BOOL tmm_centerPinViewHidden;

/**
 * @brief 中心点大头针, 如果centerPinViewHidden为YES，centerPinView就为nil
 */
@property (nonatomic, strong, nullable, readonly) TMMDCenterPinView *tmm_centerPinView;

@end

NS_ASSUME_NONNULL_END
