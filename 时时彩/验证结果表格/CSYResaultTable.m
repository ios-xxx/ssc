//
//  CSYResaultTable.m
//  时时彩
//
//  Created by hongchen on 2018/3/17.
//  Copyright © 2018年 hongchen. All rights reserved.
//

#import "CSYResaultTable.h"
#import "CSYResaultModel.h"

@implementation CSYResaultTable


-(void)awakeFromNib {
    
    NSArray * titleArr = @[@"中奖结果",@"赢利",@"总赢利"];
    
    NSInteger count = [titleArr count];
    
    for (int i = 0; i < count; i++) {
        
        NSArray * coumnArr = [self tableColumns];
        NSTableColumn * column = coumnArr[i];
        [column setWidth:CGRectGetWidth(self.bounds)/count];
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
    
    CSYResaultModel * model = [CSYResaultModel mj_objectWithKeyValues:_dataArr[row]];
    
    NSButton * textCell = cell;
    
    if ([[tableColumn identifier] isEqualToString:@"state"]) {
        
        [textCell setTitle:model.resault];
        
    }else if ([[tableColumn identifier] isEqualToString:@"profit"]) {
        
        [textCell setTitle:model.resault];
        
    }else if ([[tableColumn identifier] isEqualToString:@"profit"]) {
    
         [textCell setTitle:model.resault];
    }
    
    
}


-(void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    
    
    
}

-(CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    
    return 30;
}



@end
