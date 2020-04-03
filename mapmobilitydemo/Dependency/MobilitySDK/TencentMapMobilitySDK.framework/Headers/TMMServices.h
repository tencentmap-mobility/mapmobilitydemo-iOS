//
//  TMMNaviServices.h
//  TMMNavigation
//
//  Created by tabsong on 2018/5/28.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief 出行服务类.包含鉴权,获取版本号等功能
 */
@interface TMMServices : NSObject

/**
 * @brief 获取单例
 */
+ (TMMServices *)sharedServices;

/**
 * @brief 用户的apikey
 */
@property (nonatomic, copy) NSString *apiKey;

/**
 * @brief 用户使用签名校验的方式时需填入的Secret key
 */
@property (nonatomic, copy, nullable) NSString *secretKey;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;

@end

NS_ASSUME_NONNULL_END
