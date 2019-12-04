//
//  TripPanelView.h
//  mapmobilitydemo
//
//  Created by mol on 2019/12/4.
//  Copyright © 2019 tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TripPanelInput) {
    TripPanelInputStart = 0,    //起点
    TripPanelInputEnd,      //终点
};

@interface TripPanelView : UIView

// 起点地址
@property (nonatomic, copy, nullable) NSString *startAddress;
// 终点地址
@property (nonatomic, copy, nullable) NSString *endAddress;


- (void)setClickInputCallback:(void(^)(TripPanelInput panelInput))callback;

@end

NS_ASSUME_NONNULL_END
