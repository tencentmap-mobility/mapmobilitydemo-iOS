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

/**
 * @brief 司乘同显-司机管理类导航分类
 */
@interface TLSDriverManager (Navigation)

/**
 * @brief 驾车导航管理器, 当接到订单、导航开始之前设置它
 */
@property (nonatomic, weak) TNKCarNaviManager *carNaviManger;

/**
 * @brief 驾车导航地图类
 */
@property (nonatomic, weak) TNKCarNaviView *carNaviView;

/**
 * @brief 路线规划起点
 */
@property (nonatomic, readonly, nullable) TNKSearchNaviPoi *startPOI;

/**
 * @brief 路线规划终点
 */
@property (nonatomic, readonly, nullable) TNKSearchNaviPoi *endPOI;

/**
 * @brief 路线规划策略
 */
@property (nonatomic, readonly, nullable) TNKCarRouteSearchOption *searchOption;

/**
 * @brief 剩余途经点信息
 */
@property (nonatomic, readonly) NSArray<TLSDWayPointInfo *> *remainingWayPointInfoArray;

/**
 * @brief 途经点icon信息，可用于设置carNaviView的途经点icon
 */
@property (nonatomic, readonly) NSArray<TNKWayPointMarkerPresentation *> *wayPointMarkerPresentations;

/**
 * @brief 定位额外信息, 导航过程中会将此字段进行上报. since 2.4.4
 */
@property (nonatomic, copy, nullable) NSString *extraInfo;

/**
 * @brief 是否开启乘客选路功能
 */
@property (nonatomic, assign) BOOL passengerChooseRouteEnable;

/**
 * @brief 当前选中的路线id
 */
@property (nonatomic, readonly, nullable) NSString *selectedRouteID;

/**
 * @brief 路线规划方法
 * @param start 起点信息
 * @param end 终点信息(可为空，即无司机终点。终点和途径点不可同时为空)
 * @param wayPoints 途经点信息
 * @param option 路线规划策略
 * @param callback 路线返回值
 */
- (void)searchCarRoutesWithStart:(TNKSearchNaviPoi *)start
                             end:(TNKSearchNaviPoi * _Nullable)end
                       wayPoints:(NSArray<TLSDWayPointInfo *> * _Nullable)wayPoints
                          option:(TNKCarRouteSearchOption * _Nullable)option
                      completion:(void (^)(TNKCarRouteSearchResult *result,
                                           NSError * _Nullable error))callback;


/**
 * @brief 上报第几条路线信息。调用时机在初始路线规划（searchCarRoutesWithStart:end:wayPoints:option:completion）之后，导航开始之前。
 * @param routeIndex 路线索引
 */
- (BOOL)uploadRouteWithIndex:(NSInteger)routeIndex;

/// 上报路线。调用时机在初始路线规划（searchCarRoutesWithStart:end:wayPoints:option:completion）之后，导航开始之前。
/// @param routeID 路线ID
- (BOOL)uploadRouteWithRouteID:(NSString *)routeID;

/**
 * @brief 接到乘客订单ID为pOrderID的乘客
 * @param pOrderID 乘客订单ID
 */
- (void)arrivedPassengerStartPoint:(NSString *)pOrderID;

/**
 * @brief 送到乘客订单ID为pOrderID的乘客
 * @param pOrderID 乘客订单ID
 */
- (void)arrivedPassengerEndPoint:(NSString *)pOrderID;


/**
 * @brief 获取最优送驾顺序（无司机终点）
 * @param startPoint 起点坐标
 * @param originalWayPoints 途经点坐标,个数不能超过16个！
 * @param orderType 订单类型。可传顺风车类型或者拼车类型
 * @param completion 最优顺序回调
 */
- (NSURLSessionTask *)requestBestSortedWayPointsWithStartPoint:(CLLocationCoordinate2D)startPoint
                                                     wayPoints:(NSArray<TLSDWayPointInfo *> *)originalWayPoints
                                                     orderType:(TLSBOrderType)orderType
                                                    completion:(void (^)(NSArray<TLSDWayPointInfo *> * _Nullable sortedWayPoints,
                                                                         NSError * _Nullable error))completion;

/**
 * @brief 获取最优送驾顺序（带司机终点）
 * @param startPoint 起点坐标
 * @param originalWayPoints 途经点坐标,个数不能超过16个！
 * @param endPoint 司机的终点坐标
 * @param orderType 订单类型。可传顺风车类型或者拼车类型
 * @param completion 最优顺序回调
 */
- (NSURLSessionTask *)requestBestSortedWayPointsWithStartPoint:(CLLocationCoordinate2D)startPoint
                                                     wayPoints:(NSArray<TLSDWayPointInfo *> *)originalWayPoints
                                                      endPoint:(CLLocationCoordinate2D)endPoint
                                                     orderType:(TLSBOrderType)orderType
                                                    completion:(void (^)(NSArray<TLSDWayPointInfo *> * _Nullable sortedWayPoints,
                                                                         NSError * _Nullable error))completion;

/**
 * @brief 设置接力单信息。只支持快车
 * @param relayOrderID 接力单订单id
 * @param relayPickupPoint 接力单接驾点
 * @param curTripPoint 当前单送驾点
 * @param option 接力单接驾路线规划策略
 * @param callback 路线返回值
 */
- (void)setupRelayOrder:(NSString *)relayOrderID
       relayPickupPoint:(TNKSearchNaviPoi *)relayPickupPoint
           curTripPoint:(TNKSearchNaviPoi *)curTripPoint
                 option:(TNKCarRouteSearchOption * _Nullable)option
             completion:(void (^)(TNKCarRouteSearchResult *result, NSError * _Nullable error))callback;



/// 上报接力单路线
/// @param routeSearchRoutePlan 路线
- (BOOL)uploadRelayRoute:(TNKCarRouteSearchRoutePlan *)routeSearchRoutePlan;

/**
 * @brief 移除接力单
 */
- (void)removeRelayOrder;

/**
 * @brief 快车送驾路线规划方法. since 2.2.0
 * @param start 起点信息
 * @param end 终点信息(可为空，即无司机终点。终点和途径点不可同时为空)
 * @param wayPoints 途经点信息
 * @param option 路线规划策略
 * @param callback 路线返回值。chooseRouteInfo若有值，表示乘客选中了某条路线，开发者可以使用乘客选择的路线进行导航
 */
- (void)searchTripCarRoutesWithStart:(TNKSearchNaviPoi *)start
                                 end:(TNKSearchNaviPoi * _Nullable)end
                           wayPoints:(NSArray<TLSDWayPointInfo *> * _Nullable)wayPoints
                              option:(TNKCarRouteSearchOption * _Nullable)option
                          completion:(void (^)(TNKCarRouteSearchResult *result,
                                               NSError * _Nullable error,
                                               TLSBChooseRouteInfo * _Nullable chooseRouteInfo))callback;

/// 送驾中，导航过程修改目的地接口
/// @param endPoi 新的目的地
/// @param changeType 修改目的地类型。1代表司机修改；2代表乘客修改
/// @return 状态码。 0:成功； 1:当前非导航状态，无法修改 ；2:目的地数据不合法；3: 非送驾过程;
- (int)changeOrderDestination:(TNKSearchNaviPoi *)endPoi type:(int)changeType;

@end

NS_ASSUME_NONNULL_END
