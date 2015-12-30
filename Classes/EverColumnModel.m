//
//  ColumnFenShiChartModel.m
//  TestChart
//
//  Created by Ever on 15/12/18.
//  Copyright © 2015年 Lucky. All rights reserved.
//

#import "EverColumnModel.h"
#import "EverMacro.h"
#import "Section.h"
#import "EverChart.h"

@implementation EverColumnModel

-(void)drawSerie:(EverChart *)chart serie:(NSMutableDictionary *)serie{
    if([serie objectForKey:@"data"] == nil || [[serie objectForKey:@"data"] count] == 0){
        return;
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetShouldAntialias(context, YES);
    CGContextSetLineWidth(context, 1.0f);
    
    NSMutableArray *data          = [serie objectForKey:@"data"];
    
    int            yAxis          = [[serie objectForKey:@"yAxis"] intValue];
    int            section        = [[serie objectForKey:@"section"] intValue];
    
    YAxis *yaxis = [[[chart.sections objectAtIndex:section] yAxises] objectAtIndex:yAxis];
    
    Section *sec = [chart.sections objectAtIndex:section];
    
    //设置选中点
    if(chart.selectedIndex!=-1 && chart.selectedIndex < data.count && [data objectAtIndex:chart.selectedIndex]!=nil){
        
        float value = [[[data objectAtIndex:chart.selectedIndex] objectAtIndex:0] floatValue];
        
        //判断颜色
        float nowPri = [[[data objectAtIndex:chart.selectedIndex] objectAtIndex:1] floatValue];
        float prePri = 0;
        if (chart.selectedIndex == 0) {
            float closeYesterday = [[[data objectAtIndex:chart.selectedIndex] objectAtIndex:2] floatValue];
            prePri = closeYesterday;
        }else {
            prePri = [[[data objectAtIndex:chart.selectedIndex - 1] objectAtIndex:1] floatValue];
        }
        
        UIColor *color = kFenShiUpColor;
        if (nowPri < prePri) {
            color = kFenShiDownColor;
        }else if(nowPri > prePri){
            color = kFenShiUpColor;
        }else{
            color = kFenShiEqualColor;
        }
        
        CGContextSetStrokeColorWithColor(context, [[UIColor alloc] initWithRed:0.2 green:0.2 blue:0.2 alpha:1.0].CGColor);
        
        CGContextMoveToPoint(context, sec.frame.origin.x+sec.paddingLeft+(chart.selectedIndex-chart.rangeFrom)*chart.plotWidth+chart.plotWidth/2, sec.frame.origin.y+sec.paddingTop);
        CGContextAddLineToPoint(context,sec.frame.origin.x+sec.paddingLeft+(chart.selectedIndex-chart.rangeFrom)*chart.plotWidth+chart.plotWidth/2,sec.frame.size.height+sec.frame.origin.y);
        CGContextStrokePath(context);
        
        CGContextSetShouldAntialias(context, YES);
        CGContextBeginPath(context);
        CGContextSetFillColorWithColor(context, color.CGColor);
        if(!isnan([chart getLocalY:value withSection:section withAxis:yAxis])){
            CGContextAddArc(context, sec.frame.origin.x+sec.paddingLeft+(chart.selectedIndex-chart.rangeFrom)*chart.plotWidth+chart.plotWidth/2, [chart getLocalY:value withSection:section withAxis:yAxis], 3, 0, 2*M_PI, 1);
        }
        CGContextFillPath(context);
    }
    
    //画柱状图
    CGContextSetLineWidth(context, 0.8);
    for(int i=chart.rangeFrom;i<chart.rangeTo;i++){
        if(i == data.count){
            break;
        }
        if([data objectAtIndex:i] == nil){
            continue;
        }
        
        float value = [[[data objectAtIndex:i] objectAtIndex:0] floatValue];
        float ix  = sec.frame.origin.x+sec.paddingLeft+(i-chart.rangeFrom)*chart.plotWidth;
        float iy = [chart getLocalY:value withSection:section withAxis:yAxis];
        
        float nowPri = [[[data objectAtIndex:i] objectAtIndex:1] floatValue];
        float prePri = 0;
        if (i == 0) {
            float closeYesterday = [[[data objectAtIndex:i] objectAtIndex:2] floatValue];
            prePri = closeYesterday;
        }else {
            prePri = [[[data objectAtIndex:i - 1] objectAtIndex:1] floatValue];
        }
        
        //显示颜色：实时价格和上一分钟相比较；第一条和昨天收盘价比较；
        if(nowPri < prePri){ //下跌
            if(i == chart.selectedIndex){
                CGContextSetStrokeColorWithColor(context, kFenShiDownColor.CGColor);
                CGContextSetFillColorWithColor(context, kFenShiDownColor.CGColor);
            }else{
                CGContextSetStrokeColorWithColor(context, kFenShiDownColor.CGColor);
                CGContextSetFillColorWithColor(context, kFenShiDownColor.CGColor);
            }
            CGContextFillRect (context, CGRectMake (ix+chart.plotPadding, iy, chart.plotWidth-2*chart.plotPadding,[chart getLocalY:yaxis.baseValue withSection:section withAxis:yAxis]-iy));
            
        }else if(nowPri > prePri){ //上涨
            if(i == chart.selectedIndex){
                CGContextSetStrokeColorWithColor(context, kFenShiUpColor.CGColor);
                CGContextSetFillColorWithColor(context, kFenShiUpColor.CGColor);
            }else{
                CGContextSetStrokeColorWithColor(context, kFenShiUpColor.CGColor);
                CGContextSetFillColorWithColor(context, kFenShiUpColor.CGColor);
            }
            CGContextFillRect (context, CGRectMake (ix+chart.plotPadding, iy, chart.plotWidth-2*chart.plotPadding,[chart getLocalY:yaxis.baseValue withSection:section withAxis:yAxis]-iy));
            
        }else if(nowPri == prePri){

            if(i == chart.selectedIndex){
                CGContextSetStrokeColorWithColor(context, kFenShiEqualColor.CGColor);
                CGContextSetFillColorWithColor(context, kFenShiEqualColor.CGColor);
            }else{
                CGContextSetStrokeColorWithColor(context, kFenShiEqualColor.CGColor);
                CGContextSetFillColorWithColor(context, kFenShiEqualColor.CGColor);
            }
            
            CGContextFillRect (context, CGRectMake (ix+chart.plotPadding, iy, chart.plotWidth-2*chart.plotPadding,[chart getLocalY:yaxis.baseValue withSection:section withAxis:yAxis]-iy));
            
        }
        
    }
    
    //标记X轴时间，只标记首尾
    NSString *fromDate = @"09:30";
    NSString *middleDate = @"11:30/13:00";
    NSString *toDate = @"15:00";
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.alignment = NSTextAlignmentLeft;
    
    [fromDate drawInRect:CGRectMake(sec.frame.origin.x + sec.paddingLeft, sec.frame.origin.y + sec.frame.size.height + 2, 100, kYFontSizeFenShi*2) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:kYFontSizeFenShi],NSParagraphStyleAttributeName:style,NSForegroundColorAttributeName:kYFontColor}];
    
    style.alignment = NSTextAlignmentCenter;
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:kYFontSizeFenShi],NSParagraphStyleAttributeName:style,NSForegroundColorAttributeName:kYFontColor};
    float width = [middleDate sizeWithAttributes:attributes].width;
    [middleDate drawInRect:CGRectMake( (sec.frame.size.width - sec.paddingLeft)/2.0 - width/2.0 + sec.paddingLeft + sec.frame.origin.x, sec.frame.origin.y + sec.frame.size.height + 2, width, kYFontSizeFenShi*2) withAttributes:attributes];
    
    style.alignment = NSTextAlignmentRight;
    [toDate drawInRect:CGRectMake(sec.frame.origin.x + sec.frame.size.width - 100, sec.frame.origin.y + sec.frame.size.height + 2, 100, kYFontSizeFenShi*2) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:kYFontSizeFenShi],NSParagraphStyleAttributeName:style,NSForegroundColorAttributeName:kYFontColor}];
    
}

