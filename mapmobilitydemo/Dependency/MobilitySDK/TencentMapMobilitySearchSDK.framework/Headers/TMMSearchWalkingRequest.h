//
//  TMMSearchWalkingRequest.h
//  TencentMapMobilitySearchSDK
//
//  Created by 张晓芳 on 2020/4/2.
//  Copyright © 2020 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN
/**
 * @brief 检索步行请求
 */
@interface TMMSearchWalkingRequest : NSObject

/**
 * @brief 起点坐标（必传）
 */
@property (nonatomic, assign) CLLocationCoordinate2D startCoordinate;

/**
 * @brief 终点坐标（必传）
 */
@property (nonatomic, assign) CLLocationCoordinate2D destinationCoordinate;

@end

NS_ASSUME_NONNULL_END
