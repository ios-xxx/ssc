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
#import "CSYPopViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "CSYWebViewController.h"

@interface ViewController()
{
    /** 每次校验的期数 */
    __block int evertTime;
    
    /** 总赢利 */
    __block float totalProfit;
    
    /** 获取开奖数 */
    __block int dateNumber;
    /** 保存预测开奖号码 */
    NSMutableArray * saveNumberArrs;
    /** 记录当前连错次数 */
    __block int ContinuousErrorCount;
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
/** 开始验证按钮*/
@property (weak) IBOutlet NSButton *verifyBtn;
/** 预测数量 */
@property (weak) IBOutlet NSTextField *forecastNumber;
/** 当前连错 */
@property (weak) IBOutlet NSTextField *currentContinuouserror;


/** 存放开奖数据 */
@property (strong,nonatomic) NSMutableArray * dataArrs;

/** 状态栏图标 */
@property (strong,nonatomic) NSStatusItem * statusItem;
/** Pop属性 */
@property (strong,nonatomic) NSPopover * popover;
/** POp视图控制器 */
@property (strong,nonatomic) CSYPopViewController * popViewController;
/** 播放提示音 */
@property (strong,nonatomic) AVAudioPlayer * play;
/** webView */
@property (strong,nonatomic) CSYWebViewController * webView;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /** 初始化请求 */
    [self initWithRequest];
    /** 初始化状态栏 */
    [self initWithStatusBarItem];
    
}


#pragma mark - 初始化 StatusBarItem
/** 初始化状态栏 */
-(void)initWithStatusBarItem {
    
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [self.statusItem setImage:[NSImage imageNamed:@"cat"]];
    
    self.popover = [NSPopover new];
    self.popover.behavior = NSPopoverBehaviorTransient;
    self.popViewController = [[CSYPopViewController alloc]initWithNibName:@"CSYPopViewController" bundle:nil];
    self.popover.contentViewController = self.popViewController;
    self.popover.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantLight];
    
    /** 为Pop添加事件 */
    self.statusItem.target = self;
    [self.statusItem setAction:@selector(showPop:)];
}

-(void)showPop:(NSStatusBarButton *)sender {
    [_popover showRelativeToRect:sender.bounds  ofView:sender preferredEdge:NSRectEdgeMaxY];
    
}

#pragma mark - 初始化请求
/** 初始化请求 */
-(void)initWithRequest {
    
    
    NSString * urlString = @"https://www.caim8.com/openApi/for_fresh";
    
    
    [CSYRequest requestPostUrl:urlString paramters:nil cookie:nil success:^(NSURLSessionDataTask * _Nonnull task, NSData *data) {
        
        
        NSDictionary * json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        
        //              if ([CSYIsNull isNull:json[@"data"]])
        
        //json = json[@"data"];
        NSArray * resultArr = json[@"data"];
        
        json = resultArr.firstObject;
        
        NSArray * openList = json[@"open_list"];
        //        DLog(@"%@", openList);
        [self.dataArrs setArray:openList];
        
        
        self->_dataArrs = [NSMutableArray arrayWithArray:[[self->_dataArrs reverseObjectEnumerator] allObjects]];
        
        self->_dataTable.dataArr = [NSArray arrayWithArray:self->_dataArrs];
        [self->_dataTable reloadData];
        
        
        //动态移动cell至顶部
        [self->_dataTable scrollRowToVisible:[self->_dataArrs count] -1];
    } error:^(NSError *err) {
        
        NSAlert * alert = [NSAlert new];
        [alert setInformativeText:@"提示"];
        [alert setInformativeText:@"下载历时数据出错,重新下载？"];
        [alert addButtonWithTitle:@"取消"];
        [alert addButtonWithTitle:@"知道了"];
        [alert setAlertStyle:NSAlertStyleWarning];
        
        [alert beginSheetModalForWindow:[NSApplication sharedApplication].keyWindow completionHandler:^(NSModalResponse returnCode) {
            
            if (returnCode == 1001) {
                
                [self initWithRequest];
            }
        }];
        DLog(@"%@",err);
    }];
    
    
    
}

