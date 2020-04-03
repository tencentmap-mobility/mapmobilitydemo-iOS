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

@interface TMMNearbyCarResponse : NSObject

///附近车辆信息数组
@property (nonatomic, copy) NSArray< TMMNearbyCarModel *> *nearbyCars;

@end

NS_ASSUME_NONNULL_END
