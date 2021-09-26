//
//  TLSDCommonObj.h
//  TencentMapLocusSynchroDriverSDK
//
//  Created by mol on 2020/3/10.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#ifndef TLSBCommonObj_h
#define TLSBCommonObj_h

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief 订单类型
 */
typedef NS_ENUM(NSInteger, TLSBOrderType) {
    TLSBOrderTypeNormal,      ///< 快车
    TLSBOrderTypeHitchRide,   ///< 顺风车
    TLSBOrderTypeRidesharing, ///< 拼车
};

/**
 * @brief 订单状态
 */
typedef NS_ENUM(NSInteger, TLSBOrderStatus) {
    TLSBOrderStatusNone = 0,        ///< 初始状态
    TLSBOrderStatusPickup = 2,      ///< 接驾状态
    TLSBOrderStatusTrip = 3,        ///< 送驾状态
};

/**
 * @brief 途经点类型
 */
typedef NS_ENUM(NSInteger, TLSBWayPointType) {
    TLSBWayPointTypeGetIn = 1,      ///< 上车点
    TLSBWayPointTypeGetOff = 2,     ///< 下车点
};

/**
 * @brief 司机状态
 */
typedef NS_ENUM(NSInteger, TLSDDriverStatus) {
    TLSDDriverStatusStopped = 0,    ///< 停止服务
    TLSDDriverStatusListening = 1,  ///< 听单中
    TLSDDriverStatusServing = 2,    ///< 服务中
};


#pragma mark - 途经点. 顺风车 拼车业务使用
/**
 * @brief 途经点信息
 */
@interface TLSBWayPoint : NSObject

/**
 * @brief 乘客订单ID
 */
@property (nonatomic, copy) NSString *pOrderID;

/**
 * @brief 途经点坐标
 */
@property (nonatomic, assign) CLLocationCoordinate2D position;

/**
 * @brief 途经点类型
 */
@property (nonatomic, assign) TLSBWayPointType wayPointType;

/**
 * @brief 途经点所在路线的点串索引，该信息在导航SDK中返回
 */
@property (nonatomic, assign) int pointIndex;

/**
 * @brief 到达途经点的剩余距离.单位：米
 */
@property (nonatomic, assign) int remainingDistance;

/**
 * @brief 到达途经点的剩余时间.单位：分钟
 */
@property (nonatomic, assign) int remainingTime;


@end

/**
 * @brief POI类。 since 2.2.0
 */
@interface TLSBNaviPOI : NSObject

/**
 * @brief  POI ID
 */
@property (nonatomic, copy, nullable) NSString *poiID;

/**
 * @brief 坐标（必传）
 */
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

/**
 * @brief poi名称
 */
@property (nonatomic, copy, nullable) NSString *poiName;

@end

#pragma mark - 轨迹点信息

/**
 * @brief 轨迹点信息
 */
@interface TLSBPosition : NSObject

/**
 * @brief 原始定位点信息
 */
@property (nonatomic, strong) CLLocation *location;

/**
 * @brief 坐标所在的城市编码
 */
@property (nonatomic, copy, nullable) NSString *cityCode;

/**
 * @brief 位置补充信息. 可上传业务信息, 配合服务端使用.
 */
@property (nonatomic, copy, nullable) NSString *extraInfo;

/**
 * @brief 是否是有效数据
 */
- (BOOL)isValid;

@end

#pragma mark - 司机轨迹点信息

/**
 * @brief 司机轨迹点信息
 */
@interface TLSDDriverPosition : TLSBPosition

/**
 * @brief 司机导航过程中的吸附点坐标。该信息在导航SDK中返回
 */
@property (nonatomic, assign) CLLocationCoordinate2D matchedCoordinate;

/**
 * @brief 司机导航过程中的吸附点方向。该信息在导航SDK中返回
 */
@property (nonatomic, assign) double matchedCourse;

/**
 * @brief 司机导航过程中的吸附点所在的路线点串索引, 未吸附/未导航时传-1。该信息在导航SDK中返回
 */
@property (nonatomic, assign) int matchedIndex;

/**
 * @brief 到达终点的剩余距离.单位：米
 */
@property (nonatomic, assign) int remainingDistance;

