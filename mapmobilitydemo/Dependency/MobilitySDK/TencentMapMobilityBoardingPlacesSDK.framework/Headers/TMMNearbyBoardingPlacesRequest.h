//
//  TMMNearbyBoardingPlacesRequest.h
//  TencentMapMobilitySDK
//
//  Created by Yuchen Wang on 2019/11/18.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TMMNearbyBoardingPlacesRequest : NSObject

/**
 * @brief 中心点经纬度坐标
 */
@property (nonatomic, assign) CLLocationCoordinate2D locationCoordinate;

/**
 * @brief 返回上车点最大个数限制，默认3
 */
@property (nonatomic, assign) int limit;

@end

NS_ASSUME_NONNULL_END
