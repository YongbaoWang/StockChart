//
//  ViewController.m
//  FenShiChart
//
//  Created by Ever on 15/12/30.
//  Copyright © 2015年 Ever. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

#pragma mark - View Life
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setup];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View Life Action
- (void)setup{
    
    NSLog(@"home:%@",NSHomeDirectory());
    
    CGFloat width = MAX(self.view.frame.size.width, self.view.frame.size.height);
    CGFloat height = MIN(self.view.frame.size.width, self.view.frame.size.height);
    
    self.fenshiChart = [[EverChart alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    [self.view addSubview:self.fenshiChart];
    
    [self initFenShiChart];
    
    /*
     初始化分时图后，发起网络请求,实时获取数据；这里为演示方便，直接使用本地数据
     */
    NSString *path = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"txt"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    id responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    
    [self renderChart:responseObject];
    
}

#pragma mark - Chart Action
/**
 *  初始化分时图
 */
-(void)initFenShiChart{
    
    NSMutableArray *padding = [NSMutableArray arrayWithObjects:@"0",@"0",@"20",@"5",nil];
    [self.fenshiChart setPadding:padding]; //设置内边距
    NSMutableArray *secs = [[NSMutableArray alloc] init];
    [secs addObject:@"2"]; //设置上下两部分比例
    [secs addObject:@"1"];
    
    [self.fenshiChart addSections:2 withRatios:secs];
    [[[self.fenshiChart sections] objectAtIndex:0] addYAxis:0];
    [[[self.fenshiChart sections] objectAtIndex:1] addYAxis:0];
    
    [self.fenshiChart getYAxis:0 withIndex:0].tickInterval = 4; //设置虚线数量
    [self.fenshiChart getYAxis:1 withIndex:0].tickInterval = 2;
    self.fenshiChart.range = 241; //设置显示区间大小
    
    NSMutableArray *series = [[NSMutableArray alloc] init];
    
    NSMutableArray *secOne = [[NSMutableArray alloc] init];
    NSMutableArray *secTwo = [[NSMutableArray alloc] init];
    
    //均价
    NSMutableDictionary *serie = [[NSMutableDictionary alloc] init];
    NSMutableArray *data = [[NSMutableArray alloc] init];
    [serie setObject:kFenShiAvgNameLine forKey:@"name"]; //用于标记线段名称
    [serie setObject:@"均价" forKey:@"label"]; //当选中时，Label 要显示的名称
    [serie setObject:data forKey:@"data"]; //均线数据 （当获取到实时数据后，就是对此字段赋值；然后实时刷新UI）
    [serie setObject:kFenShiLine forKey:@"type"]; //标记当前绘图类型
    [serie setObject:@"0" forKey:@"yAxisType"]; //标记当前Y轴类型
    [serie setObject:@"0" forKey:@"section"]; //标记当前所属部分
    [serie setObject:kFenShiAvgColor forKey:@"color"]; //均价线段的颜色
    [series addObject:serie];
    [secOne addObject:serie];
    
    
    //实时价
    serie = [[NSMutableDictionary alloc] init];
    data = [[NSMutableArray alloc] init];
    [serie setObject:kFenShiNowNameLine forKey:@"name"];
    [serie setObject:@"数值" forKey:@"label"];
    [serie setObject:data forKey:@"data"];
    [serie setObject:kFenShiLine forKey:@"type"];
    [serie setObject:@"1" forKey:@"yAxisType"];
    [serie setObject:@"0" forKey:@"section"];
    [serie setObject:kFenShiNowColor forKey:@"color"];
    [series addObject:serie];
    [secOne addObject:serie];
    
    
    //VOL
    serie = [[NSMutableDictionary alloc] init];
    data = [[NSMutableArray alloc] init];
    [serie setObject:kFenShiVolNameColumn forKey:@"name"];
    [serie setObject:@"量" forKey:@"label"];
    [serie setObject:data forKey:@"data"];
    [serie setObject:kFenShiColumn forKey:@"type"];
    [serie setObject:@"1" forKey:@"section"];
    [serie setObject:@"0" forKey:@"decimal"]; //保留几位小数
    [series addObject:serie];
    [secTwo addObject:serie];
    
    [self.fenshiChart setSeries:series];
    
    [[[self.fenshiChart sections] objectAtIndex:0] setSeries:secOne];
    [[[self.fenshiChart sections] objectAtIndex:1] setSeries:secTwo];
    
}

-(void)setOptions:(NSDictionary *)options ForSerie:(NSMutableDictionary *)serie;{
    [serie setObject:[options objectForKey:@"name"] forKey:@"name"];
    [serie setObject:[options objectForKey:@"label"] forKey:@"label"];
    [serie setObject:[options objectForKey:@"type"] forKey:@"type"];
    [serie setObject:[options objectForKey:@"yAxis"] forKey:@"yAxis"];
    [serie setObject:[options objectForKey:@"section"] forKey:@"section"];
    [serie setObject:[options objectForKey:@"color"] forKey:@"color"];
}


/**
 *  配置数据源，生成分时图
 *
 *  @param responseObject 数据参数
 */
- (void)renderChart:(NSDictionary *)responseObject{
    
    [self.fenshiChart reset];
    [self.fenshiChart clearData];
    [self.fenshiChart clearCategory];
    
    NSMutableArray *data1 =[[NSMutableArray alloc] init];
    NSMutableArray *data2 =[[NSMutableArray alloc] init];
    NSMutableArray *data3 =[[NSMutableArray alloc] init];
    
    NSMutableArray *category =[[NSMutableArray alloc] init];
    
    NSArray *listArray = responseObject[@"newList"];
    NSArray *closeYesterday = responseObject[@"yesterdayEndPri"];//昨日收盘价
    
    for(int i = 0;i<listArray.count;i++){
        
        NSDictionary *dic = listArray[i];
        [category addObject:dic[@"dateTime"]]; //当前时间
        
        
        NSArray *item1 = @[dic[@"maTimeSharing"],closeYesterday]; //均价
        NSArray *item2 = @[dic[@"nowPri"],closeYesterday]; //实时价格
        
        NSString *volume = [NSString stringWithFormat:@"%d",[dic[@"traNumber"] intValue]/100]; //成交量
        NSArray *item3 = @[volume,dic[@"nowPri"],closeYesterday];
        
        [data1 addObject:item1];
        [data2 addObject:item2];
        [data3 addObject:item3];
        
    }
    
    //上面构造数据的方法，可以按照需求更改；数据源构建完毕后，赋值到分时图上
    [self.fenshiChart appendToData:data1 forName:kFenShiAvgNameLine];
    [self.fenshiChart appendToData:data2 forName:kFenShiNowNameLine];
    [self.fenshiChart appendToData:data3 forName:kFenShiVolNameColumn];
    
    //当被选中时，要显示的数据or文字
    [self.fenshiChart appendToCategory:category forName:kFenShiAvgNameLine];
    [self.fenshiChart appendToCategory:category forName:kFenShiNowNameLine];
    
    //重绘图表
    [self.fenshiChart setNeedsDisplay];
    
}

@end
