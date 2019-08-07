//
//  NavigationBottomBoard.h
//  TNKNavigationDebugging
//
//  Created by 薛程 on 2018/6/18.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NavigationBottomBoard : UIView

@property (nonatomic) BOOL nightMode;

- (void)updateInfoLabelWithTotalDistanceLeft:(NSString *)distance
                                distanceUnit:(NSString *)unit
                               totalTimeLeft:(NSString *)time;

@end
