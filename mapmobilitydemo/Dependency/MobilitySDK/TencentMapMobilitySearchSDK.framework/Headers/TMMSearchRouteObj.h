//
//  TMMSearchRouteObj.h
//  TencentMapMobilitySearchSDK
//
//  Created by mol on 2020/4/2.
//  Copyright © 2020 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief 坐标点信息
 */
@interface TMMLocationPoint : NSObject

/**
 * @brief 坐标（必传）
 */
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@end

/**
 * @brief 路线规划参数
 */
@interface TMMNaviPOI : TMMLocationPoint

/**
 * @brief  POI ID
 */
@property (nonatomic, copy) NSString *poiID;

@end

/**
 * @brief 路况信息
 */
@interface TMMTrafficItem : NSObject

/**
 * @brief 开始的路线点串索引
 */
@property (nonatomic, readonly) NSInteger from;

/**
 * @brief 结束的路线点串索引
 */
@property (nonatomic, readonly) NSInteger to;

/**
 * @brief 路况颜色。0:通畅 1:缓行 2:堵塞 3:未知路况 4:严重堵塞.
 */
@property (nonatomic, readonly) NSInteger color;
@end

/**
 * @brief 驾车路线
 */
@interface TMMCarNaviRoute : NSObject

/**
 * @brief 距离，单位：米
 */
@property (nonatomic, readonly) NSInteger distance;

/**
 * @brief 预估时间，单位：分钟
 */
@property (nonatomic, readonly) NSInteger duration;

/**
 * @brief 路线点串信息
 */
@property (nonatomic, readonly) NSArray<TMMLocationPoint *> *points;

/**
 * @brief 路况信息
 */
@property (nonatomic, readonly) NSArray<TMMTrafficItem *> *trafficItems;

@end

/**
 * @brief 步行路线
 */
@interface TMMWalkingNaviRoute : NSObject

/**
 * @brief 距离，单位：米
 */
@property (nonatomic, readonly) NSInteger distance;

/**
 * @brief 预估时间，单位：分钟
 */
@property (nonatomic, readonly) NSInteger duration;

/**
 * @brief 方案整体方向
 */
@property (nonatomic, readonly) NSString *direction;

/**
 * @brief 路线点串信息
 */
@property (nonatomic, readonly) NSArray<TMMLocationPoint *> *points;

@end

NS_ASSUME_NONNULL_END
