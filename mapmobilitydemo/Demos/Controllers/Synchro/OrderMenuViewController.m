//
//  OrderMenuViewController.m
//  TencentMapLocusSynchroDemo
//
//  Created by mol on 2021/8/13.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "OrderMenuViewController.h"

typedef NS_ENUM(NSInteger, OrderMenuItem) {
    OrderMenuItemPick = 0,  // 接驾
    OrderMenuItemTrip,  // 送驾
    OrderMenuItemStartNavi, // 开启导航
    OrderMenuItemStartSimulateNavi, // 开启模拟导航
};

NSString * const kOrderMenuCellIdentifier = @"orderMenuCellIdentifier";
NSString * const kOrderMenuItemKey = @"kOrderMenuItemKey";
NSString * const kOrderMenuItemName = @"kOrderMenuItemName";


@interface OrderMenuViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIView *backgroundView;

@property (nonatomic, strong) UITableView *tableView;
// tableView数据源
@property (nonatomic, copy) NSArray<NSArray<NSDictionary *> *> *dataArray;

@end

@implementation OrderMenuViewController

#pragma mark - lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.dataArray = @[
        @[
            @{kOrderMenuItemKey : @(OrderMenuItemPick),
              kOrderMenuItemName : @"接驾+路径规划",
            },
            @{kOrderMenuItemKey : @(OrderMenuItemTrip),
              kOrderMenuItemName : @"送驾+路径规划",
            },
        ],
        @[
            @{kOrderMenuItemKey : @(OrderMenuItemStartNavi),
              kOrderMenuItemName : @"开启导航",
            },
            @{kOrderMenuItemKey : @(OrderMenuItemStartSimulateNavi),
              kOrderMenuItemName : @"开启模拟导航",
            },
        ],
    ];
    
    CGFloat tableViewWidth = 150.0f;
    
    self.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.backgroundView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self.backgroundView addGestureRecognizer:tap];
    [self.view addSubview:self.backgroundView];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width, 0, tableViewWidth, self.view.bounds.size.height)];
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kOrderMenuCellIdentifier];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    [self.tableView reloadData];

}

#pragma mark - public
// 展示菜单
- (void)showMenu {
    
    CGRect frame = self.tableView.frame;
    frame.origin.x = self.view.bounds.size.width - frame.size.width;
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.tableView.frame = frame;
    } completion:^(BOOL finished) {

    }];
}

#pragma mark - action

- (void)tap:(UITapGestureRecognizer *)aGesture {
    
    [self dismiss];
   
}

#pragma mark - private

- (void)dismiss {
    
    CGRect frame = self.tableView.frame;
    frame.origin.x = self.view.bounds.size.width;
    [UIView animateWithDuration:0.1 animations:^{
        self.tableView.frame = frame;
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:NO completion:nil];

    }];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.dataArray[section].count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 60.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *tableViewCell = [tableView dequeueReusableCellWithIdentifier:kOrderMenuCellIdentifier forIndexPath:indexPath];
    
    NSDictionary *item = self.dataArray[indexPath.section][indexPath.item];
    tableViewCell.textLabel.font = [UIFont systemFontOfSize:15];
    tableViewCell.textLabel.text = item[kOrderMenuItemName];
    tableViewCell.textLabel.textColor = [UIColor whiteColor];
    tableViewCell.backgroundColor = [UIColor clearColor];
    
    return tableViewCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *item = self.dataArray[indexPath.section][indexPath.item];
    OrderMenuItem menuItem = [item[kOrderMenuItemKey] integerValue];
    
    switch (menuItem) {
        case OrderMenuItemPick:
        {
            [self.delegate orderMenuViewControllerPickup:self];
        }
            break;
        case OrderMenuItemTrip:
        {
            [self.delegate orderMenuViewControllerTrip:self];
        }
            break;
        case OrderMenuItemStartNavi:
        {
            if (TLSBOrderStatusNone == self.orderStatus) {
                return;
            }
            [self.delegate orderMenuViewControllerStartNavi:self];
        }
            break;
        case OrderMenuItemStartSimulateNavi:
        {
            if (TLSBOrderStatusNone == self.orderStatus) {
                return;
            }
            [self.delegate orderMenuViewControllerStartSimulateNavi:self];
        }
            break;
        default:
            break;
    }
    
    [self dismiss];
}

@end
