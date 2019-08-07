//
//  NavigationBottomBoard.m
//  TNKNavigationDebugging
//
//  Created by 薛程 on 2018/6/18.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "NavigationBottomBoard.h"

#define kNormalTextFontSize  18
#define kSpecialTextFontSize 22

#define kDayModeBackgroundColor   [UIColor whiteColor]
#define kDayModeForegroundColor   [UIColor blackColor]

#define kNightModeBackgroundColor [UIColor blackColor]
#define kNightModeForegroundColor [UIColor whiteColor]

@interface NavigationBottomBoard()

@property (nonatomic, strong) UILabel *infoLabel;

@end


@implementation NavigationBottomBoard

- (id)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        [self setupSelf];
        [self setupWidgets];
    }
    
    return self;
}

- (void)setupSelf
{
    self.backgroundColor = [self backgroundColor];
    self.layer.cornerRadius = 6;
}

- (void)setupWidgets
{
    CGFloat width  = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    CGFloat margin = 5;
 
    self.infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(margin, 0, width - 4 * margin, height)];
    self.infoLabel.textAlignment = NSTextAlignmentCenter;
    
    [self addSubview:self.infoLabel];
}

- (void)setWidgetColor
{

    self.backgroundColor = [self backgroundColor];
    
    [self changeAttributedString:self.infoLabel.attributedText color:[self foregroundColor]];
}

- (UIColor *)backgroundColor
{
    return self.nightMode? kNightModeBackgroundColor : kDayModeBackgroundColor;
}

- (UIColor *)foregroundColor
{
    return self.nightMode? kNightModeForegroundColor : kDayModeForegroundColor;
}

- (void)setNightMode:(BOOL)nightMode
{
    if(_nightMode != nightMode)
    {
        _nightMode = nightMode;
        
        [self setWidgetColor];
    }
}

- (void)updateInfoLabelWithTotalDistanceLeft:(NSString *)distance
                                distanceUnit:(NSString *)unit
                               totalTimeLeft:(NSString *)time
{
    NSMutableAttributedString *infoString = [[NSMutableAttributedString alloc] init];
    
    //剩余+距离+单位 时间+分钟
    
    //剩余
    NSDictionary *attributes = [self attributeWithFontSize:kNormalTextFontSize bold:NO fontColor:[self foregroundColor]];
    NSAttributedString *leftStr = [[NSAttributedString alloc] initWithString:@"剩余" attributes:attributes];
    [infoString appendAttributedString:leftStr];
    
    //距离
    attributes = [self attributeWithFontSize:kSpecialTextFontSize bold:YES fontColor:[self foregroundColor]];
    NSAttributedString *distanceStr = [[NSAttributedString alloc] initWithString:distance attributes:attributes];
    [infoString appendAttributedString:distanceStr];
    
    //单位
    attributes = [self attributeWithFontSize:kNormalTextFontSize bold:NO fontColor:[self foregroundColor]];
    NSAttributedString *unitStr = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ",unit] attributes:attributes];
    [infoString appendAttributedString:unitStr];
    
    //时间
    attributes = [self attributeWithFontSize:kSpecialTextFontSize bold:YES fontColor:[self foregroundColor]];
    NSAttributedString *timeStr = [[NSAttributedString alloc] initWithString:time attributes:attributes];
    [infoString appendAttributedString:timeStr];
    
    //分钟
    attributes = [self attributeWithFontSize:kNormalTextFontSize bold:NO fontColor:[self foregroundColor]];
    NSAttributedString *minuteStr = [[NSAttributedString alloc] initWithString:@"分钟" attributes:attributes];
    [infoString appendAttributedString:minuteStr];
    
    self.infoLabel.attributedText = infoString;
}


- (NSDictionary *)attributeWithFontSize:(CGFloat)fontSize bold:(BOOL)bold fontColor:(UIColor *)fontColor
{
    NSParameterAssert(fontColor != nil);
    
    UIFont *font = bold ? [UIFont boldSystemFontOfSize:fontSize] : [UIFont systemFontOfSize:fontSize];
    
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    
    [attributes setObject:font      forKey:NSFontAttributeName];
    [attributes setObject:fontColor forKey:NSForegroundColorAttributeName];
    
    return attributes;
}

- (NSMutableAttributedString *)changeAttributedString:(NSAttributedString *)string
                                                color:(UIColor *)color
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:string];
    
    [attributedString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, attributedString.length)];
    
    return attributedString;
}

@end
