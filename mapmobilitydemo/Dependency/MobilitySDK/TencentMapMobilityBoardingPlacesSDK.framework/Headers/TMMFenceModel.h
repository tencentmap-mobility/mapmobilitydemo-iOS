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

/**
 * @brief 推荐上车点围栏模型类
 */
@interface TMMFenceModel : NSObject

/**
 * @brief 一级围栏名称
 */
@property (nonatomic, readonly) NSString *title;

/**
 * @brief 所有二级围栏模型集合
 */
@property (nonatomic, readonly) NSArray <TMMSubFenceModel *> *subFenceModels;

/**
 * @brief 命中的二级围栏模型
 */
@property (nonatomic, readonly) TMMSubFenceModel *selectedSubFenceModel;

/**
 * @brief 命中的二级围栏index
 */
@property (nonatomic, assign, readonly) NSUInteger selectedSubFenceIndex;

@end

NS_ASSUME_NONNULL_END
