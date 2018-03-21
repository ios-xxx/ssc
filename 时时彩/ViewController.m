//
//  ViewController.m
//  时时彩
//
//  Created by hongchen on 2018/3/13.
//  Copyright © 2018年 hongchen. All rights reserved.
//

#import "ViewController.h"
#import "CSYAwardTable.h"
#import "CSYResaultTable.h"
#import "CSYDataModel.h"
#import "CSYResaultModel.h"

@interface ViewController()
{
    /** 每次验证 */
    __block int evertTime;
    
    /** 总赢利 */
    __block float totalProfit;
}

/** 验证期数 */
@property (weak) IBOutlet NSTextField *VerificationTxt;
/** 校验期数 */
@property (weak) IBOutlet NSTextField *checkTxt;
/** 随机注数 */
@property (weak) IBOutlet NSTextField *arcNumberTxt;

/** 连对单选框 */
@property (weak) IBOutlet NSButton *coreectRadio;
 /** 连错单选框 */
@property (weak) IBOutlet NSButton *errorRadio;
/** 当前验证状态（true(连对)/(false(连错)） */
@property (assign,nonatomic) BOOL isVerification;
/** 停止操作 */
@property (assign,nonatomic) BOOL stopOperation;
/** 开奖表格 */
@property (weak) IBOutlet CSYAwardTable *dataTable;
/** 验证结果表格 */
@property (weak) IBOutlet CSYResaultTable *resaultTable;

/** 存放开奖数据 */
@property (strong,nonatomic) NSMutableArray * dataArrs;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    /** 初始化请求 */
    [self initWithRequest];
   
    
}


#pragma mark - 初始化请求
/** 初始化请求 */
-(void)initWithRequest {
    
    NSString * url = @"http://1685582.com/Result/GetLotteryResultList?gameID=40&pageSize=100&pageIndex=1&";
    int arcUri = arc4random()%199999999+1000000;
    url=[url stringByAppendingFormat:@"%d",arcUri];
    
    
        DLog(@"%@",url);
    
    [CSYRequest requestGetUrl:url paramters:nil cookie:nil success:^(NSURLSessionDataTask * _Nonnull task, NSData *data) {
        
        NSDictionary * json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        
        
        if ([CSYIsNull isNull:json[@"list"]]) return ;
        
        for (NSDictionary * obj in json[@"list"]){
            [self.dataArrs addObject:obj];
        }
        
        _dataArrs = [NSMutableArray arrayWithArray:[[_dataArrs reverseObjectEnumerator] allObjects]];
        
        _dataTable.dataArr = [NSArray arrayWithArray:_dataArrs];
        [_dataTable reloadData];
        
        //动态移动cell至顶部
        [_dataTable scrollRowToVisible:[_dataArrs count] -1];
    } error:^(NSError *err) {
        
        
        DLog(@"%@",err);
    }];
    
}


/** 响应开始验证 */
- (IBAction)startVerification:(NSButton *)sender {
    
    sender.enabled = false;
    /** 初始化总赢利 */
    totalProfit = 0.0;
    
    /** 验证范围 */
    __block NSString * verificationStr = _VerificationTxt.stringValue;
    
    /** 每次验证期数 */
    evertTime = [_checkTxt.stringValue intValue];
    evertTime == 0 ? evertTime = 3 : evertTime;
    
    /** 每次随机的注数 */
    int arcNumber = [_arcNumberTxt.stringValue intValue];
    arcNumber == 0 ? arcNumber = 50 : arcNumber;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
       
        /** 倒数第几期开始验证 */
        NSArray * verificationArr = [verificationStr componentsSeparatedByString:@"-"];
        
        __block int verificationNumber = [verificationArr.lastObject intValue];
        verificationNumber == 0 ? verificationNumber = 1 : verificationNumber;
        
   
        /** 校验结束期数 */
        int overCount = [verificationArr.firstObject intValue];
        
        while (verificationNumber > overCount) {
            
            if (totalProfit/100 > 0.3 && _isVerification == true){
                
                
                dispatch_sync(dispatch_get_main_queue(), ^{
                   
                    
                    NSAlert * alert = [NSAlert new];
                    [alert addButtonWithTitle:@"知道了"];
                    [alert setInformativeText:[NSString stringWithFormat:@"恭喜你在第%d期达到%%30赢利",verificationNumber]];
                    
                    [alert beginSheetModalForWindow:[NSApplication sharedApplication].keyWindow completionHandler:^(NSModalResponse returnCode) {
                        
                    }];
                    
                    
                    [_resaultTable reloadData];
                    sender.enabled = true;
                });
                break;
            }
            
            
            [self verificationverificationNumber:verificationNumber evertNumber:evertTime number:arcNumber complete:^(BOOL isCoreer) {
                
                verificationNumber --;
                
                if (verificationNumber == overCount)
                {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                       
                        sender.enabled = true;
                        
                        [_resaultTable reloadData];
                        /** 显示中奖总期数 */
                        [self showWinningTotalNumber:[NSArray arrayWithArray:_resaultTable.dataArrs]];
                    });
                }
            }];
            
        }
        
    });
   
    
    
}


