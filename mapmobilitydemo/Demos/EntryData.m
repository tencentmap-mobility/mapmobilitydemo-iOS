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
        Section *section = [[Section alloc] init];
        section.title = @"司乘同显-顺风车";
        NSMutableArray<Cell *> *cellArray = [NSMutableArray array];
        section.cells = cellArray;
        
        [sectionArray addObject:section];
        
        // 基础导航
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
        
        section = [[Section alloc] init];
        section.title = @"司乘同显-快车";
        cellArray = [NSMutableArray array];
        section.cells = cellArray;
        
        [sectionArray addObject:section];
        
        // 基础导航
        {
            Cell *cell = [[Cell alloc] init];
            cell.title = @"司机端";
            cell.controllerClassName = @"KCDriverSynchroViewController";
            [cellArray addObject:cell];
            
            cell = [[Cell alloc] init];
            cell.title = @"乘客端";
            cell.controllerClassName = @"KCPassengerSynchroViewController";
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
