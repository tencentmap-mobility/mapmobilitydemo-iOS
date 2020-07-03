//
//  TMMSearchDrivingResponse.h
//  TencentMapMobilitySearchSDK
//
//  Created by 张晓芳 on 2020/4/2.
//  Copyright © 2020 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMMSearchRouteObj.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief 驾车response类
 */
@interface TMMSearchDrivingResponse : NSObject

/**
 * @brief 请求id，有问题可提供requestID方便排查
 */
@property (nonatomic, readonly) NSString *requestID;

/**
 * @brief status为0时请求成功
 */
@property (nonatomic, readonly) NSInteger status;

/**
 * @brief 导航路线信息
 */
@property (nonatomic, readonly, nullable) NSArray<TMMCarNaviRoute *> *routes;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END
