//
//  SearchKeywordViewController.h
//  mapmobilitydemo
//
//  Created by mol on 2019/12/4.
//  Copyright © 2019 tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TencentMapMobilitySearchSDK/TMMSearch.h>

NS_ASSUME_NONNULL_BEGIN

@class TMMSearchPOIModel;
@interface SearchKeywordViewController : UIViewController

@property (nonatomic, assign) TMMSSuggestionPolicy policy;
@property (nonatomic, assign) CLLocationCoordinate2D locationCoordinate;

@property (nonatomic, copy) void(^poiModelClickCallback)(TMMSearchPOIModel * _Nonnull poiModel, TMMSearchPOIModel * _Nullable subPOIModel);

@end

NS_ASSUME_NONNULL_END
