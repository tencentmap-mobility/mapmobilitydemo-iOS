//
//  SewarchKeywordPOICell.h
//  mapmobilitydemo
//
//  Created by mol on 2019/12/4.
//  Copyright © 2019 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SearchKeywordPOIModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SearchKeywordPOICell : UITableViewCell

@property (nonatomic, strong) SearchKeywordPOIModel *keywordPOIModel;
@property (nonatomic, copy) void(^poiModelClickCallback)(TMMSearchPOIModel * _Nonnull poiModel, TMMSearchPOIModel * _Nullable subPOIModel);

@end

NS_ASSUME_NONNULL_END
