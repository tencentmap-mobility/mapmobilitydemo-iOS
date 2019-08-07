//
//  MathTool.h
//  TNKNavigationDebugging
//
//  Created by 薛程 on 2018/6/19.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QMapKit/QGeometry.h>
#import <TNKNavigationKit/TNKNavigationKit.h>


#define kSCREEN_WIDTH          ([UIScreen mainScreen].bounds.size.width)
#define kSCREEN_HEIGHT         ([UIScreen mainScreen].bounds.size.height)

#define KISIphoneX (CGSizeEqualToSize(CGSizeMake(375.f, 812.f), [UIScreen mainScreen].bounds.size) || CGSizeEqualToSize(CGSizeMake(812.f, 375.f), [UIScreen mainScreen].bounds.size))

#define kHomeIndicatorHeight (KISIphoneX? 34 : 0)

#define kStatusBarHeight (KISIphoneX? 44 : 20)

#define kNavigationBarHeight (KISIphoneX? 88 : 64)

@interface MathTool : NSObject

+ (QMapRect)mapRectFitsPoints:(NSArray<TNKCoordinatePoint *>*)points;

@end
