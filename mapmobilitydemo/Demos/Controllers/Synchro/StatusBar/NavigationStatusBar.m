//
//  NavigationStatusBar.m
//  TNKNavigationDebugging
//
//  Created by 薛程 on 2018/6/21.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "NavigationStatusBar.h"
#import "Chameleon.h"

@interface NavigationStatusBar ()

@property (nonatomic) TNKRouteTrafficStatus *currentStatus;

@property (nonatomic) CGFloat scale; //point/米

@property (nonatomic) BOOL isNewData;

@end


@implementation NavigationStatusBar

- (id)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        [self setupSelf];
    }
    
    return self;
}

- (void)setupSelf
{
    self.clearsContextBeforeDrawing = YES;
}

- (void)updateStatusBar:(TNKRouteTrafficStatus *)status
{
    self.currentStatus = status;
    
    self.isNewData = YES;
    
    self.scale = [self updateScale];
    
    [self setNeedsDisplay];
}

- (void)updateRemainingDistance:(int)remainingDistance
{
    self.currentStatus.remainingDistance = remainingDistance;
    
    CGFloat passedWidth = (self.currentStatus.totalDistance - self.currentStatus.remainingDistance) * self.scale;
    
    CGRect passedRect = CGRectMake(0, 0, passedWidth, self.frame.size.height);
    
    [self setNeedsDisplayInRect:passedRect];
}

- (CGFloat)updateScale
{
    CGFloat scale;
    
    if(self.orientation <= NavigationStatusBarDisplayOrientationRightToLeft)
    {
        scale = self.frame.size.width/self.currentStatus.totalDistance;
    }
    else
    {
        scale = self.frame.size.height/self.currentStatus.totalDistance;
    }
    
    return scale;
}

- (void)drawRect:(CGRect)rect
{
    if(self.currentStatus == nil)
    {
        [[UIColor whiteColor] setFill];
        UIRectFill(rect);
        
        return;
    }
    
    if(self.currentStatus.trafficDataArray.count <= 0)
    {
        return;
    }
    
    switch (self.orientation)
    {
        case NavigationStatusBarDisplayOrientationLeftToRight:
        {
            if(self.isNewData)
            {
                [self drawStatusBarOrientationLeftToRight];
            }
            else
            {
                [self updateStatusBarOrientationLeftToRight:rect];
            }
            
            break;
        }
        default:
            break;
    }
}


- (void)drawStatusBarOrientationLeftToRight
{
    CGFloat originX = 0;
    
    for(int i=0;i<self.currentStatus.trafficDataArray.count;++i)
    {
        TNKRouteTrafficData *data = self.currentStatus.trafficDataArray[i];
        
        CGFloat width  = (int)(data.distance *  self.scale + 1);
        CGFloat height = self.frame.size.height;
        
        CGRect smallRect = CGRectMake(originX, 0, width, height);
        
        [[self fillColorWithIndex:data.color] setFill];
        UIRectFill(smallRect);
        
        originX += width;
    }
    
    CGFloat passedWidth = (self.currentStatus.totalDistance - self.currentStatus.remainingDistance) * self.scale;
    CGRect passedRect = CGRectMake(0, 0, passedWidth, self.frame.size.height);
    [self updateStatusBarOrientationLeftToRight:passedRect];
    
    self.isNewData = NO;
}

- (void)updateStatusBarOrientationLeftToRight:(CGRect)rect
{
    [[self fillColorWithIndex:5] setFill];
    UIRectFill(rect);
}

- (UIColor *)fillColorWithIndex:(NSInteger)index
{
    switch (index)
    {
        case 0:
        {
            return [UIColor flatGreenColor];
            break;
        }
        case 1:
        {
            return [UIColor flatYellowColor];
            break;
        }
        case 2:
        {
            return [UIColor flatRedColor];
            break;
        }
        case 3:
        {
            return [UIColor flatBlueColor];
            break;
        }
        case 4:
        {
            return [UIColor flatRedDarkColor];
            break;
        }
        case 5:
        {
            return [UIColor flatWhiteDarkColor];
            break;
        }
        default:
        {
            return [UIColor flatBlueColor];
            break;
        }
    }
}

- (void)setOrientation:(NavigationStatusBarDisplayOrientation)orientation
{
    if(orientation > NavigationStatusBarDisplayOrientationBottomToTop) return;
    
    if(_orientation != orientation)
    {
        _orientation = orientation;
        
        [self setNeedsDisplay];
    }
}

@end
