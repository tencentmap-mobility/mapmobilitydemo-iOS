//
//  TMMNearbyCarRequest.h
//  TencentMapMobilitySDK
//
//  Created by Yuchen Wang on 2019/11/22.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMMNearbyCarConfig.h"
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief 周边车辆请求类
 */
@interface TMMNearbyCarRequest : NSObject
/**
 * @brief 中心点坐标（必传）
 */
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

/**
 * @brief 城市编码（必传）
 */
@property (nonatomic, copy) NSString *cityCode;

/**
 * @brief 其他配置信息（必传）
 */
@property (nonatomic, strong) TMMNearbyCarConfig *nearbyCarConfig;

@end

NS_ASSUME_NONNULL_END