/** 刷新开奖数据 */
-(void)refashData {
    
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        /** 清空保存预测号码的数组 */
        [self->saveNumberArrs removeAllObjects];
        
        NSTimer * timer = [NSTimer timerWithTimeInterval:15 repeats:true block:^(NSTimer * _Nonnull timer) {
            
            
            NSString * url = @"https://www.caim8.com/openApi/for_fresh";
            
            
            [CSYRequest requestPostUrl:url paramters:nil cookie:nil success:^(NSURLSessionDataTask * _Nonnull task, NSData *data) {
                
                NSDictionary * json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                
                
                if ([CSYIsNull isNull:json[@"list"]]) return ;
                
                /** 上一期开奖序列号 */
                NSString * oldPeriod = [self->_dataTable.dataArr.lastObject objectForKey:@"period"];
                /** 当前开奖序列号 */
                NSString * currentPeriod = [[json[@"list"] objectAtIndex:0] objectForKey:@"period"];
                
                
                if ([currentPeriod integerValue] > [oldPeriod integerValue]) {
                    
                    /** 开奖结果字字典 */
                    NSDictionary * resaultNumberDict = [json[@"list"] objectAtIndex:0];
                    [_dataArrs addObject:resaultNumberDict];
                    _dataTable.dataArr = [NSArray arrayWithArray:_dataArrs];
                    [_dataTable reloadData];
                    
                    /** 开奖结果字符串 */
                    NSString * resaultNumberStr = [NSString stringWithFormat:@"%@期：%@", [resaultNumberDict objectForKey:@"period"], [resaultNumberDict objectForKey:@"result"]];
                    [_popViewController.numberResault setStringValue:resaultNumberStr];
                    
                    NSStatusBarButton * stausBarButton = self.statusItem.button;
                    [_popover showRelativeToRect:stausBarButton.bounds ofView:stausBarButton preferredEdge:NSRectEdgeMaxY];
                    
                    //动态移动cell至顶部
                    [_dataTable scrollRowToVisible:[_dataArrs count] -1];
                    /** 验证预测号码 */
                    [self verificationProphesyNumber];
                    /** 播放提示音 */
                    [self.play play];
                    
                    /** 每次验证期数 */
                    evertTime = [_checkTxt.stringValue intValue];
                    evertTime == 0 ? evertTime = 3 : evertTime;
                    
                    /** 验证历时，并生成新号码 */
                    [self verificationverificationNumber:1 evertTime:evertTime number:5];
                    
                    /** 通过定时器关闭 pop */
                    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
                    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC, 1.0 * NSEC_PER_SEC);
                    __block   int time = 0;
                    dispatch_source_set_event_handler(timer, ^{
                        time++;
                        if (time == 7) {
                            
                            [self.popover close];
                            dispatch_cancel(timer);
                            
                        }
                    });
                    dispatch_resume(timer);
                }
            } error:^(NSError *err) {
                
                DLog(@"%@",err);
                
                NSThread * thred =  [NSThread currentThread];
                [thred cancel];
                thred = nil;
            }];
        }];
        
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        [[NSRunLoop currentRunLoop] run];
        
    });
    
    
}


/** 响应开始验证 */
- (IBAction)startVerification:(NSButton *)sender {
    
    /** 清空保存预测号码的数组 */
    saveNumberArrs = [NSMutableArray new];
    [saveNumberArrs removeAllObjects];
    
    sender.enabled = false;
    _stopOperation = false;
    
    
    /** 验证范围 */
    __block NSString * verificationStr = self->_VerificationTxt.stringValue;
    
    /** 每次随机的注数 */
    int arcNumber = [self->_arcNumberTxt.stringValue intValue];
    arcNumber == 0 ? arcNumber = 5 : arcNumber;
    
    /** 须要校验的期数 */
    self->evertTime = [self->_checkTxt.stringValue intValue];
    self->evertTime == 0 ? self->evertTime = 3 : self->evertTime;
    
    /** 初始化总赢利 */
    self->totalProfit = 0.0;
    
    for(int i = 0; i < 1; i++) {
        
       [self createManythreadVerificationStr:verificationStr arcNumber:arcNumber evertTime:self-> evertTime];
        
    }
}


