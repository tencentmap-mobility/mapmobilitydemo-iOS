//
//  TMMSearchAddressComponent.h
//  TencentMapMobilitySearchSDK
//
//  Created by mol on 2019/11/26.
//  Copyright © 2019 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief 地址信息
 */
@interface TMMSearchAddressComponent : NSObject

/**
 * @brief 国家
 */
@property (nonatomic, copy) NSString  *nation;

/**
 * @brief 省
 */
@property (nonatomic, copy) NSString  *province;

/**
 * @brief 市
 */
@property (nonatomic, copy) NSString  *city;

/**
 * @brief 区，可能为空字串
 */
@property (nonatomic, copy, nullable) NSString  *district;

/**
 * @brief 街道，可能为空字串
 */
@property (nonatomic, copy, nullable) NSString  *street;

/**
 * @brief 门牌，可能为空字串
 */
@property (nonatomic, copy, nullable) NSString  *streetNumber;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END
