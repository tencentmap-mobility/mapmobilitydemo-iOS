//
//  TMMSubTrafficHubModel.h
//  TencentMapMobilitySDK
//
//  Created by Yuchen Wang on 2019/11/25.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMMNearbyBoardingPlaceModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief 推荐上车点子围栏类
 */
@interface TMMSubFenceModel : NSObject

/**
 * @brief 二级围栏名称
 */
@property (nonatomic, readonly) NSString *title;

/**
* @brief 二级围栏详细名称
*/
@property (nonatomic, readonly) NSString *detailName;

/**
 * @brief 二级围栏推荐上车点集合
 */
@property (nonatomic, strong, readonly) NSArray<TMMNearbyBoardingPlaceModel *> *nearbyBoardingPlaceModels;

@end

NS_ASSUME_NONNULL_END
