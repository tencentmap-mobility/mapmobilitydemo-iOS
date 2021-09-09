//
//  calloutAnnotationView.m
//  TencentMapLocusSynchroDemo
//
//  Created by Yuchen Wang on 2020/3/23.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "CarBubbleAnnotationView.h"

@interface CarBubbleAnnotationView()

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *distanceLabel;

@end

@implementation CarBubbleAnnotationView

// 设置剩余时间和剩余距离
- (void)setRemainingDistance:(int)remainingDistance remainingTime:(int)remainingTime {
    
    self.distanceLabel.text = [NSString stringWithFormat:@"距离终点%.1f公里", remainingDistance / 1000.0f];
    self.timeLabel.text = [NSString stringWithFormat:@"预计行驶%d分钟", remainingTime];
}

#pragma mark - Setup

- (void)setupViews {

    self.bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 160, 50)];
    self.bgView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.bgView];
    self.bgView.layer.cornerRadius = self.bgView.bounds.size.height / 2;
        
    self.distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 7, 140, 15)];
    self.distanceLabel.font = [UIFont systemFontOfSize:14];
    self.distanceLabel.textAlignment   = NSTextAlignmentLeft;
    self.distanceLabel.backgroundColor = [UIColor clearColor];
    self.distanceLabel.textColor = [UIColor blackColor];
    self.distanceLabel.text = @"距离终点";
    [self.bgView addSubview:self.distanceLabel];
    
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 27, 140, 15)];
    self.timeLabel.font = [UIFont systemFontOfSize:14];
    self.timeLabel.textAlignment   = NSTextAlignmentLeft;
    self.timeLabel.backgroundColor = [UIColor clearColor];
    self.timeLabel.textColor = [UIColor blackColor];
    self.timeLabel.text = @"预计行驶";
    [self.bgView addSubview:self.timeLabel];
}

- (instancetype)initWithAnnotation:(id<QAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier])  {
        
        [self setupViews];
      
        self.bounds = CGRectMake(0, 0, self.bgView.bounds.size.width, self.bgView.bounds.size.height + 20);
        
        self.centerOffset = CGPointMake(0, - self.bounds.size.height);
        
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

@end
