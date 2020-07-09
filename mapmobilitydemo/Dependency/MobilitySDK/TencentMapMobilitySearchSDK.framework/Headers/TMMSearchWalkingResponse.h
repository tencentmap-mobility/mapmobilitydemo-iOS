//
//  TMMSearchWalkingResponse.h
//  TencentMapMobilitySearchSDK
//
//  Created by 张晓芳 on 2020/4/2.
//  Copyright © 2020 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMMSearchRouteObj.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief 步行 response
 */
@interface TMMSearchWalkingResponse : NSObject

/**
 * @brief status为0时请求成功
 */
@property (nonatomic, readonly) NSInteger status;

/**
 * @brief 步行路线
 */
@property (nonatomic, readonly, nullable) NSArray<TMMWalkingNaviRoute *>*routes;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END
