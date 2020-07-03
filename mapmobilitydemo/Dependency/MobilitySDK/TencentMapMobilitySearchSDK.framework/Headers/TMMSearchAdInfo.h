//
//  TMMSearchRegeoAdInfo.h
//  TencentMapMobilitySearchSDK
//
//  Created by mol on 2020/7/1.
//  Copyright © 2020 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TMMSearchAdInfo : NSObject

/**
 * @brief 行政区划代码
 */
@property (nonatomic, copy) NSString  *nationCode;

/**
 * @brief 行政区划名称
 */
@property (nonatomic, copy) NSString  *name;

/**
 * @brief 国家
 */
@property (nonatomic, copy) NSString  *nation;

/**
 * @brief 省 / 直辖市
 */
@property (nonatomic, copy) NSString  *province;

/**
 * @brief 市 / 地级区 及同级行政区划
 */
@property (nonatomic, copy) NSString  *city;

/**
 * @brief 区 / 县级市 及同级行政区划
 */
@property (nonatomic, copy, nullable) NSString  *district;

/**
 * @brief 行政区划中心点坐标
 */
@property (nonatomic, assign) CLLocationCoordinate2D location;


- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END
