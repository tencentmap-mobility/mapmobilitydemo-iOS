//
//  TMMSearchDrivingRequest.h
//  TencentMapMobilitySearchSDK
//
//  Created by 张晓芳 on 2020/4/2.
//  Copyright © 2020 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMMSearchRouteObj.h"

NS_ASSUME_NONNULL_BEGIN

@interface TMMSearchDrivingRequest : NSObject

//驾车规划的起点
@property (nonatomic, strong) TMMNaviPOI *start;

//驾车规划的终点
@property (nonatomic, strong) TMMNaviPOI *destination;

@end

NS_ASSUME_NONNULL_END
