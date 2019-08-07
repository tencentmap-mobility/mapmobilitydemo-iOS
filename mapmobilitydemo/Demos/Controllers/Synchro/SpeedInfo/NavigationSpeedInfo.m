//
//  NavigationSpeedInfo.m
//  TNKNavigationDebugging
//
//  Created by 薛程 on 2018/6/18.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "NavigationSpeedInfo.h"
#import "LimitSpeedView.h"
#import "CurrentSpeedView.h"
#import "CurrentRoadView.h"

@interface NavigationSpeedInfo()

@property (nonatomic, strong) CurrentSpeedView *currentSpeedView;

@property (nonatomic, strong) LimitSpeedView *limitSpeedView;

@property (nonatomic, strong) CurrentRoadView *currentRoadView;

@end

@implementation NavigationSpeedInfo

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

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
    self.backgroundColor = [UIColor clearColor];
}

- (void)setupWidgets
{
    CGFloat width  = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    CGFloat infoWidth = height;
    CGFloat infoHeight = height;
    
    CGFloat inter = 16;
    
    self.currentSpeedView = [[CurrentSpeedView alloc] initWithFrame:CGRectMake(0, 0, infoWidth, infoHeight)];
    
    self.limitSpeedView = [[LimitSpeedView alloc] initWithFrame:CGRectMake(infoWidth, 0, infoWidth, infoHeight)];
    
    self.currentRoadView = [[CurrentRoadView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.limitSpeedView.frame) - inter, height/6, width - 2 * infoWidth + inter, height/3 * 2)];
    
    [self addSubview:self.currentRoadView];
    [self addSubview:self.currentSpeedView];
    [self addSubview:self.limitSpeedView];
}

- (void)updateCurrentSpeed:(int)current
                limitSpeed:(int)limit
           currentRoadName:(NSString *)road;
{
    self.limitSpeedView.speed = limit;
    self.currentSpeedView.speed = current;
    self.currentRoadView.roadName = road;
}

@end
