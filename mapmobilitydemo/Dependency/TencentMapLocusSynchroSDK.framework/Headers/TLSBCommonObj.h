//
//  TLSDCommonObj.h
//  TencentMapLocusSynchroDriverSDK
//
//  Created by mol on 2020/3/10.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

// 订单类型
typedef NS_ENUM(NSInteger, TLSBOrderType) {
    TLSBOrderTypeNormal,    //快车
    TLSBOrderTypeHitchRide, //顺风车
};

// 订单状态
typedef NS_ENUM(NSInteger, TLSBOrderStatus) {
    TLSBOrderStatusNone = 0,        // 初始状态
    TLSBOrderStatusPickup = 2,      // 接驾状态
    TLSBOrderStatusTrip = 3,        // 送驾状态
};

// 途经点类型
typedef NS_ENUM(NSInteger, TLSBWayPointType) {
    TLSBWayPointTypeGetIn = 1,      // 上车点
    TLSBWayPointTypeGetOff = 2,     // 下车点
};

// 司机状态
typedef NS_ENUM(NSInteger, TLSDDriverStatus) {
    TLSDDriverStatusStopped = 0,    // 停止服务
    TLSDDriverStatusListening = 1,  // 听单中
    TLSDDriverStatusServing = 2,    // 服务中
};


#pragma mark - 途经点. 顺风车业务使用
@interface TLSBWayPoint : NSObject

// 乘客订单ID
@property (nonatomic, copy) NSString *pOrderID;

// 途经点坐标
@property (nonatomic, assign) CLLocationCoordinate2D position;

// 途经点类型
@property (nonatomic, assign) TLSBWayPointType wayPointType;

// 途经点所在路线的点串索引，该信息在导航SDK中返回
@property (nonatomic, assign) int pointIndex;

// 到达途经点的剩余距离.单位：米
@property (nonatomic, assign) int remainingDistance;

// 到达途经点的剩余时间.单位：分钟
@property (nonatomic, assign) int remainingTime;


@end

#pragma mark - 轨迹点信息
@interface TLSBPosition : NSObject

// 原始定位点信息
@property (nonatomic, strong) CLLocation *location;

// 坐标所在的城市编码
@property (nonatomic, copy, nullable) NSString *cityCode;

// 位置补充信息. 可上传业务信息, 配合服务端使用.
@property (nonatomic, copy, nullable) NSString *extraInfo;

// 是否是有效数据
- (BOOL)isValid;

@end

#pragma mark - 司机轨迹点信息
@interface TLSDDriverPosition : TLSBPosition

// 司机导航过程中的吸附点坐标。该信息在导航SDK中返回
@property (nonatomic, assign) CLLocationCoordinate2D matchedCoordinate;

// 司机导航过程中的吸附点方向。该信息在导航SDK中返回
@property (nonatomic, assign) double matchedCourse;

// 司机导航过程中的吸附点所在的路线点串索引, 未吸附/未导航时传-1。该信息在导航SDK中返回
@property (nonatomic, assign) int matchedIndex;

// 到达终点的剩余距离.单位：米
@property (nonatomic, assign) int remainingDistance;

// 到达终点的剩余时间.单位：分钟
@property (nonatomic, assign) int remainingTime;

// 所属路线的id，没有则为空
@property (nonatomic, copy, nullable) NSString *routeID;

// 途经点信息
@property (nonatomic, copy, nullable) NSArray<TLSBWayPoint *> *wayPoints;

@end

#pragma mark - 路况信息
@interface TLSBRouteTrafficItem : NSObject

// 路况信息起点pointIndex
@property (nonatomic, assign) int from;

// 路况信息终点pointIndex
@property (nonatomic, assign) int to;

// 路况颜色
@property (nonatomic, assign) int color;
@end

#pragma mark - 坐标点
@protocol TLSBLocation <NSObject>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@end

@interface TLSBLocationObj : NSObject <TLSBLocation>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@end

#pragma mark - 路线信息
@interface TLSBRoute : NSObject

// 路线ID
@property (nonatomic, copy) NSString *routeID;

// 路线点串信息
@property (nonatomic, copy) NSArray<id<TLSBLocation>> *points;

// 路况信息
@property (nonatomic, copy, nullable) NSArray<TLSBRouteTrafficItem *> *trafficItems;

// 途经点信息
@property (nonatomic, copy, nullable) NSArray<TLSBWayPoint *> *wayPoints;

// 到达终点的剩余距离.单位：米
@property (nonatomic, assign) int remainingDistance;

// 到达终点的剩余时间.单位：分钟
@property (nonatomic, assign) int remainingTime;

// 数据是否有效
- (BOOL)isValid;

@end

/**
 * @brief  订单信息基类.
 */
@interface TLSBOrder : NSObject

// 订单id
@property (nonatomic, copy, nullable) NSString *identifier;
// 订单类型
@property (nonatomic, assign) TLSBOrderType orderType;
//订单状态
@property (nonatomic, assign) TLSBOrderStatus orderStatus;

// 数据是否有效
- (BOOL)isValid;

@end

@interface TLSDDriverOrder : TLSBOrder

// 司机状态
@property (nonatomic, assign) TLSDDriverStatus driverStatus;

@end


NS_ASSUME_NONNULL_END