/// 多线程校验开奖号码
/// @param verificationStr 验证范围 5-10
/// @param arcNumber 随机注数
/// @param evertTime 须要校验的期数
-(void)createManythreadVerificationStr:(NSString *) verificationStr arcNumber:(int)arcNumber evertTime:(int)evertTime {
    
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        
        /** 获取须要验证的期数段 */
        NSArray * verificationArr = [verificationStr componentsSeparatedByString:@"-"];
        
        /** 验证范围g开始期数*/
        __block int verificationNumber = [verificationArr.lastObject intValue];
        verificationNumber == 0 ? verificationNumber = 1 : verificationNumber;
        
        
        /** 验证结束期数 */
        int overCount = [verificationArr.firstObject intValue];
        
        while (verificationNumber > overCount) {
            
            if(self->_stopOperation){
                // 当停止验证为真
                
                verificationNumber = 0;
                overCount = 0;
                return ;
            }
            
            if (self->totalProfit/100 > 0.3 && self->_isVerification == true){
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    
                    NSAlert * alert = [NSAlert new];
                    [alert addButtonWithTitle:@"知道了"];
                    [alert setInformativeText:[NSString stringWithFormat:@"恭喜你在第%d期达到%%30赢利",verificationNumber]];
                    
                    [alert beginSheetModalForWindow:[NSApplication sharedApplication].keyWindow completionHandler:^(NSModalResponse returnCode) {
                        
                    }];
                    
                    
                    [self->_resaultTable reloadData];
                    self->_verifyBtn.enabled = true;
                });
                break;
            }
            
            if(self->saveNumberArrs.count < [self->_forecastNumber.stringValue intValue
                                             ]) {
                // 验证开奖结果
                [self verificationverificationNumber:verificationNumber evertTime:self->evertTime number:arcNumber];
            }
            
            // 当保存预测号码的数组元素大于8
            if(self->saveNumberArrs.count >= [self->_forecastNumber.stringValue intValue
            ]) {
                
                
                // 获取当前校验期数开奖数据
                CSYDataModel * model = [CSYDataModel mj_objectWithKeyValues:self->_dataArrs[self->_dataArrs.count - verificationNumber]];
                
                // 通过计算赢利获取查询结果
                [self calculateProfit:model queryNumber:self->saveNumberArrs];
                
                // DLog(@"%d",verificationNumber);
                DLog(@"\n\t\t%@期开奖号码: %@ 预测开奖号码: %@", model.qihao,model.data,[self->saveNumberArrs componentsJoinedByString:@","]);
                
                DLog(@"开始期数：%d 结束期数：%d",verificationNumber,overCount);
                DLog(@"ver = %ld",self->_dataArrs.count - verificationNumber);
                // 如果当前校验能分期等于开奖期数最后一期
                if(self->_dataArrs.count - verificationNumber == self->_dataArrs.count -1) {
                    
                    while (self->_dataArrs.count < [self->_forecastNumber.stringValue intValue
                    ]) {
                        
                        // 验证开奖结果
                        [self verificationverificationNumber:1 evertTime:self->evertTime number:arcNumber];
                    }
                    
                    
                    DLog(@"%@",[self->saveNumberArrs componentsJoinedByString:@","]);

                    //    删除重复元素
                    for(int i = 0 ;i <  self->saveNumberArrs.count; i++ ) {
                        
                        NSString * str = self->saveNumberArrs[i];
                        
                        NSInteger index = [self-> saveNumberArrs indexOfObject:str];
                        DLog(@"index = %ld",index);
                        if(index < self->saveNumberArrs.count) [self-> saveNumberArrs removeObjectAtIndex:index];
                        
                    }
                    
//                    self-> saveNumberArrs = [NSMutableArray arrayWithArray:[sets allObjects]];
                    
                    
                    NSString * number=[self->saveNumberArrs componentsJoinedByString:@","];
                    
                    NSPasteboard * pastedoard = [NSPasteboard generalPasteboard];
                    [pastedoard clearContents];
                    [pastedoard writeObjects:@[number]];
                    
                    DLog(@"\n\n\n\t\t预测%ld期开奖号码为: %@\n\n",[model.qihao integerValue] +1,number);
                    /** 发送通知 */
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"message" object:number];
                    
                }
                
                [self->saveNumberArrs removeAllObjects];
                
                verificationNumber --;
            }
            
            if (verificationNumber == overCount)
            {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if(self-> _stopOperation) return;
                    
                    self->_verifyBtn.enabled = true;
                    self->_stopOperation = true;
                    
                    [self->_resaultTable reloadData];
                    /** 显示中奖总期数 */
                    [self showWinningTotalNumber:[NSArray arrayWithArray:self->_resaultTable.dataArrs]];
                    
                });
            }
            
            
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
    
    [sender setState:1];
    [_errorRadio setState:0];
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
    _verifyBtn.enabled = true;
    
}

