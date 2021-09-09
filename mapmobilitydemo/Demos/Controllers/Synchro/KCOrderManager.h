//
//  KCOrderManager.h
//  TencentMapLocusSynchroDemo
//
//  Created by mol on 2021/9/8.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <TencentMapLocusSynchroSDK/TencentMapLocusSynchroSDK.h>


NS_ASSUME_NONNULL_BEGIN

@interface MyPOI : NSObject

/// 坐标
@property (nonatomic, assign) CLLocationCoordinate2D coord;

/// POI ID
@property (nonatomic, copy, nullable) NSString *poiID;

/// POI ID
@property (nonatomic, copy) NSString *poiName;

@end

@interface KCMyOrder : NSObject

// 订单id
@property (nonatomic, copy) NSString *orderID;

// 乘客id
@property (nonatomic, copy) NSString *passengerID;
// 乘客设备标识
@property (nonatomic, copy) NSString *passengerDev;

// 司机id
@property (nonatomic, copy, nullable) NSString *driverID;
// 司机设备标识
@property (nonatomic, copy, nullable) NSString *driverDev;

// 订单接驾点
@property (nonatomic, strong) MyPOI *startPOI;

// 订单送驾点
@property (nonatomic, strong) MyPOI *endPOI;

// 订单状态
@property (nonatomic, assign) TLSBOrderStatus orderStatus;

// 订单创建的城市
@property (nonatomic, copy) NSString *adCode;

@end

/// 订单管理类，包括创建订单以及订单状态流转(初始->接驾->送驾->结束)
@interface KCOrderManager : NSObject

// 单例
+ (instancetype)sharedInstance;
- (instancetype)init NS_UNAVAILABLE;

/// 创建订单
/// @param order 订单对象
/// @param completion 返回结果
- (void)createOrder:(KCMyOrder *)order completion:(void(^)(BOOL success, NSError * _Nullable error))completion;


/// 创建订单后，派单给司机，状态切换至接驾
/// @param order 订单对象
/// @param driverID 司机id
/// @param driverDev 司机设备号
/// @param driverCoord 司机接单时的位置
/// @param completion 返回结果
- (void)sendOrderToDriver:(KCMyOrder *)order
                 driverID:(NSString * _Nullable)driverID
                driverDev:(NSString * _Nullable)driverDev
              driverCoord:(CLLocationCoordinate2D)driverCoord
               completion:(void(^)(BOOL success, NSError * _Nullable error))completion;


/// 流转订单状态至送驾
/// @param order 订单对象
/// @param driverCoord 司机当前位置
/// @param completion 返回结果
- (void)changeOrderStatusToTrip:(KCMyOrder *)order
                    driverCoord:(CLLocationCoordinate2D)driverCoord
                     completion:(void(^)(BOOL success, NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
