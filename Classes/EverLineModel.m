//
//  LineFenShiModel.m
//  TestChart
//
//  Created by Ever on 15/12/18.
//  Copyright © 2015年 Lucky. All rights reserved.
//

#import "EverLineModel.h"
#import "Section.h"
#import "EverChart.h"
#import "EverMacro.h"

@implementation EverLineModel

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
    UIColor       *color         = [serie objectForKey:@"color"];
    
    Section *sec = [chart.sections objectAtIndex:section];
    
    //设置选中点 竖线以及小球颜色
    if(chart.selectedIndex!=-1 && chart.selectedIndex < data.count && [data objectAtIndex:chart.selectedIndex]!=nil){
        
        //设置选中点竖线
        float value = [[[data objectAtIndex:chart.selectedIndex] objectAtIndex:0] floatValue];

        CGContextSetShouldAntialias(context, YES);
        CGContextSetLineWidth(context, 0.8);
        CGContextSetStrokeColorWithColor(context, kYFontColor.CGColor);
        
        //画竖线
        CGContextMoveToPoint(context, sec.frame.origin.x+sec.paddingLeft+(chart.selectedIndex-chart.rangeFrom)*chart.plotWidth+chart.plotWidth/2, sec.frame.origin.y+sec.paddingTop);
        CGContextAddLineToPoint(context,sec.frame.origin.x+sec.paddingLeft+(chart.selectedIndex-chart.rangeFrom)*chart.plotWidth+chart.plotWidth/2,sec.frame.size.height+sec.frame.origin.y);
        CGContextStrokePath(context);
            
        //设置选中点小球颜色
        CGContextBeginPath(context);
        CGContextSetFillColorWithColor(context, color.CGColor);
        if(!isnan([chart getLocalY:value withSection:section withAxis:yAxis])){
            CGContextAddArc(context, sec.frame.origin.x+sec.paddingLeft+(chart.selectedIndex-chart.rangeFrom)*chart.plotWidth+chart.plotWidth/2, [chart getLocalY:value withSection:section withAxis:yAxis], 3, 0, 2*M_PI, 1);
        }
        CGContextFillPath(context);
        
        //画横线
        if (chart.touchY > sec.paddingTop && chart.touchY < sec.frame.size.height) {
            CGContextMoveToPoint(context, sec.frame.origin.x + sec.paddingLeft, chart.touchY);
            CGContextAddLineToPoint(context, sec.frame.origin.x + sec.frame.size.width, chart.touchY);
            CGContextStrokePath(context);
            
            //计算横线对应刻度
            YAxis *yaxis = sec.yAxises[0];
            CGFloat touchPointValue = (sec.frame.origin.y + sec.frame.size.height - chart.touchY)/(sec.frame.size.height - sec.paddingTop) * (yaxis.max - yaxis.min) + yaxis.min;
            
            //画横线左侧刻度标记
            NSString *text;
            if (yaxis.decimal == 0) {
                text = [NSString stringWithFormat:@"%d",(int)touchPointValue];
            }else{
                text = [NSString stringWithFormat:@"%.2f",touchPointValue];
            }
            
            NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
            style.alignment = NSTextAlignmentCenter;
            
            NSDictionary *attributes = @{NSFontAttributeName:[UIFont fontWithName:@"Helvetica" size:kYFontSizeFenShi],NSParagraphStyleAttributeName:style};
            CGSize textSize = [text sizeWithAttributes:attributes];
            CGRect rect = CGRectMake(sec.paddingLeft + sec.frame.origin.x - textSize.width - 3, chart.touchY - (textSize.height + 2)/2.0, textSize.width + 2, textSize.height + 2);
            
            CGContextSetShouldAntialias(context, YES);
            CGContextSetStrokeColorWithColor(context, kYFontColor.CGColor);
            CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
            CGContextSetLineWidth(context, 1);
            
            CGContextFillRect(context, rect);
            
            UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:4];
            CGContextAddPath(context, path.CGPath);
            CGContextStrokePath(context);
            
            [text drawInRect:rect withAttributes:attributes];
            
        }

    }
    
    CGContextSetShouldAntialias(context, YES);
    for(int i=chart.rangeFrom;i<chart.rangeTo;i++){
        if(i == data.count-1){
            break;
        }
        if([data objectAtIndex:i] == nil){
            continue;
        }
        if (i<chart.rangeTo-1 && [data objectAtIndex:(i+1)] != nil) {
            float value = [[[data objectAtIndex:i] objectAtIndex:0] floatValue];
            float ix  = sec.frame.origin.x+sec.paddingLeft+(i-chart.rangeFrom)*chart.plotWidth;
            float iNx  = sec.frame.origin.x+sec.paddingLeft+(i+1-chart.rangeFrom)*chart.plotWidth;
            float iy = [chart getLocalY:value withSection:section withAxis:yAxis];
            CGContextSetStrokeColorWithColor(context, color.CGColor);
            CGContextMoveToPoint(context, ix+chart.plotWidth/2, iy);
            
            float y = [chart getLocalY:([[[data objectAtIndex:(i+1)] objectAtIndex:0] floatValue]) withSection:section withAxis:yAxis];
            if(!isnan(y)){
                CGContextAddLineToPoint(context, iNx+chart.plotWidth/2, y);
            }
            
            CGContextStrokePath(context);
        }
    }
    
}