/**
 * @brief 到达终点的剩余时间.单位：分钟
 */
@property (nonatomic, assign) int remainingTime;

/**
 * @brief 所属路线的id，没有则为空
 */
@property (nonatomic, copy, nullable) NSString *routeID;

/**
 * @brief 途经点信息
 */
@property (nonatomic, copy, nullable) NSArray<TLSBWayPoint *> *wayPoints;

@end

#pragma mark - 路况信息

/**
 * @brief 路况信息
 */
@interface TLSBRouteTrafficItem : NSObject

/**
 * @brief 路况信息起点pointIndex
 */
@property (nonatomic, assign) int from;

/**
 * @brief 路况信息终点pointIndex
 */
@property (nonatomic, assign) int to;

/**
 * @brief 路况颜色. 0:通畅 1:缓行 2:堵塞 3:未知路况 4:严重堵塞.
 */
@property (nonatomic, assign) int color;
@end

#pragma mark - 坐标点

/**
 * @brief 坐标点协议
 */
@protocol TLSBLocation <NSObject>

/**
 * @brief 坐标
 */
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@end

/**
 * @brief 坐标点obj
 */
@interface TLSBLocationObj : NSObject <TLSBLocation>

/**
 * @brief 坐标
 */
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@end

#pragma mark - 路线信息

@class TLSBRouteSegment;

/**
 * @brief 路线信息
 */
@interface TLSBRoute : NSObject

/**
 * @brief 路线ID
 */
@property (nonatomic, copy) NSString *routeID;

/**
 * @brief 路线点串信息
 */
@property (nonatomic, copy) NSArray<id<TLSBLocation>> *points;

/**
 * @brief 路况信息
 */
@property (nonatomic, copy, nullable) NSArray<TLSBRouteTrafficItem *> *trafficItems;

/**
 * @brief 途经点信息
 */
@property (nonatomic, copy, nullable) NSArray<TLSBWayPoint *> *wayPoints;

/**
 * @brief 到达终点的剩余距离.单位：米
 */
@property (nonatomic, assign) int remainingDistance;

/**
 * @brief 到达终点的剩余时间.单位：分钟
 */
@property (nonatomic, assign) int remainingTime;


/**
 * @brief 路线标签。例如: 时间短、距离短
 */
@property (nonatomic, copy, nullable) NSString *tag;

/**
 * @brief 剩余红绿灯个数
 */
@property (nonatomic, assign) int leftTrafficCount;

@property (nonatomic, copy, nullable) NSArray<TLSBRouteSegment *> *routeSegments;

/**
 * @brief 数据是否有效
 */
- (BOOL)isValid;

@end

#pragma mark - 订单信息

/**
 * @brief  订单信息基类.
 */
@interface TLSBOrder : NSObject

/**
 * @brief 订单id
 */
@property (nonatomic, copy, nullable) NSString *identifier;

/**
 * @brief 订单类型
 */
@property (nonatomic, assign) TLSBOrderType orderType;

/**
 * @brief 订单状态
 */
@property (nonatomic, assign) TLSBOrderStatus orderStatus;

/**
 * @brief 订单总时间，单位：分钟。乘客端拉取数据中返回
 */
@property (nonatomic, readonly) int totalTime;

/**
 * @brief 订单总里程，单位：米。乘客端拉取数据中返回
 */
@property (nonatomic, readonly) int totalDistance;

/**
 * @brief 数据是否有效
 */
- (BOOL)isValid;

@end

/**
 * @brief 订单信息司机类
 */
@interface TLSDDriverOrder : TLSBOrder

/**
 * @brief 司机状态
 */
@property (nonatomic, assign) TLSDDriverStatus driverStatus;

@end

/**
 * @brief 路线分段信息
 */
@interface TLSBRouteSegment : NSObject

/**
 * @brief 路名
 */
@property (nonatomic, copy) NSString *roadName;

/**
 * @brief 路线点串起点索引
 */
@property (nonatomic, assign) int from;

/**
 * @brief 路线点串终点索引
 */
@property (nonatomic, assign) int to;

/**
 * @brief 路线长度
 */
@property (nonatomic, assign) int length;

@end

NS_ASSUME_NONNULL_END


#endif /* TLSBCommonObj_h */
