//
//  TLSPassengerManager.h
//  TencentMapLocusSynchroPassengerSDK
//
//  Created by Yuchen Wang on 2020/3/11.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TLSPCommonObj.h"

NS_ASSUME_NONNULL_BEGIN

@class TLSPConfig, TLSPassengerManager;

@protocol TLSPassengerManagerDelegate <NSObject>

@optional

// 上报定位成功回调
- (void)tlsPassengerManagerDidUploadLocationSuccess:(TLSPassengerManager *)passengerManager;
// 上报定位失败回调
- (void)tlsPassengerManagerDidUploadLocationFail:(TLSPassengerManager *)passengerManager error:(NSError *)error;
// 拉取司机信息成功回调
- (void)tlsPassengerManager:(TLSPassengerManager *)passengerManager didFetchedData:(TLSPFetchedData*)fetchedData;
// 拉取司机信息失败回调
- (void)tlsPassengerManager:(TLSPassengerManager *)passengerManager didFailWithError:(NSError *)error;
@end


@interface TLSPassengerManager : NSObject

@property (nonatomic, weak) id<TLSPassengerManagerDelegate> delegate;
// 主订单ID
@property (nonatomic, copy, nullable) NSString *orderID;
// 乘客订单ID，顺风车时主订单id和乘客的订单ID不同，需要赋值此属性
@property (nonatomic, copy, nullable) NSString *pOrderID;

// 订单类型
@property (nonatomic, assign) TLSBOrderType orderType;

// 订单状态。如果是顺风车订单，开始服务时请切换至TLSDOrderStatusTrip状态
@property (nonatomic, assign) TLSBOrderStatus orderStatus;

// 同步司机数据的时间间隔. 默认时间间隔为5秒.
@property (nonatomic, assign) NSTimeInterval syncTimeInterval;

// 司乘同显服务是否开启
@property (nonatomic, readonly) BOOL isRunning;

// 是否开启上传乘客位置，默认为NO
@property (nonatomic, assign) BOOL uploadPassengerPositionsEnabled;

// 初始化乘客管理类
- (instancetype)initWithConfig:(TLSPConfig *)config;

// 乘客需要调用该方法上报乘客轨迹点
- (void)uploadPosition:(TLSBPosition *)position;

// 清除订单信息。当订单结束时调用该方法，使得orderID = nil; orderStatus = TLSPOrderStatusNone;
- (void)resetOrderInfo;

// 开始拉取信息。乘客拉取司机的信息。
- (void)start;

// 结束拉取信息
- (void)stop;

@end

@interface TLSPConfig: NSObject

// 司乘同显的Key。注意：司机端与乘客端需要使用相同的key
@property (nonatomic, copy) NSString *key;

// 乘客id
@property (nonatomic, copy) NSString *passengerID;

 /**
 * @brief deviceID 设备标识，默认取自idfv。排查问题时需提供此identifier。注意，卸载重装时deviceID可能发生变化。
 * 如果希望使用自己业务上的设备标识来排查问题，可以将deviceID修改为自己业务上的设备标识。
 */
@property (nonatomic, copy) NSString *deviceID;
@end

NS_ASSUME_NONNULL_END
