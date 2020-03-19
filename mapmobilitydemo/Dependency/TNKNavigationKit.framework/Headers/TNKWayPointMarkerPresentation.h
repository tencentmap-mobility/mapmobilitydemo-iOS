//
//  TNKWayPointMarkerPresentation.h
//  TNKNavigationKit
//
//  Created by Yuchen Wang on 2020/3/5.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface TNKWayPointMarkerPresentation : NSObject

/**
 *  @brief  设置途径点气泡图标. 设置为nil则隐藏默认资源.  注意：途径点个数与设置途径点的bubbleIcon的个数需一致！
 */
@property (nonatomic, strong, nullable) UIImage *bubbleIcon;


@end

NS_ASSUME_NONNULL_END
