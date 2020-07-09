//
//  TMMNearbyBoardingPlacesResponse.h
//  TencentMapMobilitySDK
//
//  Created by Yuchen Wang on 2019/11/18.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMMNearbyBoardingPlaceModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief 推荐上车点error domain
 */
extern NSString *const TMMBoardingPlaceErrorDomain;

/**
 * @brief 推荐上车点response类
 */
@interface TMMNearbyBoardingPlacesResponse : NSObject

/**
 * @brief 服务端返回上车点个数
 */
@property (nonatomic, assign) int nearbyBoardingPlacesCount;

/**
 * @brief 上车点信息数组
 */
@property (nonatomic, strong) NSArray<TMMNearbyBoardingPlaceModel *> *nearbyBoardingPlaces;


@end

NS_ASSUME_NONNULL_END
