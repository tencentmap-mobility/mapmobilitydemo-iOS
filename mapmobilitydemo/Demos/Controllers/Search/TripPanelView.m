//
//  TripPanelView.m
//  mapmobilitydemo
//
//  Created by mol on 2019/12/4.
//  Copyright © 2019 tencent. All rights reserved.
//

#import "TripPanelView.h"

@interface TripPanelCell : UITableViewCell

- (void)setAddress:(NSString *)address tripPanelInput:(TripPanelInput)tripPanelInput;
@end

@implementation TripPanelCell

- (void)setAddress:(NSString *)address tripPanelInput:(TripPanelInput)tripPanelInput {
    
    BOOL usePlaceHolder = address.length == 0;
    NSString *text = address;
    UIColor *textColor = [UIColor blackColor];
    
    if (usePlaceHolder) {
        switch (tripPanelInput) {
            case TripPanelInputStart:
            {
                text = @"您在哪儿上车";
            }
                break;
            case TripPanelInputEnd:
            {
                text = @"您要去哪儿";
            }
            default:
                break;
        }
        
        textColor = [UIColor lightGrayColor];
    }
    
    self.textLabel.attributedText = [[NSAttributedString alloc] initWithString:text attributes:@{NSForegroundColorAttributeName : textColor, NSFontAttributeName : [UIFont systemFontOfSize:12]}];
}

@end


@interface TripPanelView ()<UITableViewDelegate, UITableViewDataSource>

// 分割线
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, copy) void(^inputCallback)(TripPanelInput panelInput);
@end

@implementation TripPanelView

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        [self setup];
    }
    
    return self;
}

- (void)setup {
    
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = 6.0;
    self.layer.shadowColor = [UIColor grayColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0, 2.0);
    self.layer.shadowRadius = 2.0;
    self.layer.shadowOpacity = 0.5;
    
    self.tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.tableView registerClass:[TripPanelCell class] forCellReuseIdentifier:@"TripPanelCellIdentifier"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView reloadData];
    [self addSubview:self.tableView];
}

#pragma mark - public
- (void)setClickInputCallback:(void(^)(TripPanelInput panelInput))callback {
    self.inputCallback = callback;
}

#pragma mark - setter
- (void)setStartAddress:(NSString *)startAddress {
    _startAddress = startAddress;
    
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:TripPanelInputStart inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)setEndAddress:(NSString *)endAddress {
    _endAddress = endAddress;
    
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:TripPanelInputEnd inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.tableView.bounds.size.height / 2.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TripPanelCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TripPanelCellIdentifier" forIndexPath:indexPath];
    if (!cell) {
        cell = [[TripPanelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TripPanelCellIdentifier"];
    }
    
    NSString *text = indexPath.row == TripPanelInputStart ? self.startAddress : self.endAddress;
    [cell setAddress:text tripPanelInput:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.inputCallback) {
        self.inputCallback(indexPath.row);
    }
}

@end

