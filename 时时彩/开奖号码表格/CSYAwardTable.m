//
//  CSYAwardTable.m
//  时时彩
//
//  Created by hongchen on 2018/3/16.
//  Copyright © 2018年 hongchen. All rights reserved.
//

#import "CSYAwardTable.h"
#import "CSYDataModel.h"

@implementation CSYAwardTable

-(void)awakeFromNib {
    
    NSArray * titleArr = @[@"开奖期数",@"开奖号码"];
    
    NSInteger count = [titleArr count];
    
    for (int i = 0; i < count; i++) {
        
        NSArray * coumnArr = [self tableColumns];
        NSTableColumn * column = coumnArr[i];
        column.headerCell.title = titleArr[i];
        [column.headerCell setAlignment:NSTextAlignmentCenter];
    }
    
    self.needsDisplay=true;
    self.delegate = self;
    self.dataSource = self;
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    
    return [_dataArr count];
}

-(void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    CSYDataModel * model = [CSYDataModel mj_objectWithKeyValues:_dataArr[row]];
    
    NSButton * textCell = cell;
    
    if ([[tableColumn identifier] isEqualToString:@"id"]) {
        
        [textCell setTitle:model.period];
        
    }else if ([[tableColumn identifier] isEqualToString:@"number"]) {
        
        [textCell setTitle:model.result];
        
    }
    
    
}


-(void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
  
    
    
}

-(CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    
    return 30;
}


@end
