//
//  calloutAnnotationView.h
//  TencentMapLocusSynchroDemo
//
//  Created by Yuchen Wang on 2020/3/23.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <QMapKit/QMapKit.h>
#import <QMapKit/QAnnotationView.h>
NS_ASSUME_NONNULL_BEGIN

@interface CarBubbleAnnotationView : QAnnotationView

// 设置剩余时间和剩余距离
- (void)setRemainingDistance:(int)remainingDistance remainingTime:(int)remainingTime;

@end

NS_ASSUME_NONNULL_END
