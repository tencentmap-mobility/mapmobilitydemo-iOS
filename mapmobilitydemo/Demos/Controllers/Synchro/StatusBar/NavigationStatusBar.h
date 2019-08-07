//
//  NavigationStatusBar.h
//  TNKNavigationDebugging
//
//  Created by 薛程 on 2018/6/21.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TNKNavigationKit/TNKNavigationKit.h>

typedef NS_ENUM(NSUInteger, NavigationStatusBarDisplayOrientation)
{
    NavigationStatusBarDisplayOrientationLeftToRight = 0,
    NavigationStatusBarDisplayOrientationRightToLeft = 1,
    NavigationStatusBarDisplayOrientationTopToBottom = 2,
    NavigationStatusBarDisplayOrientationBottomToTop = 3,
};

@interface NavigationStatusBar : UIView

@property (nonatomic) NavigationStatusBarDisplayOrientation orientation;

- (void)updateRemainingDistance:(int)remainingDistance;

- (void)updateStatusBar:(TNKRouteTrafficStatus *)status;

@end