-(void)setValuesForYAxis:(EverChart *)chart serie:(NSDictionary *)serie{
    if([[serie objectForKey:@"data"] count] == 0){
        return;
    }
    
    NSMutableArray *data    = [serie objectForKey:@"data"];
    NSString       *yAxis   = [serie objectForKey:@"yAxis"];
    NSString       *section = [serie objectForKey:@"section"];
    
    YAxis *yaxis = [[[chart.sections objectAtIndex:[section intValue]] yAxises] objectAtIndex:[yAxis intValue]];
    if([serie objectForKey:@"decimal"] != nil){
        yaxis.decimal = [[serie objectForKey:@"decimal"] intValue];
    }
    
    float value = [[[data objectAtIndex:chart.rangeFrom] objectAtIndex:0] floatValue];
    if(!yaxis.isUsed){
        [yaxis setMax:value];
        [yaxis setMin:value];
        yaxis.isUsed = YES;
    }
    for(int i=chart.rangeFrom;i<chart.rangeTo;i++){
        if(i == data.count){
            break;
        }
        if([data objectAtIndex:i] == nil){
            continue;
        }
        
        float value = [[[data objectAtIndex:i] objectAtIndex:0] floatValue];
        if(value > [yaxis max])
            [yaxis setMax:value];
        if(value < [yaxis min])
            [yaxis setMin:value];
    }
    
}

-(void)setLabel:(EverChart *)chart label:(NSMutableArray *)label forSerie:(NSMutableDictionary *) serie{
    if([serie objectForKey:@"data"] == nil || [[serie objectForKey:@"data"] count] == 0){
        return;
    }
    
    NSMutableArray *data          = [serie objectForKey:@"data"];
    NSString       *lbl           = [serie objectForKey:@"label"];
    int            yAxis          = [[serie objectForKey:@"yAxis"] intValue];
    int            section        = [[serie objectForKey:@"section"] intValue];
    UIColor       *color         = kFenShiVolumeYFontColor;
    
    YAxis *yaxis = [[[chart.sections objectAtIndex:section] yAxises] objectAtIndex:yAxis];
    NSString *format = [NSString stringWithFormat:@"%@:%%.%df",lbl,yaxis.decimal];
    
    if(chart.selectedIndex!=-1 && chart.selectedIndex < data.count && [data objectAtIndex:chart.selectedIndex]!=nil){
        float value = [[[data objectAtIndex:chart.selectedIndex] objectAtIndex:0] floatValue];
        
        NSString *text = [NSString stringWithFormat:format,value];
        
        NSDictionary *tmp = @{@"text":text,@"color":color};
        [label addObject:tmp];
    }
}


@end
