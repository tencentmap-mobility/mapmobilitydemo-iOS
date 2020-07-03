//
//  TMMSearchReGeocodeResponse.h
//  TencentMapMobilitySearchSDK
//
//  Created by mol on 2019/11/26.
//  Copyright © 2019 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TMMSearchAddressComponent, TMMSearchPOIModel, TMMSearchAdInfo;
NS_ASSUME_NONNULL_BEGIN

/**
 * @brief 逆地址解析response类
 */
@interface TMMSearchReGeocodeResponse : NSObject

/**
 * @brief 地址描述
 */
@property (nonatomic, copy) NSString *address;

/**
 * @brief 逆地址解析所在城市adcode
 */
@property (nonatomic, copy) NSString *adcode;

/**
 * @brief 格式化地址
 */
@property (nonatomic, copy, nullable) NSString *formattedAddress;

/**
 * @brief adinfo
 */
@property (nonatomic, strong) TMMSearchAdInfo *adInfo;

/**
 * @brief 地址组成要素
 */
@property (nonatomic, strong) TMMSearchAddressComponent *addressComponent;

/**
 * @brief 周边兴趣点列表
 */
@property (nonatomic, strong) NSArray<TMMSearchPOIModel *> *poiModels;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END
