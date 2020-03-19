//
//  TLSDCommonObj.h
//  TencentMapLocusSynchroDriverSDK
//
//  Created by mol on 2020/3/10.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <TencentMapLocusSynchroSDK/TLSBCommonObj.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TLSDConfig: NSObject

// 司乘同显的Key。注意：司机端与乘客端需要使用相同的key
@property (nonatomic, copy) NSString *key;

// 司机id
@property (nonatomic, copy) NSString *driverID;

 /**
 * @brief deviceID 设备标识，默认取自idfv。排查问题时需提供此identifier。注意，卸载重装时deviceID可能发生变化。
 * 如果希望使用自己业务上的设备标识来排查问题，可以将deviceID修改为自己业务上的设备标识。
 */
@property (nonatomic, copy) NSString *deviceID;

@end


// 顺风车业务使用。路线规划时需要设置的途经点信息。顺风车业务使用
@interface TLSDWayPointInfo : NSObject

// 乘客订单号，必填
@property (nonatomic, copy) NSString *pOrderID;

// 途经点类型
@property (nonatomic, assign) TLSBWayPointType wayPointType;

// 途经点POI ID
@property (nonatomic, copy, nullable) NSString *poiID;

// 途经点位置坐标
@property (nonatomic, assign) CLLocationCoordinate2D position;

// 途经点展示图片，不设置就不展示
@property (nonatomic, strong, nullable) UIImage *image;

@end

// 顺风车业务使用。路线规划之前需要对途经点进行排序，TLSDWayPointRequest为请求排序时的途经点参数
@interface TLSDSortRequestWayPoint : NSObject

// 乘客订单号，必填
@property (nonatomic, copy) NSString *pOrderID;

// 订单起点
@property (nonatomic, assign) CLLocationCoordinate2D startPoint;

// 订单终点
@property (nonatomic, assign) CLLocationCoordinate2D endPoint;

@end


@interface TLSDFetchedData : NSObject

// 服务端的订单信息
@property (nonatomic, readonly) TLSBOrder *order;

// 乘客的轨迹信息
@property (nonatomic, readonly, nullable) NSArray<TLSBPosition *> *positions;

@end

NS_ASSUME_NONNULL_END
