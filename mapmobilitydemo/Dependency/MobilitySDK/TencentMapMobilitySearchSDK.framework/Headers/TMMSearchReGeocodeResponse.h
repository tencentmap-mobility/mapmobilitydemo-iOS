//
//  TMMSearchReGeocodeResponse.h
//  TencentMapMobilitySearchSDK
//
//  Created by mol on 2019/11/26.
//  Copyright © 2019 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class TMMSearchPOIModel, TMMSearchAddressComponent;
@interface TMMSearchReGeocodeResponse : NSObject

// 地址描述
@property (nonatomic, copy) NSString *address;
// 格式化地址
@property (nonatomic, copy, nullable) NSString *formattedAddress;
// 地址组成要素
@property (nonatomic, strong) TMMSearchAddressComponent *addressComponent;
// 周边兴趣点列表
@property (nonatomic, strong) NSArray<TMMSearchPOIModel *> *poiModels;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END
