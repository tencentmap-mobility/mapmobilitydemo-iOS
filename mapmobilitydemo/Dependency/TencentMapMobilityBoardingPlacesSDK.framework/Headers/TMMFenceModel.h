//
//  TMMTrafficHubModel.h
//  TencentMapMobilitySDK
//
//  Created by Yuchen Wang on 2019/11/25.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMMNearbyBoardingPlaceModel.h"
#import "TMMSubFenceModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TMMFenceModel : NSObject

/**
 * @brief 所有二级围栏模型集合
 */
@property (nonatomic, strong) NSArray <TMMSubFenceModel *> *subFenceModels;

/**
 * @brief 命中的二级围栏模型
 */
@property (nonatomic, strong, readonly) TMMSubFenceModel *selectedSubFenceModel;

/**
 * @brief 命中的二级围栏index
 */
@property (nonatomic, assign, readonly) NSUInteger selectedSubFenceIndex;

@end

NS_ASSUME_NONNULL_END
