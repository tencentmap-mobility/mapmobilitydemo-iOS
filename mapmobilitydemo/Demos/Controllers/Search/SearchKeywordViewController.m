//
//  SearchKeywordViewController.m
//  mapmobilitydemo
//
//  Created by mol on 2019/12/4.
//  Copyright © 2019 tencent. All rights reserved.
//

#import "SearchKeywordViewController.h"
#import "SearchKeywordHeaderView.h"
#import <TencentMapMobilitySearchSDK/TMMSearch.h>
#import "SearchKeywordPOICell.h"
#import "SearchKeywordPOIModel.h"

@interface SearchKeywordViewController ()<SearchKeywordHeaderViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) SearchKeywordHeaderView *headerView;
@property (nonatomic, strong) NSURLSessionTask *searchTask;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, copy) NSString *city;

@property (nonatomic, strong) NSArray<SearchKeywordPOIModel *> *keywordPOIModels;
@end

@implementation SearchKeywordViewController

- (void)dealloc {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.city = @"北京";
    
    [self setupHeaderView];
    [self setupTableView];
    
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.headerView];

}

- (void)setupHeaderView {
    
    self.headerView = [[SearchKeywordHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 64 + 30)];
    self.headerView.city = self.city;
    self.headerView.delegate = self;
    [self.headerView textFieldBecomeFirstResponder];
}


- (void)setupTableView {
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.headerView.frame), self.view.bounds.size.width, self.view.bounds.size.height - CGRectGetMaxY(self.headerView.frame)) style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[SearchKeywordPOICell class] forCellReuseIdentifier:@"SearchKeywordPOICell"];
}

#pragma mark - private
- (void)selectPOIModel:(TMMSearchPOIModel *)poiModel subPOIModel:(TMMSearchPOIModel *)subPOIModel {
    
    if (self.poiModelClickCallback) {
        self.poiModelClickCallback(poiModel, subPOIModel);
    }
    
    [self.headerView textFieldResignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - SearchKeywordHeaderViewDelegate
- (void)searchKeywordHeaderViewDidCancel:(SearchKeywordHeaderView *)headerView {
 
    [self.headerView resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)searchKeywordHeaderView:(SearchKeywordHeaderView *)headerView cityDidChange:(NSString *)city {
    
}

- (void)searchKeywordHeaderView:(SearchKeywordHeaderView *)headerView keywordDidChange:(NSString *)keyword {
    
    if (keyword.length == 0) {
        
        self.keywordPOIModels = nil;
        [self.tableView reloadData];
        return;
    }
    
    TMMSearchSuggestionRequest *request = [[TMMSearchSuggestionRequest alloc] init];
    request.keyword = keyword;
    request.region = self.city;
    request.policy = self.policy;
    request.locationCoordinate = self.locationCoordinate;
    
    __weak typeof(self) weakself = self;
    [self.searchTask cancel];
    self.searchTask = [TMMSearchManager querySuggestionWithRequest:request completion:^(TMMSearchSuggestionResponse * _Nullable response, NSError * _Nullable error) {
        
        __strong SearchKeywordViewController *strongself = weakself;
        if (!strongself) {
            return;
        }
        
        if (error) {
            return ;
        }
        
        strongself.keywordPOIModels = [SearchKeywordPOIModel modelWithArray:response.poiModels];
        [strongself.tableView reloadData];
    }];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
        return self.keywordPOIModels.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.keywordPOIModels[indexPath.row].cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SearchKeywordPOICell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchKeywordPOICell" forIndexPath:indexPath];
    cell.keywordPOIModel = self.keywordPOIModels[indexPath.row];
    
    __weak typeof(self) weakself = self;
    cell.poiModelClickCallback = ^(TMMSearchPOIModel * _Nonnull poiModel, TMMSearchPOIModel * _Nullable subPOIModell) {
        [weakself selectPOIModel:poiModel subPOIModel:subPOIModell];
    };
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self selectPOIModel:self.keywordPOIModels[indexPath.row].poiModel subPOIModel:nil];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.headerView textFieldResignFirstResponder];
}

@end