-(void)setValuesForYAxis:(EverChart *)chart serie:(NSDictionary *)serie{
    if([[serie objectForKey:@"data"] count] == 0){
        return;
    }
    
    NSMutableArray *data    = [serie objectForKey:@"data"];
    NSString       *yAxis   = [serie objectForKey:@"yAxis"];
    NSString       *yAxisType   = [serie objectForKey:@"yAxisType"];
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
    
    //实时价格线:  Y轴区间:昨天收盘价 上下浮动最大涨跌幅； 当前最大涨跌幅 ：（最大/最小 - 昨天收盘价）/ 昨天收盘价
    if ([yAxisType isEqualToString:@"1"]) {
        
        float maxNow = 0,minNow = MAXFLOAT;
        float closeYesterday = [[data[0] objectAtIndex:0] floatValue];
        
        for(int i = 0; i < data.count; i++) {
            NSArray *tmpArray = data[i];
            float now = [tmpArray[0] floatValue];
            if (minNow > now) {
                minNow = now;
            }
            else if (maxNow < now) {
                maxNow = now;
            }
        }
        
        float percentMax = (maxNow - closeYesterday)/closeYesterday;
        float percentMin = (minNow - closeYesterday)/closeYesterday;
        float percent = MAX(fabs(percentMax), fabs(percentMin)) ;
        float maxY = closeYesterday * (1 + percent);
        float minY = closeYesterday * (1 - percent);
        
        [yaxis setMax:maxY];
        [yaxis setMin:minY];
        NSLog(@"min:%f,max:%f",minY,maxY);
        
        return;
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
    //	NSString       *type          = [serie objectForKey:@"type"];
    NSString       *lbl           = [serie objectForKey:@"label"];
    int            yAxis          = [[serie objectForKey:@"yAxis"] intValue];
    NSString       *yAxisType     = [serie objectForKey:@"yAxisType"];
    int            section        = [[serie objectForKey:@"section"] intValue];
    UIColor       *color         = [serie objectForKey:@"color"];
    
    YAxis *yaxis = [[[chart.sections objectAtIndex:section] yAxises] objectAtIndex:yAxis];
    NSString *format = [NSString stringWithFormat:@"%@:%%.%df",lbl,yaxis.decimal];
    
    if(chart.selectedIndex!=-1 && chart.selectedIndex < data.count && [data objectAtIndex:chart.selectedIndex]!=nil){
        float value = [[[data objectAtIndex:chart.selectedIndex] objectAtIndex:0] floatValue];
        
        if ([yAxisType isEqualToString:@"1"]) {
            
            float closeYesterday = [[[data objectAtIndex:chart.selectedIndex] objectAtIndex:1] floatValue];
            UIColor *lblColor = [UIColor grayColor];
            
            if (value < closeYesterday) { //下跌
                lblColor = kFenShiDownColor;
            }
            else if(value > closeYesterday){ //上涨
                lblColor = kFenShiUpColor;
            }
            else{ //持平
                lblColor = kFenShiEqualColor;
            }
            
            //实时价格标签
            NSString *text = [NSString stringWithFormat:format,value];
            [label addObject:@{@"text":text,@"color":lblColor}];
            
            //差值
            format = [NSString stringWithFormat:@"%%.%df",yaxis.decimal];
            NSString *diffValue = [NSString stringWithFormat:format,value - closeYesterday];
            [label addObject:@{@"text":diffValue,@"color":lblColor}];
            
            //差值百分比
            format = [NSString stringWithFormat:@"%%.%df%%",yaxis.decimal];
            NSString *diffPercent = [NSString stringWithFormat:format,(value - closeYesterday)/closeYesterday * 100];
            [label addObject:@{@"text":diffPercent,@"color":lblColor}];

            //实时价格中的最高价/最低价
            float maxPrice = 0;
            float minPrice = MAXFLOAT;
            for (NSArray *array in data) {
                float nowPrice = [array[0] floatValue];
                if (maxPrice < nowPrice) {
                    maxPrice = nowPrice;
                }
                if(minPrice > nowPrice){
                    minPrice = nowPrice;
                }
            }
            //最高
            [label addObject:@{@"text":@"高",@"color":kFenShiEqualColor}];
            lblColor = (maxPrice > closeYesterday)? kFenShiUpColor : (maxPrice < closeYesterday ? kFenShiDownColor :kFenShiEqualColor);
            [label addObject:@{@"text":[NSString stringWithFormat:@"%.2f",maxPrice], @"color":lblColor}];
            
            //最低
            [label addObject:@{@"text":@"低",@"color":kFenShiEqualColor}];
            lblColor = (minPrice > closeYesterday)? kFenShiUpColor : (minPrice < closeYesterday ? kFenShiDownColor :kFenShiEqualColor);
            [label addObject:@{@"text":[NSString stringWithFormat:@"%.2f",minPrice], @"color":lblColor}];

            //开盘价
            [label addObject:@{@"text":@"开",@"color":kFenShiEqualColor}];
            [label addObject:@{@"text":@"--", @"color":kFenShiUpColor}];


        }else {
            
            NSString *text = [NSString stringWithFormat:format,value];
            
            NSDictionary *tmp = @{@"text":text,@"color":color};
            [label addObject:tmp];

        }
        
    }
}

-(void)drawTips:(EverChart *)chart serie:(NSMutableDictionary *)serie{
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetShouldAntialias(context, NO);
    CGContextSetLineWidth(context, 1.0f);
    
    NSMutableArray *data          = [serie objectForKey:@"data"];
    NSString       *type          = [serie objectForKey:@"type"];
    int            section        = [[serie objectForKey:@"section"] intValue];
    NSMutableArray *category      = [serie objectForKey:@"category"];
    Section *sec = [chart.sections objectAtIndex:section];
    
    if([type isEqualToString:kFenShiLine]){
        for(int i=chart.rangeFrom;i<chart.rangeTo;i++){
            if(i == data.count){
                break;
            }
            if([data objectAtIndex:i] == nil){
                continue;
            }
            
            float ix  = sec.frame.origin.x+sec.paddingLeft+(i-chart.rangeFrom)*chart.plotWidth;
            
            if(i == chart.selectedIndex && chart.selectedIndex < data.count && [data objectAtIndex:chart.selectedIndex]!=nil){
                
                NSString *tipsText = [NSString stringWithFormat:@"%@",[category objectAtIndex:chart.selectedIndex]];
                
                CGContextSetShouldAntialias(context, YES);
                CGContextSetStrokeColorWithColor(context, kYFontColor.CGColor);
                CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
                
                CGSize size = [tipsText sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica" size:kYFontSizeFenShi]}];
                
                int x = ix+chart.plotWidth/2;
                int y = sec.frame.origin.y+sec.paddingTop;
                if(x+size.width > sec.frame.size.width+sec.frame.origin.x){
                    x= x-(size.width+4);
                }
                CGContextFillRect (context, CGRectMake (x, y, size.width+4,size.height+2));
                UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(x, y, size.width+4,size.height+2) cornerRadius:4];
                CGContextAddPath(context, path.CGPath);
                CGContextStrokePath(context);
                
                [tipsText drawAtPoint:CGPointMake(x+2,y+1) withAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica" size:kYFontSizeFenShi]}];
                CGContextSetShouldAntialias(context, NO);
                
                
            }
        }
    }
    
}

@end
