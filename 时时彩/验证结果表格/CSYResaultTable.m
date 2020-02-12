//
//  CSYResaultTable.m
//  时时彩
//
//  Created by hongchen on 2018/3/17.
//  Copyright © 2018年 hongchen. All rights reserved.
//

#import "CSYResaultTable.h"
#import "CSYResaultModel.h"

@interface CSYResaultTable ()
/** 赢利数据 */
@property (strong,nonatomic) NSMutableArray * profitArrs;
@end

@implementation CSYResaultTable


-(void)awakeFromNib {
    
    NSArray * titleArr = @[@"期号",@"开奖号码",@"预测号码",@"中奖结果",@"赢利",@"总赢利"];
    
    NSInteger count = [titleArr count];
    
    for (int i = 0; i < count; i++) {
        
        NSArray * coumnArr = [self tableColumns];
        NSTableColumn * column = coumnArr[i];
        [column setWidth:CGRectGetWidth(self.bounds)/count];
        column.headerCell.title = titleArr[i];
        [column.headerCell setAlignment:NSTextAlignmentCenter];
    }
    
    self.delegate = self;
    self.dataSource = self;
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    
    return [_dataArrs count];
}

-(void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    CSYResaultModel * model = [CSYResaultModel mj_objectWithKeyValues:_dataArrs[row]];
    
    NSButton * textCell = cell;
    
    if ([[tableColumn identifier] isEqualToString:@"number"]) {
        
        [textCell setTitle:model.qihao];
        
    }else if ([[tableColumn identifier] isEqualToString:@"openNumber"]) {
        
        [textCell setTitle:model.data];
        
    }else if ([[tableColumn identifier] isEqualToString:@"forecasNumber"]) {
        
        [textCell setTitle:model.forecas];
        
    }else if ([[tableColumn identifier] isEqualToString:@"state"]) {
        
        [textCell setTitle:model.resault];
        
    }else if ([[tableColumn identifier] isEqualToString:@"profit"]) {
        
        [textCell setTitle:model.profit];
        
    }else if ([[tableColumn identifier] isEqualToString:@"totalProfit"]) {
    
         [textCell setTitle:model.totalProfit];
    }
    
    
}


-(void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    
    
    
}

-(CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    
    return 30;
}


-(NSMutableArray *)dataArrs {
    
    if (_dataArrs) return _dataArrs;

    return _dataArrs = [NSMutableArray new];
}

-(NSMutableArray *)profitArrs {
    
    if (_profitArrs) return _profitArrs;
    return _profitArrs = [NSMutableArray new];
}
@end
