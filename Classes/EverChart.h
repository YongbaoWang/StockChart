//
//  ChartFenShi.h
//  TestChart
//
//  Created by Ever on 15/12/18.
//  Copyright © 2015年 Lucky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YAxis.h"
#import "Section.h"
#import "ChartModel.h"
#import "EverLineModel.h"
#import "EverColumnModel.h"
#import "EverMacro.h"

@class ChartModel;

@interface EverChart : UIView {
    bool  enableSelection;
    bool  isInitialized;
    bool  isSectionInitialized;
    float borderWidth;
    float plotWidth;
    float plotPadding;
    float plotCount;
    float paddingLeft;
    float paddingRight;
    float paddingTop;
    float paddingBottom;
    int   rangeFrom;
    int   rangeTo;
    int   range;
    int   selectedIndex;
    float touchFlag;
    float touchFlagTwo;
    NSMutableArray *padding;
    NSMutableArray *series;
    NSMutableArray *sections;
    NSMutableArray *ratios;
    NSMutableDictionary *models;
    UIColor        *borderColor;
    NSString       *title;
    
    CGRect  sec1BtnRect; //k线 btn 区域：用于检测手势是否触摸到该区域
    CGRect sec2BtnRect; //成交量等 btn 区域；
    float touchOne;
    float touchTwo;
}

@property (nonatomic)        bool  enableSelection; //是否可以选中
@property (nonatomic)        bool  isInitialized; //是否初始化
@property (nonatomic)        bool  isSectionInitialized;
@property (nonatomic)        float borderWidth;
@property (nonatomic)        float plotWidth; //单位宽度
@property (nonatomic)        float plotPadding; //单位水平间距
@property (nonatomic)        float plotCount; //单位数量 = data.count
@property (nonatomic)        float paddingLeft;
@property (nonatomic)        float paddingRight;
@property (nonatomic)        float paddingTop;
@property (nonatomic)        float paddingBottom;
@property (nonatomic)        int   rangeFrom; //显示开始下标
@property (nonatomic)        int   rangeTo; //显示结束下班
@property (nonatomic)        int   range; //显示条数
@property (nonatomic)        int   selectedIndex;
@property (nonatomic)        float touchY; //记录选中点的Y坐标
@property (nonatomic)        float touchFlag; //双指手势位置
@property (nonatomic)        float touchFlagTwo; //双指手势位置
@property (nonatomic,retain) NSMutableArray *padding;
@property (nonatomic,retain) NSMutableArray *series;
@property (nonatomic,retain) NSMutableArray *sections;
@property (nonatomic,retain) NSMutableArray  *ratios;
@property (nonatomic,retain) NSMutableDictionary *models;
@property (nonatomic,retain) UIColor  *borderColor;
@property (nonatomic,retain) NSString *title;

-(float)getLocalY:(float)val withSection:(int)sectionIndex withAxis:(int)yAxisIndex;
-(void)setSelectedIndexByPoint:(CGPoint) point;
-(void)reset;

/* init */
-(void)initChart;
-(void)initXAxis;
-(void)initYAxis;
-(void)initModels;
-(void)addModel:(ChartModel *)model withName:(NSString *)name;
-(ChartModel *)getModel:(NSString *)name;

/* draw */
-(void)drawChart;
-(void)drawXAxis;
-(void)drawYAxis;
-(void)drawSerie:(NSMutableDictionary *)serie;
-(void)drawLabels;
-(void)setLabel:(NSMutableArray *)label forSerie:(NSMutableDictionary *) serie;

/* data */
-(void)appendToData:(NSArray *)data forName:(NSString *)name;
-(void)clearDataforName:(NSString *)name;
-(void)clearData;
-(void)setData:(NSMutableArray *)data forName:(NSString *)name;

/* category */
-(void)appendToCategory:(NSArray *)category forName:(NSString *)name;
-(void)clearCategoryforName:(NSString *)name;
-(void)clearCategory;
-(void)setCategory:(NSMutableArray *)category forName:(NSString *)name;

/* series */
-(NSMutableDictionary *)getSerie:(NSString *)name;
-(void)addSerie:(NSObject *)serie;

/* section */
-(Section *)getSection:(int) index;
-(int) getIndexOfSection:(CGPoint) point;
-(void)addSection:(NSString *)ratio;
-(void)removeSection:(int)index;
-(void)addSections:(int)num withRatios:(NSArray *)rats;
-(void)removeSections;
-(void)initSections;

/* YAxis */
/**
 *  获取Y轴对象
 *
 *  @param section 区域
 *  @param index   Y轴位置
 *
 *  @return Y轴对象
 */
-(YAxis *)getYAxis:(int) section withIndex:(int) index;
-(void)setValuesForYAxis:(NSDictionary *)serie;

@end
