//
//  TMMNearbyCarModel.h
//  TencentMapMobilityDemo
//
//  Created by Yuchen Wang on 2019/8/5.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief 周边车辆模型类
 */
@interface TMMNearbyCarModel : NSObject

/**
 * @brief 司机起终点位置的驾车距离，单位米
 */
@property (nonatomic, assign) NSInteger distance;

/**
 * @brief 司机终点位置的纬度
 */
@property (nonatomic, assign) float dlat;

/**
 * @brief 司机终点位置的经度
 */
//
@property (nonatomic, assign) float dlng;

/**
 * @brief 司机起终点位置的驾车时间，单位秒
 */
//
@property (nonatomic, assign) NSInteger duration;

/**
 * @brief 司机id
 */
@property (nonatomic, strong) NSString *ID;

/**
 * @brief 司机起终点位置的点串索引，线路点串,纬度在前,经度在后,逗号分隔，每两个点构成一个经纬度坐标
 */
@property (nonatomic, strong) NSArray *polyline;

/**
 * @brief 司机起点位置的纬度
 */
@property (nonatomic, assign) float slat;

/**
 * @brief 司机起点位置的经度
 */
@property (nonatomic, assign) float slng;

/**
 * @brief 当前线路从点串中哪个位置开始，保证小车的平滑移动
 */
@property (nonatomic, assign) NSInteger start_idx;

/**
 * @brief 车辆类型
 */
@property (nonatomic, strong) NSString *vehicle_types;

@end

NS_ASSUME_NONNULL_END
