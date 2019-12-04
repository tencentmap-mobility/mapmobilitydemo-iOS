//
//  TMMNearbyStepinPointModel.h
//  TencentMapMobilitySDK
//
//  Created by Yuchen Wang on 2019/8/29.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TMMNearbyBoardingPlaceModel : NSObject

/**
 * @brief 上车点ID，需全局唯一
 */
@property (nonatomic, copy, readonly) NSString *ID;

/**
 * @brief 上车点名
 */
@property (nonatomic, copy, readonly) NSString *title;

/**
 * @brief 上车点经纬度
 */
@property (nonatomic, assign, readonly) CLLocationCoordinate2D locationCoordinate;

/**
 * @brief 到达上车点的步行距离，米为单位
 */
@property (nonatomic, assign, readonly) int distance;

@end

NS_ASSUME_NONNULL_END
