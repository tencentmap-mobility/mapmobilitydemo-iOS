//
//  CurrentRoadView.m
//  TNKNavigationDebugging
//
//  Created by 薛程 on 2018/6/20.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "CurrentRoadView.h"

#define kRoadTextSize 16

@interface CurrentRoadView()

@property (nonatomic, strong) NSDictionary *textDictionary;

@end

@implementation CurrentRoadView


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
    CGSize textSize = [self.roadName sizeWithAttributes:self.textDictionary];
    CGRect textRect = {CGPointMake(rect.size.width/2 - textSize.width/2,rect.size.height/2 - textSize.height/2), textSize};
    
    [self.roadName drawInRect:textRect withAttributes:self.textDictionary];
}

- (void)setup
{
    self.backgroundColor = [UIColor blackColor];
    self.alpha = 0.8;
    self.layer.cornerRadius = 10;
    self.clipsToBounds = YES;
    
    self.textDictionary = @{NSFontAttributeName:[UIFont fontWithName:@"Arial-BoldMT"size:kRoadTextSize],
                            NSForegroundColorAttributeName:[UIColor whiteColor]};
}

- (void)setRoadName:(NSString *)roadName
{
    if([_roadName isEqualToString:roadName] == NO)
    {
        _roadName = roadName;
        
        [self setNeedsDisplay];
    }
}

@end
