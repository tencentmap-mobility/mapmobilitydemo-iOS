//
//  TMMSearchAddressComponent.h
//  TencentMapMobilitySearchSDK
//
//  Created by mol on 2019/11/26.
//  Copyright © 2019 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TMMSearchAddressComponent : NSObject

// 国家
@property (nonatomic, copy) NSString  *nation;
// 省
@property (nonatomic, copy) NSString  *province;
// 市
@property (nonatomic, copy) NSString  *city;
// 区，可能为空字串
@property (nonatomic, copy, nullable) NSString  *district;
// 街道，可能为空字串
@property (nonatomic, copy, nullable) NSString  *street;
// 门牌，可能为空字串
@property (nonatomic, copy, nullable) NSString  *streetNumber;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
@end

NS_ASSUME_NONNULL_END
