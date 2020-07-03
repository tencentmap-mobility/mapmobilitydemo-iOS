//
//  NearbyCarConfig.h
//  TencentMapMobilityDemo
//
//  Created by Yuchen Wang on 2019/8/6.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief 周边车辆配置类
 */
@interface TMMNearbyCarConfig : NSObject

/**
 * @brief 筛选距离查询位置的范围，米为单位 (必须)
 * 范围：[0,1000000]
 * 例如：radius=3000
 */
@property (nonatomic, assign) double radius;

/**
 * @brief 召回最多车辆总数，取值范围：[0,12] (必须)
 * 例如：num=5
 */
@property (nonatomic, assign) int num;

/**
 * @brief是否mock数据，默认mock=1，如果需要真实数据，mock=0 (非必须)
 * 例如：num=5
 */
@property (nonatomic, assign) int mock;


/**
 * @brief 召回车辆类型 逗号分隔，允许传多个；如果不填，默认全部召回 (必须)
 * 1.出租车
 * 2.新能源
 * 3.舒适型
 * 4.豪华型
 * 5.商务型
 * 6.经济型
 */
@property (nonatomic, copy) NSString *vehicleTypes;

/**
 * @brief 延时 （非必须）
 * 筛选司机最后更新状态的时间间隔，秒为单位
 * 范围[0,86400]
 * 如果不传，默认是：60
 */
@property (nonatomic, assign) int timeDelta;

/**
 * @brief 自定义替换车型图片 （非必须）
 * key分别可以取vehicle_types的 1～6，value对应的是自定义的图片
 */
@property (nonatomic, copy, nullable) NSDictionary<NSNumber *, UIImage *> *carIconDictionary;

/**
 * @brief 是否轮询请求周边车辆，默认为YES.如果开启，则60s重新请求一次周边车辆
 */
@property (nonatomic, assign) BOOL requestRepeatedly;

@end

NS_ASSUME_NONNULL_END
