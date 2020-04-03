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

@interface TMMSearchWalkingRequest : NSObject

// 起点坐标（必传）
@property (nonatomic, assign) CLLocationCoordinate2D startCoordinate;

//终点坐标（必传）
@property (nonatomic, assign) CLLocationCoordinate2D destinationCoordinate;

@end

NS_ASSUME_NONNULL_END
