//
//  TMMDPinView.h
//  TencentMapMobilityDemo
//
//  Created by mol on 2019/11/27.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TMMDCenterPinView : UIView

// 大头针图片
@property (nonatomic, strong) UIImage *image;
// 气泡上的文字
@property (nonatomic, copy, nullable) NSAttributedString *calloutAttribtedText;
// 气泡是否显示
@property (nonatomic, assign, getter=isCalloutViewHidden) BOOL calloutViewHidden;

- (instancetype)init;

- (instancetype)initWithFrame:(CGRect)frame UNAVAILABLE_ATTRIBUTE; 

/**
 显示/隐藏气泡

 @param calloutViewHidden 气泡视图是否隐藏
 @param animated 是否使用动画
 */
- (void)setCalloutViewHidden:(BOOL)calloutViewHidden animated:(BOOL)animated;
@end

NS_ASSUME_NONNULL_END
