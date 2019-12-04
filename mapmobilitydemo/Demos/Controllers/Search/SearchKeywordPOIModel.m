//
//  SewarchKeywordPOIModel.m
//  mapmobilitydemo
//
//  Created by mol on 2019/12/4.
//  Copyright © 2019 tencent. All rights reserved.
//

#import "SearchKeywordPOIModel.h"

@implementation SearchKeywordPOIModel

- (instancetype)initWithPOIModel:(TMMSearchPOIModel *)poiModel {
    
    self = [super init];
    if (self) {
        _poiModel = poiModel;
        _edgeInsets = UIEdgeInsetsMake(15, 20, 15, 20);
        _titleHeight = 50;
        _subPOIButtonCol = 3;
        _subPOIButtonHeight = 30;
        _subPOIButtonPadding = 8;
        
        // 子poi行数
        NSUInteger subPOIRow = poiModel.subPOIModels.count == 0 ? 0 : ((poiModel.subPOIModels.count - 1) / _subPOIButtonCol + 1);
        _cellHeight = _edgeInsets.top + _titleHeight + _edgeInsets.bottom;
        if (subPOIRow != 0) {
            _cellHeight += subPOIRow * _subPOIButtonHeight + (subPOIRow - 1) * _subPOIButtonPadding;
        }
    }

    return self;
}

+ (NSArray<SearchKeywordPOIModel *> *)modelWithArray:(NSArray<TMMSearchPOIModel *> *)poiModels {
    
    NSMutableArray *tmpArray = [NSMutableArray arrayWithCapacity:poiModels.count];
    for (TMMSearchPOIModel *poiModel in poiModels) {
        
        SearchKeywordPOIModel *keywordPOIModel = [[SearchKeywordPOIModel alloc] initWithPOIModel:poiModel];
        if (keywordPOIModel) {
            [tmpArray addObject:keywordPOIModel];
        }
    }
    
    return [tmpArray copy];
}
@end
