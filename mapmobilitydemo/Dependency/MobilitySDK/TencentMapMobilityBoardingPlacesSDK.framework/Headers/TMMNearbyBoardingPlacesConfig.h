//
//  TMMNearbyBoardingPlacesConfig.h
//  TencentMapMobilitySDK
//
//  Created by Yuchen Wang on 2019/9/2.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface TMMNearbyBoardingPlacesConfig : NSObject

/**
 * @brief 推荐上车点图片。 不填为默认值
 */
@property (nonatomic, copy) UIImage *nearbyBoardingPlacesImage;

/**
 * @brief 推荐上车点文字颜色。 不填为默认值
 */
@property (nonatomic, copy) UIColor *textColor;

/**
 * @brief 推荐上车点文字边界颜色。 不填为默认值白色
 */
@property (nonatomic, copy) UIColor *borderColor;

/**
 * @brief 推荐上车点文字边界宽度。 不填为默认值2
 */
@property (nonatomic, assign) int borderWidth;

/**
 * @brief 返回上车点个数，最大支持3个， 默认为3个
 */
@property (nonatomic, assign) int limit;

/**
 * @brief 上车点允许获取和显示的最小地图缩放级别，默认16
 */
@property (nonatomic, assign) CGFloat minMapZoomLevel;

/**
 * @brief 上车点是否进行吸附，默认吸附
 */
@property (nonatomic, assign) BOOL isAbsorbed;

/**
 * @brief 上车点自动吸附距离阈值，此值自动吸附，单位m，默认50，取值范围[0,100]
 */
@property (nonatomic, assign) CGFloat absorbThreshold;

@end

NS_ASSUME_NONNULL_END
