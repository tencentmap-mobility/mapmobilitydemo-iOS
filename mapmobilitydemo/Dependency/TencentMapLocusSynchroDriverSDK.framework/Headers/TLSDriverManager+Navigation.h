//
//  TLSDriverManager+Navigation.h
//  TencentMapLocusSynchroDriverSDK
//
//  Created by mol on 2020/3/10.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TLSDriverManager.h"
#import <TNKNavigationKit/TNKNavigationKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TLSDWayPointInfo, TLSDSortRequestWayPoint;

@interface TLSDriverManager (Navigation)

// 驾车导航管理器, 当接到订单、导航开始之前设置它
@property (nonatomic, weak) TNKCarNaviManager *carNaviManger;

// 驾车导航地图类
@property (nonatomic, weak) TNKCarNaviView *carNaviView;

// 路线规划起点
@property (nonatomic, readonly, nullable) TNKSearchNaviPoi *startPOI;
// 路线规划终点
@property (nonatomic, readonly, nullable) TNKSearchNaviPoi *endPOI;
// 路线规划策略
@property (nonatomic, readonly, nullable) TNKCarRouteSearchOption *searchOption;
// 剩余途经点信息
@property (nonatomic, readonly) NSArray<TLSDWayPointInfo *> *remainingWayPointInfoArray;

/// 路线规划方法
/// @param start 起点信息
/// @param end 终点信息
/// @param wayPoints 途经点信息
/// @param option 路线规划策略
/// @param callback 路线返回值
- (void)searchCarRoutesWithStart:(TNKSearchNaviPoi *)start
                             end:(TNKSearchNaviPoi *)end
                       wayPoints:(NSArray<TLSDWayPointInfo *> * _Nullable)wayPoints
                          option:(TNKCarRouteSearchOption * _Nullable)option
                      completion:(void (^)(TNKCarRouteSearchResult *result, NSError * _Nullable error))callback;


/// 上报第几条路线信息。调用时机在初始路线规划（searchCarRoutesWithStart:end:wayPoints:option:completion）之后，导航开始之前。
/// @param routeIndex 路线索引
- (BOOL)uploadRouteWithIndex:(NSInteger)routeIndex;

// 接到乘客订单ID为pOrderID的乘客
- (void)arrivedPassengerStartPoint:(NSString *)pOrderID;

// 送到乘客订单ID为pOrderID的乘客
- (void)arrivedPassengerEndPoint:(NSString *)pOrderID;

/// 获取最优送驾顺序
/// @param startPoint 起点坐标
/// @param endPoint 终点坐标
/// @param originalWayPoints 途经点坐标,个数不能超过10个！
/// @param completion 最优顺序回调
- (NSURLSessionTask *)requestBestSortedWayPointsWithStartPoint:(CLLocationCoordinate2D)startPoint
                                                      endPoint:(CLLocationCoordinate2D)endPoint
                                                     wayPoints:(NSArray<TLSDWayPointInfo *> *)originalWayPoints
                                                    completion:(void(^)(NSArray<TLSDWayPointInfo *> * _Nullable sortedWayPoints, NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
