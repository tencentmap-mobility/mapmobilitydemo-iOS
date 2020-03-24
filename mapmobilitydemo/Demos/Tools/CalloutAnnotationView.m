//
//  calloutAnnotationView.m
//  TencentMapLocusSynchroDemo
//
//  Created by Yuchen Wang on 2020/3/23.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "CalloutAnnotationView.h"

@interface CalloutAnnotationView()
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *label;
@end

@implementation CalloutAnnotationView

- (void)setCallloutText:(NSString *)callloutText
{
    _callloutText = callloutText;
    
    self.label.text = self.callloutText;
}

#pragma mark - Setup

- (void)setupImageView
{
    UIImage *img = [UIImage imageNamed:@"calloutview"];
    
    UIImage *resizedImg = [self image:img byScalingToSize:CGSizeMake(300, 30)];
    
    self.imageView = [[UIImageView alloc] initWithImage:resizedImg];
    
    self.imageView.frame = CGRectMake(0, 0, resizedImg.size.width, resizedImg.size.height);
    
    [self addSubview:self.imageView];
}

- (UIImage *)image:(UIImage*)image byScalingToSize:(CGSize)targetSize {
    UIImage *sourceImage = image;
    UIImage *newImage = nil;
 
    UIGraphicsBeginImageContext(targetSize);
 
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = CGPointZero;
    thumbnailRect.size.width  = targetSize.width;
    thumbnailRect.size.height = targetSize.height;
 
    [sourceImage drawInRect:thumbnailRect];
 
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
 
    return newImage ;
}

- (void)setupLabel
{
    #define Label_H 32
    
    CGRect r = CGRectMake(0, 0, CGRectGetWidth(self.imageView.bounds), Label_H);
    
    self.label = [[UILabel alloc] initWithFrame:r];
    
    self.label.textAlignment   = NSTextAlignmentCenter;
    self.label.backgroundColor = [UIColor clearColor];
    self.label.textColor       = [UIColor blackColor];
    self.label.text            = self.callloutText;
    [self.imageView addSubview:self.label];
}

- (instancetype)initWithAnnotation:(id<QAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier])
    {
        [self setupImageView];
        
        [self setupLabel];
        self.bounds = self.imageView.bounds;
        
        self.centerOffset = CGPointMake(0, -32);
        
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

@end