/** 响应连错被选中 */
- (IBAction)error:(id)sender {
    
    [sender setState:1];
    [_coreectRadio setState:0];
    _isVerification = false;
    
}

/** 响应连对被选中 */
- (IBAction)coreect:(id)sender {
    
    [sender setState:0];
    [_errorRadio setState:1];
    _isVerification = true;
    
}

/** 清空数据效验 */
- (IBAction)clearVerificationData:(id)sender {
    
    [_resaultTable.dataArrs removeAllObjects];
    [_resaultTable reloadData];
}

/** 停止 */
- (IBAction)stopOperation:(id)sender {
    
    _stopOperation = true;
}




#pragma mark - 兑奖号码生成
/**
 验证开奖结果

 @param verificationNumber 倒数第几期开始验证
 @param evertNumber 每次验证的期数
 @param arcNumber    每次随机生成的注数
 @param complete 返回结果
 */
-(void)verificationverificationNumber:(int)verificationNumber  evertNumber:(int)evertNumber number:(int)arcNumber complete:(void(^)(BOOL isCoreer))complete{
    
    /** 当前验证次数 */
    __block int  currentCount=0;
    
    /** 倒数第几期开始验证 */
    __block int count2 = evertNumber + verificationNumber;
    
    while (currentCount != evertNumber+1) {

        CSYDataModel * model = [CSYDataModel mj_objectWithKeyValues:_dataArrs[_dataArrs.count - count2]];
       
        [self arcNumber:arcNumber block:^(NSMutableArray *numArrs) {
            
            BOOL isCorrect = [self queryWinningNumber:model.result queryArr:numArrs];
            
            if (isCorrect){  // 如果中奖号不在这个数组中
              
//                DLog(@"cont= %d",currentCount);
                if (currentCount == evertTime) {
                    
                    [self arcNumber:arcNumber block:^(NSMutableArray *numArrs) {
                        
                        if (numArrs.count) {
                            
                            if (_dataArrs.count - count2 == _dataArrs.count -1) {

                                DLog(@"%@%@",numArrs,model.result);


                            }else {
                            
                                CSYDataModel * model2 = [CSYDataModel mj_objectWithKeyValues:_dataArrs[_dataArrs.count - count2+1]];
                                
                                DLog(@"result = %@ , number = %@",numArrs,model2.result);
                                //  complete(true);
                                BOOL isCorrect =  [self queryWinningNumber:model2.result queryArr:numArrs];
                                
                                if (isCorrect) { // 当中奖结果存在
                                    
                                    /** 赢利+9.6 */
                                    totalProfit +=9.60;
                                    
                            
                                    
                                    NSDictionary * paramterDict = @{
                                                                    @"resault":@"中",
                                                                    @"profit":@"9.6",
                                                                    @"totalProfit":@(totalProfit),
                                                                    };
                                    [_resaultTable.dataArrs addObject:paramterDict];
                                } else {
                                    
                                    /** 赢利-10 */
                                    totalProfit -=10;
                                    NSDictionary * paramterDict = @{
                                                                    @"resault":@"没中",
                                                                    @"profit":@"-10",
                                                                    @"totalProfit":@(totalProfit),
                                                                    };
                                    [_resaultTable.dataArrs addObject:paramterDict];
                                    
                                }
                                
                            }
                    }
                        complete(true);
                    }];
                    
                }
                
                currentCount ++;
                count2 --;
            }else {
                
                currentCount = 0;
                count2 = evertNumber + verificationNumber;
            }
            
            
        }];

    }
}


