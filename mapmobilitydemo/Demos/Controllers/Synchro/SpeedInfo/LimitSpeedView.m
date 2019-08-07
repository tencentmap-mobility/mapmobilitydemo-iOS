//
//  LimitSpeedView.m
//  TNKNavigationDebugging
//
//  Created by 薛程 on 2018/6/20.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "LimitSpeedView.h"

#define kSpeedTextSize 24

@interface LimitSpeedView ()

@property (nonatomic, strong) UIImage *backgroundImage;

@property (nonatomic, strong) NSDictionary *textDictionary;

@property (nonatomic, strong) NSString *speedString;

@end


@implementation LimitSpeedView

- (id)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        [self setup];
    }
    
    return self;
}


- (void)drawRect:(CGRect)rect
{
    CGSize textSize = [self.speedString sizeWithAttributes:self.textDictionary];
    CGRect textRect = {CGPointMake(rect.size.width/2 - textSize.width/2,rect.size.height/2 - textSize.height/2), textSize};
    
    [self.backgroundImage drawInRect:rect];
    [self.speedString drawInRect:textRect withAttributes:self.textDictionary];
}

- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    self.backgroundImage = [UIImage imageNamed:@"navi_bg_speedlimit"];

    self.textDictionary = @{NSFontAttributeName:[UIFont fontWithName:@"Arial-BoldMT" size:kSpeedTextSize],
                            NSForegroundColorAttributeName:[UIColor blackColor]};
}

- (void)setSpeed:(int)speed
{
    if(_speed != speed)
    {
        _speed = speed;
        
        self.speedString = [self stringWithSpeed:speed];
        
        [self setNeedsDisplay];
    }
}

- (NSString *)stringWithSpeed:(int)speed
{
    NSString *string;
    
    if(speed < 0)
    {
        string = @"";
    }
    else
    {
        string = [NSString stringWithFormat:@"%d",speed];
    }
    
    return string;
}

@end
