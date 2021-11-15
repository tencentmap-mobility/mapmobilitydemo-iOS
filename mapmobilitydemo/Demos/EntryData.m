//
//  EntryData.m
//  TLSLocusSynchroDubugging
//
//  Created by 薛程 on 2018/11/27.
//  Copyright © 2018年 tencent. All rights reserved.
//

#import "EntryData.h"

@implementation Cell

@end

@implementation Section

@end

@implementation EntryData

+ (instancetype)constructDefaultEntryData
{
    EntryData *entry = [[EntryData alloc] init];
    entry.title = @"Mobility Demo";
    
    NSMutableArray<Section *> *sectionArray = [NSMutableArray array];
    entry.sections = sectionArray;
    
    {
        Section *section;
        NSMutableArray<Cell *> *cellArray;
        
        // 快车
        section = [[Section alloc] init];
        section.title = @"司乘同显-快车";
        cellArray = [NSMutableArray array];
        section.cells = cellArray;
        
        [sectionArray addObject:section];
        
        {
            Cell * cell = [[Cell alloc] init];
            cell.title = @"快车订单管理";
            cell.controllerClassName = @"KCOrderSyncViewController";
            [cellArray addObject:cell];
            
            cell = [[Cell alloc] init];
            cell.title = @"司机端";
            cell.controllerClassName = @"KCDriverSynchroViewController";
            [cellArray addObject:cell];
            
            cell = [[Cell alloc] init];
            cell.title = @"乘客端";
            cell.controllerClassName = @"KCPassengerSynchroViewController";
            [cellArray addObject:cell];
            
            cell = [[Cell alloc] init];
            cell.title = @"送驾前选路";
            cell.controllerClassName = @"KCPassengerBeforeTripViewController";
            [cellArray addObject:cell];
        }
        
        
        
        // 拼车
        section = [[Section alloc] init];
        section.title = @"司乘同显-拼车";
        cellArray = [NSMutableArray array];
        section.cells = cellArray;
        
        [sectionArray addObject:section];
        
        {
            Cell *cell = [[Cell alloc] init];
            cell.title = @"司机端";
            cell.controllerClassName = @"PCDriverSynchroViewController";
            [cellArray addObject:cell];
            
            cell = [[Cell alloc] init];
            cell.title = @"乘客端";
            cell.controllerClassName = @"PCPassengerSynchroViewController";
            [cellArray addObject:cell];
        }
        
        // 顺风车
        section = [[Section alloc] init];
        section.title = @"司乘同显-顺风车";
        cellArray = [NSMutableArray array];
        section.cells = cellArray;
        
        [sectionArray addObject:section];
        
        {
            Cell *cell = [[Cell alloc] init];
            cell.title = @"司机端";
            cell.controllerClassName = @"SFCDriverSynchroViewController";
            [cellArray addObject:cell];
            
            cell = [[Cell alloc] init];
            cell.title = @"乘客端";
            cell.controllerClassName = @"SFCPassengerSynchroViewController";
            [cellArray addObject:cell];
        }
        
    }
    {
        Section *section = [[Section alloc] init];
        section.title = @"移动出行";
        NSMutableArray<Cell *> *cellArray = [NSMutableArray array];
        section.cells = cellArray;
        
        [sectionArray addObject:section];
        
        {
            Cell *cell = [[Cell alloc] init];
            cell.title = @"周边车辆展示";
            cell.controllerClassName = @"NearbyCarsViewController";
            [cellArray addObject:cell];
        }
        {
            Cell *cell = [[Cell alloc] init];
            cell.title = @"推荐上车点展示";
            cell.controllerClassName = @"BoardingPlacesViewController";
            [cellArray addObject:cell];
        }
        {
            Cell *cell = [[Cell alloc] init];
            cell.title = @"出行检索-sug、逆地址解析";
            cell.controllerClassName = @"MobilitySearchViewController";
            [cellArray addObject:cell];
        }
        {
            Cell *cell = [[Cell alloc] init];
            cell.title = @"出行检索-路线规划";
            cell.controllerClassName = @"RoutePlanningViewController";
            [cellArray addObject:cell];
        }
        
    }
    
    return entry;
}

@end
