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

@interface TMMSearchDrivingResponse : NSObject

// 请求id，有问题可提供requestID方便排查
@property (nonatomic, readonly) NSString *requestID;

// status为0时请求成功
@property (nonatomic, readonly) NSInteger status;

@property (nonatomic, readonly, nullable) NSArray<TMMCarNaviRoute *> *routes;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END