/** 响应投注按钮被单击 */
- (IBAction)betting:(id)sender {
    
    NSString * url = @"https://www.caim8.com/openApi/for_fresh";
    
    [CSYRequest requestPostUrl:url paramters:nil cookie:nil success:^(NSURLSessionDataTask * _Nonnull task, NSData *data) {
        
        NSDictionary * json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        
        //json = json[@"data"];
        NSArray * resultArr = json[@"data"];
        
        json = resultArr.firstObject;
        
        NSArray * openList = json[@"open_list"];
        //        DLog(@"%@", openList);
        [self.dataArrs setArray:openList];
        
        self->_dataArrs = [NSMutableArray arrayWithArray:[[self->_dataArrs reverseObjectEnumerator] allObjects]];
        
        //self->_dataTable.dataArr = [NSArray arrayWithArray:self->_dataArrs];
        [self->_dataTable reloadData];
        
        /** 刷新开奖数据 */
        [self refashData];
        
        //动态移动cell至顶部
        [self->_dataTable scrollRowToVisible:[self->_dataArrs count] -1];
    } error:^(NSError *err) {
        
        NSAlert * alert = [NSAlert new];
        [alert setInformativeText:@"提示"];
        [alert setInformativeText:@"下载历时数据出错,重新下载？"];
        [alert addButtonWithTitle:@"取消"];
        [alert addButtonWithTitle:@"知道了"];
        [alert setAlertStyle:NSAlertStyleWarning];
        
        [alert beginSheetModalForWindow:[NSApplication sharedApplication].keyWindow completionHandler:^(NSModalResponse returnCode) {
            
            if (returnCode == 1001) {
                
                [self initWithRequest];
            }
        }];
        DLog(@"%@",err);
    }];
    
    
}

/** 响应webView被单击 */
- (IBAction)webView:(id)sender {
    
    self.webView = [[CSYWebViewController alloc]initWithWindowNibName: @"CSYWebViewController"];
    [_webView.window setTitle:@"财猫"];
    [self.webView.window orderFront:nil];
}



#pragma mark - 兑奖号码生成
/**
 验证开奖结果
 
 @param verificationNumber 倒数第几期开始验证
 @param arcNumber    每次随机生成的注数
 @param evertTime    要校验的期数
 return 返回结果
 */
-(BOOL)verificationverificationNumber:(int)verificationNumber evertTime:(int)evertTime  number:(int)arcNumber {
    
    if(self->saveNumberArrs.count >= [self->_forecastNumber.stringValue intValue
    ]) return false;
    
    /** 当前验证次数 */
    __block int  currentCount=0;
    
    /** 倒数第几期开始验证 */
    __block int count2 = evertTime + verificationNumber;
    
    // 获取要校验期数的开奖号码
    CSYDataModel * model;
    // 获取随机号码
    NSMutableArray * numArrs;
    // 查询随机出来的号码是否包含开奖号
    BOOL isCorrect;
    
    
    
    while (currentCount != evertTime+1) {
        // 当停止验证为真
        if(_stopOperation || self-> saveNumberArrs.count >= [self->_forecastNumber.stringValue intValue
        ]) return false;
        
        DLog(@" 校验倒数第 %d 期",count2);
        
        // 获取要校验期数的开奖号码
        model = [CSYDataModel mj_objectWithKeyValues:_dataArrs[_dataArrs.count - count2]];
        // 获取随机号码
        numArrs = [self arcNumber:arcNumber];
        // 查询随机出来的号码是否包含开奖号
        isCorrect = [self queryWinningNumber:model.data queryArr:numArrs];
        
        
        // 如果中奖号在这个数组中
        if (isCorrect){
            
            DLog(@"current = %d evertTime = %d", currentCount, evertTime);
            // 判断当前期数 是否和要校验的期数相等
            if (currentCount == evertTime)
            {
                
                numArrs = [self arcNumber:arcNumber];
                
                for(NSString * str in numArrs) {
                    
                    [self->saveNumberArrs addObject:str];
                }
            }
            
            currentCount ++;
            count2 --;
            
        }else {
            
            // 如果不存在则重新开始验证
            currentCount = 0;
            count2 = evertTime + verificationNumber;
        }
        
        
    }
    return false;
}


