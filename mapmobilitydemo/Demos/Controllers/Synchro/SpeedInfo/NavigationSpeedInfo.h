//
//  NavigationSpeedInfo.h
//  TNKNavigationDebugging
//
//  Created by 薛程 on 2018/6/18.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NavigationSpeedInfo : UIView

- (void)updateCurrentSpeed:(int)current
                limitSpeed:(int)limit
           currentRoadName:(NSString *)road;

@end
