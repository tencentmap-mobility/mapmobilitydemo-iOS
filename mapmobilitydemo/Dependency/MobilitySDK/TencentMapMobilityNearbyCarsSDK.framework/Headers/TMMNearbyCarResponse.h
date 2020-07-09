//
//  TMMNearbyCarResponse.h
//  TencentMapMobilitySDK
//
//  Created by Yuchen Wang on 2019/11/22.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMMNearbyCarModel.h"
NS_ASSUME_NONNULL_BEGIN

/**
 * @brief 周边车辆response类
 */
@interface TMMNearbyCarResponse : NSObject

/**
 * @brief 附近车辆信息数组
 */
@property (nonatomic, copy) NSArray< TMMNearbyCarModel *> *nearbyCars;

@end

NS_ASSUME_NONNULL_END