/**
 显示中奖期数

 @param dataArr 中奖数据
 */
-(void)showWinningTotalNumber:(NSArray *)dataArr {
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"SELF == %@",@"中"];
    
    NSMutableArray * resaultArrs = [NSMutableArray new];
    for (NSDictionary * obj in dataArr) {
        [resaultArrs addObject:obj[@"resault"]];
    }
    [resaultArrs filterUsingPredicate:predicate];
    
    NSAlert * alert = [NSAlert new];
    [alert addButtonWithTitle:@"知道了"];
    
    NSString * message;
    if ([dataArr count]/[resaultArrs count] < 2) {

        float tmpPorfit = (float)[resaultArrs count] * 9.6 - (float)([dataArr count] - [resaultArrs count])*10;

        message = [NSString stringWithFormat:@"共验证%ld期,中出 %ld 期,赢利%.2f元!",[dataArr count],[resaultArrs count],tmpPorfit];
    }else {

        float tmpPorfit = (float)[resaultArrs count] * 9.6 - (float)([dataArr count] - [resaultArrs count])*10;

        message = [NSString stringWithFormat:@"共验证%ld期,中出 %ld 期,亏损%.2f元!",[dataArr count],[resaultArrs count],tmpPorfit];
    }

    [alert setInformativeText:message];
    
    [alert beginSheetModalForWindow:[NSApplication sharedApplication].keyWindow completionHandler:^(NSModalResponse returnCode) {
        
    }];
    
    
}



/**
  查询中奖号码

 @param queryString 要查询的奖号
 @param toArray 被查询的数组
 resault bool 返回结果
 */
-(BOOL)queryWinningNumber:(NSString *)queryString  queryArr:(NSArray *)toArray{
    
    NSArray * queryArr = [queryString componentsSeparatedByString:@","];
    
    queryString = [NSString stringWithFormat:@"%@%@",queryArr[queryArr.count -2],queryArr.lastObject];
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS %@",queryString];
    
    NSMutableArray * deleteArrs = [NSMutableArray arrayWithArray:toArray];
    [deleteArrs filterUsingPredicate:predicate];
    
    if ([deleteArrs count] > 0) {
        
        return true;
    }else {
        
        return false;
    }
    
}

/**
 随机生成 N 注开奖号

 @param number 已经验证过开奖号的次数
 @param complete 返回随机出来的开奖号
 */
-(void)arcNumber:(int)number block:(void(^)(NSMutableArray * numArrs))complete {
    
    
    NSMutableArray * numArrs = [NSMutableArray new];
    
    while ([numArrs count] < number) {
        
        int num = arc4random()%99+0;
        NSString * numStr;
        
        if (num < 10) {
            numStr = [NSString stringWithFormat:@"0%d",num];
        }else {
            numStr = [NSString stringWithFormat:@"%d",num];
        }
        
        NSMutableArray * deteleArrs = [NSMutableArray arrayWithArray:numArrs];
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS %@",numStr];
        [deteleArrs filterUsingPredicate:predicate];
        //
        if ([deteleArrs count] > 0) {
            
            [numArrs removeObject:deteleArrs.firstObject];
            [deteleArrs removeAllObjects];
        }
        
        [numArrs addObject:numStr];
        
    }
    
    complete(numArrs);
   
    
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


#pragma mark - 初始化全局属性
-(NSMutableArray *)dataArrs {
    
    if (_dataArrs) return _dataArrs;
    
    return _dataArrs = [NSMutableArray new];
}


@end
