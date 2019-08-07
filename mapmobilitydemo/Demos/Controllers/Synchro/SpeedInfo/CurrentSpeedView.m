//
//  CurrentSpeedView.m
//  TNKNavigationDebugging
//
//  Created by 薛程 on 2018/6/20.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "CurrentSpeedView.h"

#define kUnitText @"km/h"
#define kSpeedTextSize 20
#define kUnitTextSize 12

@interface CurrentSpeedView ()

@property (nonatomic, strong) UIImage *backgroundImage;

@property (nonatomic, strong) NSDictionary *speedTextDictionary;

@property (nonatomic, strong) NSDictionary *unitTextDictionary;

@property (nonatomic, strong) NSString *speedString;

@end


@implementation CurrentSpeedView

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
    CGSize speedTextSize = [self.speedString sizeWithAttributes:self.speedTextDictionary];
    CGSize unitTextSize  = [kUnitText sizeWithAttributes:self.unitTextDictionary];
    
    CGRect speedRect = {CGPointMake(rect.size.width/2 - speedTextSize.width/2,rect.size.height/2 - speedTextSize.height/4 * 3), speedTextSize};
    CGRect unitRect  = {CGPointMake(rect.size.width/2 - unitTextSize.width/2,rect.size.height/2 + 2), unitTextSize};
    
    [self.backgroundImage drawInRect:rect];
    
    [self.speedString drawInRect:speedRect withAttributes:self.speedTextDictionary];
    [kUnitText drawInRect:unitRect withAttributes:self.unitTextDictionary];
}

- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    self.backgroundImage = [UIImage imageNamed:@"navi_bg_speed"];
    
    self.speedTextDictionary = @{NSFontAttributeName:[UIFont fontWithName:@"Arial-BoldMT"size:kSpeedTextSize],
                                 NSForegroundColorAttributeName:[UIColor blackColor]};
    self.unitTextDictionary  = @{NSFontAttributeName:[UIFont fontWithName:@"Arial-BoldMT"size:kUnitTextSize],
                                 NSForegroundColorAttributeName:[UIColor blackColor]};
    self.speedString = @"-";
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
        string = @"-";
    }
    else
    {
        string = [NSString stringWithFormat:@"%d",speed];
    }
    
    return string;
}

@end
