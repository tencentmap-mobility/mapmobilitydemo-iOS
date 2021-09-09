//
//  TLSPassengerManager.h
//  TencentMapLocusSynchroPassengerSDK
//
//  Created by ikaros on 2020/3/11.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TLSPCommonObj.h"

NS_ASSUME_NONNULL_BEGIN

@class TLSPConfig, TLSPassengerManager;

/**
 * @brief 司乘同显-乘客管理类代理
 */
@protocol TLSPassengerManagerDelegate <NSObject>

@optional

/**
 * @brief 上报定位成功回调
 * @param passengerManager 乘客端管理类
 */
- (void)tlsPassengerManagerDidUploadLocationSuccess:(TLSPassengerManager *)passengerManager;

/**
 * @brief 上报定位失败回调
 * @param passengerManager 乘客端管理类
 * @param error 错误信息
 */
- (void)tlsPassengerManagerDidUploadLocationFail:(TLSPassengerManager *)passengerManager error:(NSError *)error;

/**
 * @brief 乘客拉取司机信息成功回调
 * @param passengerManager 乘客端管理类
 * @param fetchedData 乘客拉取司机的信息
 */
- (void)tlsPassengerManager:(TLSPassengerManager *)passengerManager didFetchedData:(TLSPFetchedData *)fetchedData;

/**
 * @brief 拉取司机信息失败回调
 * @param passengerManager 乘客端管理类
 * @param error 错误信息
 */
- (void)tlsPassengerManager:(TLSPassengerManager *)passengerManager didFailWithError:(NSError *)error;


/**
 * @brief 发起选路请求成功回调. since 2.2.0
 * @param passengerManager 乘客端管理类
 */
- (void)tlsPassengerManagerDidSendRouteRequestSuccess:(TLSPassengerManager *)passengerManager;

/**
 * @brief 发起选路请求失败回调. since 2.2.0
 * @param passengerManager 乘客端管理类
 * @param error 错误信息
 */
- (void)tlsPassengerManagerDidSendRouteRequestFail:(TLSPassengerManager *)passengerManager error:(NSError *)error;

@end

/**
 * @brief 司乘同显-乘客管理类
 */
@interface TLSPassengerManager : NSObject

/**
 * @brief 司乘同显-乘客管理类代理
 */
@property (nonatomic, weak) id<TLSPassengerManagerDelegate> delegate;

/**
 * @brief 主订单ID
 */
@property (nonatomic, copy, nullable) NSString *orderID;

/**
 * @brief 乘客订单ID，顺风车时主订单id和乘客的订单ID不同，需要赋值此属性
 */
@property (nonatomic, copy, nullable) NSString *pOrderID;

/**
 * @brief 订单类型
 */
@property (nonatomic, assign) TLSBOrderType orderType;

/**
 * @brief 订单状态。如果是顺风车订单，开始服务时请切换至TLSDOrderStatusTrip状态
 */
@property (nonatomic, assign) TLSBOrderStatus orderStatus;

/**
 * @brief 同步司机数据的时间间隔. 默认时间间隔为5秒.
 */
@property (nonatomic, assign) NSTimeInterval syncTimeInterval;

/**
 * @brief 司乘同显服务是否开启
 */
@property (nonatomic, readonly) BOOL isRunning;

/**
 * @brief 是否开启上传乘客位置，默认为NO
 */
@property (nonatomic, assign) BOOL uploadPassengerPositionsEnabled;

/**
 * @brief 是否获取所有的路线、定位信息。 顺风车/拼车场景如果开启，需要开发者自行进行过滤和截取。默认为NO
 */
@property (nonatomic, assign) BOOL driverAllSyncDataEnabled;

/**
 * @brief 初始化乘客管理类
 * @param config 乘客端配置信息
 */
- (instancetype)initWithConfig:(TLSPConfig *)config;

/**
 * @brief 开始拉取信息。乘客拉取司机的信息。
 */
- (void)start;

/**
 * @brief 结束拉取信息
 */
- (void)stop;

/**
 * @brief 乘客需要调用该方法上报乘客轨迹点
 * @param position 轨迹点信息
 */
- (void)uploadPosition:(TLSBPosition *)position;

/**
 * @brief 清除订单信息。当订单结束时调用该方法，使得orderID = nil; orderStatus = TLSPOrderStatusNone;
 */
- (void)resetOrderInfo;

/**
 * @brief 行前驾车路线规划. since 2.2.0
 * @param request 驾车请求参数
 * @param completion 驾车请求结果
 * @return 请求Task
 */
- (NSURLSessionTask * _Nullable)queryDrivingWithRequest:(TLSPSearchDrivingRequest *)request
                                             completion:(void(^)(TLSPSearchDrivingResponse * _Nullable response,
                                                                 NSError * _Nullable error))completion;

/// 送驾中乘客选路方法. since 2.2.0
/// @param route 路线信息。路线信息中routeID不可为空
- (void)chooseRouteWhenTrip:(TLSBRoute *)route;

/// 送驾前乘客选择送驾路线方法. since 2.2.0
/// @param route 路线信息。
- (void)chooseRouteBeforeTrip:(TLSBRoute *)route;

@end

/**
 * @brief 乘客端配置信息
 */
@interface TLSPConfig: NSObject

/**
 * @brief 司乘同显的Key。注意：司机端与乘客端需要使用相同的key
 */
@property (nonatomic, copy) NSString *key;

/**
 * @brief 司乘同显的secretKey， 如果鉴权方式不是签名校验则无需填写。在https://lbs.qq.com/的控制台->应用管理->我的应用中查看
 */
@property (nonatomic, copy, nullable) NSString *secretKey;

/**
 * @brief 乘客id
 */
@property (nonatomic, copy) NSString *passengerID;

/**
 * @brief deviceID 设备标识，默认取自idfv。排查问题时需提供此identifier。注意，卸载重装时deviceID可能发生变化。
 * 如果希望使用自己业务上的设备标识来排查问题，可以将deviceID修改为自己业务上的设备标识。
 */
@property (nonatomic, copy) NSString *deviceID;

@end

NS_ASSUME_NONNULL_END
