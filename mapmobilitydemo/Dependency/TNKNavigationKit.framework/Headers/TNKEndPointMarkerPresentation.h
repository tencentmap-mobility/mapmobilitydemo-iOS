//
//  TNKEndPointMarkerPresentation.h
//  TNKNavigationKit
//
//  Created by Yuchen Wang on 2020/3/5.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface TNKEndPointMarkerPresentation : NSObject

/**
 *  @brief  设置终点气泡图标. 设置为nil则使用隐藏资源.
 */
@property (nonatomic, strong, nullable) UIImage *bubbleIcon;

/**
 *  @brief  设置终点圆盘图标. 设置为nil则隐藏默认资源.
 */
@property (nonatomic, strong, nullable) UIImage *diskIcon;


@end

NS_ASSUME_NONNULL_END
