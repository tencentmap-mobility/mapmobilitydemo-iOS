//
//  TMMNearbyCarModel.h
//  TencentMapMobilityDemo
//
//  Created by Yuchen Wang on 2019/8/5.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TMMNearbyCarModel : NSObject


// 司机起终点位置的驾车距离，单位米
@property (nonatomic, assign) NSInteger distance;

// 司机终点位置的纬度
@property (nonatomic, assign) float dlat;

// 司机终点位置的经度
@property (nonatomic, assign) float dlng;

// 司机起终点位置的驾车时间，单位秒
@property (nonatomic, assign) NSInteger duration;

// 司机id
@property (nonatomic, strong) NSString *ID;

// 司机起终点位置的点串索引，线路点串,纬度在前,经度在后,逗号分隔，每两个点构成一个经纬度坐标
@property (nonatomic, strong) NSArray *polyline;

// 司机起点位置的纬度
@property (nonatomic, assign) float slat;

// 司机起点位置的经度
@property (nonatomic, assign) float slng;

// 当前线路从点串中哪个位置开始，保证小车的平滑移动
@property (nonatomic, assign) NSInteger start_idx;

// 车辆类型
@property (nonatomic, strong) NSString *vehicle_types;

@end

NS_ASSUME_NONNULL_END
