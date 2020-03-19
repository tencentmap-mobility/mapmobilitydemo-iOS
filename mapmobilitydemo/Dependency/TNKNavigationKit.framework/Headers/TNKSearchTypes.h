//
//  TNKSearchTypes.h
//  TNKNavigation
//
//  Created by 薛程 on 2018/3/5.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
#import "TNKSearchTask.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum _TNKSearhType {
    kTNKSearchType_Car,
    kTNKSearchType_Bus,
}
TNKSearchType;


#pragma mark - TNKSearchRequest

@class TNKSearchNaviPoi, TNKSearchOption, TNKCoordinatePoint, TNKNaviToWayPointInfo;

/**
 * @brief 路线规划的起终点类型
 */
@interface TNKSearchRequest : NSObject

/**
 * @brief 路线规划的起点
 */
@property (nonatomic, strong) TNKSearchNaviPoi   *startPoint;

/**
 * @brief 路线规划的终点
 */
@property (nonatomic, strong) TNKSearchNaviPoi   *destinationPoint;


@end


#pragma mark - TNKSearchNaviPoi

/**
 * @brief 路线规划的起终途径点类型
 */
@interface TNKSearchNaviPoi : NSObject

/**
 * @brief 地点的坐标.
 */
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

/**
 * @brief 该地点的唯一标识,即poi id. 有uid时优先使用uid,
 */
@property (nonatomic,strong) NSString   *uid;


@end

#pragma mark - TNKNaviToWayPointInfo

/**
 * @brief 路线规划返回的途径点类型
*/
@interface TNKNaviToWayPointInfo : NSObject

/**
 * @brief 吸附的坐标.
 */
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

/**
 * @brief 原始的坐标.
 */
@property (nonatomic, assign) CLLocationCoordinate2D originalCoordinate;

/**
 * @brief 该地点的唯一标识,即poi id. 有uid时优先使用uid,
 */
@property (nonatomic,strong) NSString   *uid;

/**
 * @brief 途径点index
*/
@property (nonatomic, assign) int wayPointIndex;

/**
 * @brief 当前位置到途径点剩余距离， 单位：米
*/
@property (nonatomic, assign) int remainingDistance;

/**
 * @brief 当前位置到途径点剩余时间，单位：分钟
 */
@property (nonatomic, assign) int remainingTime;

@end

#pragma mark - TNKSearchOption

/**
 * @brief 路线规划的参数配置
 */
@interface TNKSearchOption : NSObject

/**
 * @brief 规划类型
 */
@property (nonatomic, assign) TNKSearchType type;

@end


#pragma mark - TNKRouteSearchResult

/**
 * @brief 路线规划的所有路线结果集合
 */
@interface TNKRouteSearchResult : NSObject

@end


#pragma mark - TNKSearchRoutePlan

@class TNKSearchRouteLine;

/**
 * @brief 路线规划的一条可选路线
 */
@interface TNKSearchRoutePlan : NSObject

/**
 * @brief 路线ID
 */
@property (nonatomic, readonly) NSString *routeID;

/**
 * @brief 总距离. 单位，米
 */
@property (nonatomic, readonly) int totalDistance;

/**
 * @brief 总预计时间. 单位，分钟
 */
@property (nonatomic, readonly) int totalTime;

@end


#pragma mark - TNKSearchRouteLine

/**
 * @brief 路线规划的一条可选路线的线段
 */
@interface TNKSearchRouteLine : NSObject

/**
 * @brief 路线规划的起点
 */
@property (nonatomic, strong) TNKSearchNaviPoi  *startPoint;

/**
 * @brief 路线规划的终点
 */
@property (nonatomic, strong) TNKSearchNaviPoi  *destinationPoint;

/**
 * @brief 道路信息的坐标点串
 */
@property (nonatomic, strong, readonly) NSArray<TNKCoordinatePoint *> *coordinatePoints;

@end

NS_ASSUME_NONNULL_END
