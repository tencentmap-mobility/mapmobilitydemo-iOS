//
//  TMMSearchPOIModel.h
//  TencentMapMobilitySearchSDK
//
//  Created by mol on 2019/11/25.
//  Copyright © 2019 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief 检索POI模型类
 */
@interface TMMSearchPOIModel : NSObject

/**
 * @brief 兴趣点id
 */
@property (nonatomic, readonly) NSString *poiID;

/**
 * @brief 名称
 */
@property (nonatomic, readonly) NSString *title;

/**
 * @brief 地址
 */
@property (nonatomic, readonly) NSString *address;

/**
 * @brief 城市编号
 */
@property (nonatomic, readonly, nullable) NSString *adcode;

/**
 * @brief 省
 */
@property (nonatomic, readonly, nullable) NSString *province;

/**
 * @brief 市
 */
@property (nonatomic, readonly, nullable) NSString *city;

/**
 * @brief 逆地址解析返回的坐标与此poi的距离
 */
@property (nonatomic, readonly) int distance;

/**
 * @brief 逆地址解析的定位点是否在此poi面内
 */
@property (nonatomic, readonly) BOOL inner;

/**
 * @brief 逆地址解析的定位点与此poi的的方位关系，如：北、南、内
 */
@property (nonatomic, readonly) NSString *dirDesc;

/**
 * @brief 兴趣点坐标
 */
@property (nonatomic, readonly) CLLocationCoordinate2D locationCoordinate;

/**
 * @brief 两个poi可能存在父子关系， 子poi会有parentPOIID
 */
@property (nonatomic, readonly, nullable) NSString *parentPOIID;

/**
 * @brief 父poi可能存在多个子poi
 */
@property (nonatomic, readonly, nullable) NSArray<TMMSearchPOIModel *> *subPOIModels;

@end

NS_ASSUME_NONNULL_END