/// 计算赢利
/// @param model 开奖数据
/// @param numArrs 要查询的开奖号
-(BOOL)calculateProfit:(CSYDataModel *)model queryNumber:(NSMutableArray *)numArrs {
    
    
    BOOL isCorrect =  [self queryWinningNumber:model.data queryArr:numArrs];
    
    //    数组取重
    NSMutableSet * sets = [NSMutableSet set];
    for(NSString * str in numArrs) {
        [sets addObject:str];
    }
    
    numArrs = [NSMutableArray arrayWithArray:[sets allObjects]];
    float profit;
    
    if (isCorrect) { // 当中奖结果存在
        
        /** 赢利 */
        profit =19.6- numArrs.count * 2;
        totalProfit += profit;
        
        NSDictionary * paramterDict = @{
            @"qihao": model.qihao,
            @"data" : model.data,
            @"forecas" : [numArrs componentsJoinedByString:@","],
            @"resault":@"中",
            @"profit":@(profit),
            @"totalProfit":@(totalProfit),
        };
        [_resaultTable.dataArrs addObject:paramterDict];
        
        
    } else {
        
        /** -赢利 */
        profit = numArrs.count * 2;
        totalProfit -=profit;
        NSDictionary * paramterDict = @{
            @"qihao": model.qihao,
            @"data" : model.data,
            @"forecas" : [numArrs componentsJoinedByString:@","],
            @"resault":@"没中",
            @"profit":@(-profit),
            @"totalProfit":@(totalProfit),
        };
        [_resaultTable.dataArrs addObject:paramterDict];
        
    }
    
    return isCorrect;
    
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
    
    NSString * profiteStr = [_resaultTable.dataArrs.lastObject objectForKey:@"totalProfit"];
    NSString * message = [NSString stringWithFormat:@"共验证%ld期,中出 %ld 期,赢利%@元!",[dataArr count],[resaultArrs count],profiteStr];
    
    [alert setInformativeText:message];
    
    [alert beginSheetModalForWindow:[NSApplication sharedApplication].keyWindow completionHandler:^(NSModalResponse returnCode) {
        
    }];
    
    
}

/** 验证预测号码 */
-(void)verificationProphesyNumber {
    
    
    /** 判断是否有开奖数据 */
    if (saveNumberArrs.count > 0) {
        
        DLog(@"开奖号码：%@",[_dataTable.dataArr.lastObject objectForKey:@"result"]);
        BOOL isCorrect =  [self queryWinningNumber:[_dataTable.dataArr.lastObject objectForKey:@"result"] queryArr:[NSArray arrayWithArray:saveNumberArrs]];
        float profit;
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
        
        // xx-net0-266914|xx-net1-266915|xx-net2-267105
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self->_resaultTable reloadData];
        });
        
    }
}


/**
 查询中奖号码
 
 @param queryString 要查询的奖号
 @param toArray 被查询的数组
 resault bool 返回结果
 */
-(BOOL)queryWinningNumber:(NSString *)queryString  queryArr:(NSArray *)toArray{
    
    NSArray * queryArr = [queryString componentsSeparatedByString:@","];
    queryString = [NSString stringWithFormat:@"%@",queryArr.lastObject];
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS %@",queryString];
    
    NSMutableArray * deleteArrs = [NSMutableArray arrayWithArray:toArray];
    [deleteArrs filterUsingPredicate:predicate];
    
//    DLog(@"arr = %ld", deleteArrs.count);
    if ([deleteArrs count] > 0) {
        
        return true;
    }else {
        
        return false;
    }
    
}

/**
 随机生成 N 注开奖号
 
 @param number 已经验证过开奖号的次数
 return 返回开奖号
 */
-(NSMutableArray *)arcNumber:(int)number {
    
    
    NSMutableArray * numArrs = [NSMutableArray new];
    
    while ([numArrs count] < number) {
        
        int num = arc4random_uniform(10);
        NSString * numStr;
        
        if (num < 10) {
            numStr = [NSString stringWithFormat:@"%d",num];
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
    
    return numArrs;
    
    
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    
    // Update the view, if already loaded.
}


#pragma mark - 初始化全局属性

/// 初始化开奖号数组
-(NSMutableArray *)dataArrs {
    
    if (_dataArrs) return _dataArrs;
    
    return _dataArrs = [NSMutableArray new];
}


-(AVAudioPlayer *)play {
    
    if (_play) return _play;
    
    NSString * pathUrl = [[NSBundle mainBundle] pathForResource:@"message" ofType:@"mp3"];
    NSURL * url = [NSURL fileURLWithPath:pathUrl];
    
    NSError * err;
    self.play = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:&err];
    [self.play prepareToPlay];
    
    return _play;
}

@end
