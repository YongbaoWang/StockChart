//
//  ChartFenShi.m
//  TestChart
//
//  Created by Ever on 15/12/18.
//  Copyright © 2015年 Lucky. All rights reserved.
//

#import "EverChart.h"
#import "EverMacro.h"

#define MIN_INTERVAL  3

@implementation EverChart

@synthesize enableSelection;
@synthesize isInitialized;
@synthesize isSectionInitialized;
@synthesize borderColor;
@synthesize borderWidth;
@synthesize plotWidth;
@synthesize plotPadding;
@synthesize plotCount;
@synthesize paddingLeft;
@synthesize paddingRight;
@synthesize paddingTop;
@synthesize paddingBottom;
@synthesize padding;
@synthesize selectedIndex;
@synthesize touchFlag;
@synthesize touchFlagTwo;
@synthesize rangeFrom;
@synthesize rangeTo;
@synthesize range;
@synthesize series;
@synthesize sections;
@synthesize ratios;
@synthesize models;
@synthesize title;

-(float)getLocalY:(float)val withSection:(int)sectionIndex withAxis:(int)yAxisIndex{
    Section *sec = [[self sections] objectAtIndex:sectionIndex];
    YAxis *yaxis = [sec.yAxises objectAtIndex:yAxisIndex];
    CGRect fra = sec.frame;
    float  max = yaxis.max;
    float  min = yaxis.min;
    
    if (max == min) {
        return 0;
    }
    return fra.size.height - (fra.size.height-sec.paddingTop)* (val-min)/(max-min)+fra.origin.y;
}

- (void)initChart{
    if(!self.isInitialized){
        self.plotPadding = 0.5;
        if(self.padding != nil){
            self.paddingTop    = [[self.padding objectAtIndex:0] floatValue];
            self.paddingRight  = [[self.padding objectAtIndex:1] floatValue];
            self.paddingBottom = [[self.padding objectAtIndex:2] floatValue];
            self.paddingLeft   = [[self.padding objectAtIndex:3] floatValue];
        }
        
        if(self.series!=nil){
            self.rangeTo = (int)[[[[self series] objectAtIndex:0] objectForKey:@"data"] count];
            if(rangeTo-range >= 0){
                self.rangeFrom = rangeTo-range;
            }else{
                self.rangeFrom = 0;
            }
        }else{
            self.rangeTo   = 0;
            self.rangeFrom = 0;
        }
        self.selectedIndex = self.rangeTo-1;
        self.isInitialized = YES;
    }
    
    if(self.series!=nil){
        self.plotCount = [[[[self series] objectAtIndex:0] objectForKey:@"data"] count];
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(context, 255/255.0, 255/255.0, 255/255.0, 1.0);
    CGContextFillRect (context, CGRectMake (0, 0, self.bounds.size.width,self.bounds.size.height));
}

-(void)reset{
    self.isInitialized = NO;
}

- (void)initXAxis{
    
}

- (void)initYAxis{
    for(int secIndex=0;secIndex<[self.sections count];secIndex++){
        Section *sec = [self.sections objectAtIndex:secIndex];
        for(int sIndex=0;sIndex<[sec.yAxises count];sIndex++){
            YAxis *yaxis = [sec.yAxises objectAtIndex:sIndex];
            yaxis.isUsed = NO;
        }
    }
    
    for(int secIndex=0;secIndex<[self.sections count];secIndex++){
        Section *sec = [self.sections objectAtIndex:secIndex];
        if(sec.paging && [[sec series] count] > 0){
            NSObject *serie = [[sec series] objectAtIndex:sec.selectedIndex];
            if([serie isKindOfClass:[NSArray class]]){
                NSArray *se = (NSArray *)serie;
                for(int i=0;i<[se count];i++){
                    [self setValuesForYAxis:[se objectAtIndex:i]];
                }
            }else {
                [self setValuesForYAxis:(NSDictionary *)serie];
            }
        }else{
            for(int sIndex=0;sIndex<[sec.series count];sIndex++){
                NSObject *serie = [[sec series] objectAtIndex:sIndex];
                if([serie isKindOfClass:[NSArray class]]){
                    NSArray *se = (NSArray *)serie;
                    for(int i=0;i<[se count];i++){
                        [self setValuesForYAxis:[se objectAtIndex:i]];
                    }
                }else {
                    [self setValuesForYAxis:(NSDictionary *)serie];
                }
            }
        }
        
        for(int i = 0;i<sec.yAxises.count;i++){
            YAxis *yaxis = [sec.yAxises objectAtIndex:i];
            yaxis.max += (yaxis.max-yaxis.min)*yaxis.ext;
            yaxis.min -= (yaxis.max-yaxis.min)*yaxis.ext;
            
            if(!yaxis.baseValueSticky){
                if(yaxis.max >= 0 && yaxis.min >= 0){
                    yaxis.baseValue = yaxis.min;
                }else if(yaxis.max < 0 && yaxis.min < 0){
                    yaxis.baseValue = yaxis.max;
                }else{
                    yaxis.baseValue = 0;
                }
            }else{
                if(yaxis.baseValue < yaxis.min){
                    yaxis.min = yaxis.baseValue;
                }
                
                if(yaxis.baseValue > yaxis.max){
                    yaxis.max = yaxis.baseValue;
                }
            }
            
            if(yaxis.symmetrical == YES){
                if(yaxis.baseValue > yaxis.max){
                    yaxis.max =  yaxis.baseValue + (yaxis.baseValue-yaxis.min);
                }else if(yaxis.baseValue < yaxis.min){
                    yaxis.min =  yaxis.baseValue - (yaxis.max-yaxis.baseValue);
                }else {
                    if((yaxis.max-yaxis.baseValue) > (yaxis.baseValue-yaxis.min)){
                        yaxis.min =  yaxis.baseValue - (yaxis.max-yaxis.baseValue);
                    }else{
                        yaxis.max =  yaxis.baseValue + (yaxis.baseValue-yaxis.min);
                    }
                }
            }
        }
        
    }
}

-(void)initBtn{
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, kBtnBgColor.CGColor);
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    
    NSString *text = @"分时量";
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.alignment = NSTextAlignmentCenter;
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:kYFontSizeFenShi],NSForegroundColorAttributeName:[UIColor whiteColor],NSParagraphStyleAttributeName:style};
    CGSize btnSize = [text sizeWithAttributes:attributes];

    
    Section *sec2 = self.sections[1];
    float offset = 2;
    CGRect btn2Rect = CGRectMake(1, sec2.frame.origin.y + offset, sec2.paddingLeft , sec2.paddingTop - offset * 2);
    CGContextBeginPath(context);
    
    UIBezierPath *path2 = [UIBezierPath bezierPathWithRoundedRect:btn2Rect cornerRadius:3];
    CGContextAddPath(context, path2.CGPath);
    CGContextClosePath(context);
    CGContextFillPath(context);
    
    [text drawInRect:CGRectInset(btn2Rect, 0, (btn2Rect.size.height - btnSize.height)/2.0) withAttributes:attributes];
    
}

-(void)setValuesForYAxis:(NSDictionary *)serie{
    NSString   *type  = [serie objectForKey:@"type"];
    ChartModel *model = [self getModel:type];
    [model setValuesForYAxis:self serie:serie];
}

-(void)drawChart{
    
    for(int secIndex=0;secIndex<self.sections.count;secIndex++){
        Section *sec = [self.sections objectAtIndex:secIndex];
        if(sec.hidden){
            continue;
        }
//        plotWidth = (sec.frame.size.width-sec.paddingLeft)/(self.rangeTo-self.rangeFrom);
        plotWidth = (sec.frame.size.width - sec.paddingLeft)/241.0;
        for(int sIndex=0;sIndex<sec.series.count;sIndex++){
            NSObject *serie = [sec.series objectAtIndex:sIndex];
            
            if(sec.hidden){
                continue;
            }
            
            if(sec.paging){
                if (sec.selectedIndex == sIndex) {
                    if([serie isKindOfClass:[NSArray class]]){
                        NSArray *se = (NSArray *)serie;
                        for(int i=0;i<[se count];i++){
                            [self drawSerie:[se objectAtIndex:i]];
                        }
                    }else{
                        [self drawSerie:(NSMutableDictionary *)serie];
                    }
                    break;
                }
            }else{
                if([serie isKindOfClass:[NSArray class]]){
                    NSArray *se = (NSArray *)serie;
                    for(int i=0;i<[se count];i++){
                        [self drawSerie:[se objectAtIndex:i]];
                    }
                }else{
                    [self drawSerie:(NSMutableDictionary *)serie];
                }
            }
        }
    }
    [self drawLabels];
}

-(void)drawLabels{
    
    for(int i=0;i<self.sections.count;i++){
        Section *sec = [self.sections objectAtIndex:i];
        if(sec.hidden){
            continue;
        }
        
        float w = 0;
        for(int s=0;s<sec.series.count;s++){
                        
            NSMutableArray *label =[[NSMutableArray alloc] init];
            NSObject *serie = [sec.series objectAtIndex:s];
            
            if(sec.paging){
                if (sec.selectedIndex == s) {
                    if([serie isKindOfClass:[NSArray class]]){
                        NSArray *se = (NSArray *)serie;
                        for(int i=0;i<[se count];i++){
                            [self setLabel:label forSerie:[se objectAtIndex:i]];
                        }
                    }else{
                        [self setLabel:label forSerie:(NSMutableDictionary *)serie];
                    }
                }
            }else{
                if([serie isKindOfClass:[NSArray class]]){
                    NSArray *se = (NSArray *)serie;
                    for(int i=0;i<[se count];i++){
                        [self setLabel:label forSerie:[se objectAtIndex:i]];
                    }
                }else{
                    [self setLabel:label forSerie:(NSMutableDictionary *)serie];
                }
            }
            for(int j=0;j<label.count;j++){
                
                NSMutableDictionary *lbl = [label objectAtIndex:j];
                NSString *text  = [lbl objectForKey:@"text"];
                UIColor *textColor = [lbl objectForKey:@"color"];
                
                CGContextRef context = UIGraphicsGetCurrentContext();
                CGContextSetShouldAntialias(context, YES);
                
                CGSize textSize = [text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]}];
                CGRect rect = CGRectZero;
                if (i == 0) {
                    rect = CGRectMake(5 + w + 5 * i, sec.frame.origin.y + (sec.paddingTop - textSize.height)/2.0, textSize.width, textSize.height);
                }
                else
                {
                    rect = CGRectMake(sec.frame.origin.x + sec.paddingLeft + w + 10, sec.frame.origin.y + (sec.paddingTop - textSize.height)/2.0, textSize.width, textSize.height);
                }
                
                [text drawInRect:rect withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13],NSForegroundColorAttributeName:textColor}];
                w += textSize.width + 5;
            }
        }
    }
}

-(void)setLabel:(NSMutableArray *)label forSerie:(NSMutableDictionary *) serie{
    NSString   *type  = [serie objectForKey:@"type"];
    ChartModel *model = [self getModel:type];
    [model setLabel:self label:label forSerie:serie];
}

-(void)drawSerie:(NSMutableDictionary *)serie{
    NSString   *type  = [serie objectForKey:@"type"];
    ChartModel *model = [self getModel:type];
    [model drawSerie:self serie:serie];
    
    NSEnumerator *enumerator = [self.models keyEnumerator];
    id key;
    while ((key = [enumerator nextObject])){
        ChartModel *m = [self.models objectForKey:key];
        [m drawTips:self serie:serie];
    }
}

-(void)drawYAxis{
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetShouldAntialias(context, YES);
    CGContextSetLineWidth(context, 1.0f);
    
    for(int secIndex=0;secIndex<[self.sections count];secIndex++){
        Section *sec = [self.sections objectAtIndex:secIndex];
        if(sec.hidden){
            continue;
        }
        
        //左边Y轴
        CGContextMoveToPoint(context, sec.frame.origin.x+sec.paddingLeft,sec.frame.origin.y+sec.paddingTop);
        CGContextAddLineToPoint(context, sec.frame.origin.x+sec.paddingLeft,sec.frame.size.height+sec.frame.origin.y);
        
        //右边Y轴
        CGContextMoveToPoint(context, sec.frame.origin.x+sec.frame.size.width,sec.frame.origin.y+sec.paddingTop);
        CGContextAddLineToPoint(context, sec.frame.origin.x+sec.frame.size.width,sec.frame.size.height+sec.frame.origin.y);
        
    }
    CGContextStrokePath(context);
    
    for(int secIndex=0;secIndex<[self.sections count];secIndex++){
        Section *sec = [self.sections objectAtIndex:secIndex];
        if(sec.hidden){
            continue;
        }

        //中间竖线(虚线)
        float interWidth = (sec.frame.size.width - sec.paddingLeft)/4.0;
        for (int i = 1; i< 4; i++) {
            
            if (i == 2) { //设置实线
                CGContextSetLineDash(context, 0, 0, 0);
                CGContextSetLineWidth(context, 0.8);
            }else{
                //设置虚线
                CGFloat dash[] = {1,1};
                CGContextSetLineDash (context,20,dash,2);
                CGContextSetLineWidth(context, 1);
            }

            CGContextMoveToPoint(context, sec.frame.origin.x+sec.paddingLeft + interWidth * i, sec.frame.origin.y+sec.paddingTop);
            CGContextAddLineToPoint(context, sec.frame.origin.x+sec.paddingLeft + interWidth * i, sec.frame.size.height+sec.frame.origin.y);
            
            CGContextStrokePath(context);
        }

    }
    
    for(int secIndex=0;secIndex<self.sections.count;secIndex++){
        
        Section *sec = [self.sections objectAtIndex:secIndex];
        if(sec.hidden){
            continue;
        }
        for(int aIndex=0;aIndex<sec.yAxises.count;aIndex++){
            
            YAxis *yaxis = [sec.yAxises objectAtIndex:aIndex];
            
            //获取Y轴类型
            NSObject *seriesY = [sec.series objectAtIndex:aIndex];
            NSString *yAxisType = @"";
            if ([seriesY isKindOfClass:[NSDictionary class]]) {
                yAxisType = [seriesY valueForKey:@"type"];
                
            }
            
            NSString *format=[@"%." stringByAppendingFormat:@"%df",yaxis.decimal];
            
            float step = (float)(yaxis.max-yaxis.min)/yaxis.tickInterval;

            float baseY = [self getLocalY:yaxis.baseValue withSection:secIndex withAxis:aIndex];
            float middleValue = yaxis.baseValue + 2 * step;
            
            NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
            style.alignment = NSTextAlignmentRight;
            
            NSMutableParagraphStyle *style2 = [[NSMutableParagraphStyle alloc] init];
            style2.alignment = NSTextAlignmentLeft;
            
            CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);

            //原点处的Y轴刻度
            if ([yAxisType isEqualToString:kFenShiLine]) {
                
                //显示分时图原点处左侧价格刻度
                [[@"" stringByAppendingFormat:format,yaxis.baseValue] drawInRect:CGRectMake(0, baseY - kYFontSizeFenShi, sec.frame.origin.x + sec.paddingLeft - 1, kYFontSizeFenShi * 2) withAttributes:@{NSFontAttributeName:[UIFont fontWithName:KYFontName size:kYFontSizeFenShi],NSParagraphStyleAttributeName:style,NSForegroundColorAttributeName:kFenShiDownColor}];
                
                //显示分时图原点处右侧百分比
                NSString *percentText = [NSString stringWithFormat:@"%.2f%%",(yaxis.baseValue - middleValue)/middleValue * 100];
                [percentText drawInRect:CGRectMake(sec.frame.origin.x + sec.frame.size.width + 1, baseY - kYFontSizeFenShi, 40, kYFontSizeFenShi * 2) withAttributes:@{NSFontAttributeName:[UIFont fontWithName:KYFontName size:kYFontSizeFenShi],NSParagraphStyleAttributeName:style2,NSForegroundColorAttributeName:kFenShiDownColor}];

            }
            
            if (yaxis.tickInterval%2 == 1) {
                yaxis.tickInterval +=1;
            }
            
            for(int i=1; i<= yaxis.tickInterval;i++){
                
                //设置虚线
                CGFloat dash[] = {1,1};
                CGContextSetLineDash (context,20,dash,2);
                CGContextSetLineWidth(context, 1);
                
                if(yaxis.baseValue + i*step <= yaxis.max && yaxis.max < MAXFLOAT){
                    float iy = [self getLocalY:(yaxis.baseValue + i*step) withSection:secIndex withAxis:aIndex];
                    
                    UIColor *textColor = [UIColor blackColor];

                    //成交量显示缩写；
                    NSString *valueY = [@"" stringByAppendingFormat:format,yaxis.baseValue+i*step];
                    if ([yAxisType isEqualToString:kFenShiColumn]) {
                        valueY = [self roundFloatDisplay:yaxis.baseValue+i*step];
                        textColor = kFenShiVolumeYFontColor;
                    }else {
                        if (i == 1) {
                            textColor = kFenShiDownColor;
                        }else if(i == 2){
                            textColor = [UIColor blackColor];
                            CGContextSetLineDash (context,0,0,0);
                            CGContextSetLineWidth(context, 0.8);
                        }else if(i > 2){
                            textColor = kFenShiUpColor;
                        }
                    }
                    
                    //Y轴最大刻度，显示位置靠下
                    CGFloat offset = (i == yaxis.tickInterval) ? 0 : kYFontSizeFenShi/2 ;
                    
                    //显示分时图左侧价格刻度
                    [valueY drawInRect:CGRectMake(0, iy - offset, sec.frame.origin.x + sec.paddingLeft - 1, kYFontSizeFenShi * 2) withAttributes:@{NSFontAttributeName:[UIFont fontWithName:KYFontName size:kYFontSizeFenShi],NSParagraphStyleAttributeName:style,NSForegroundColorAttributeName:textColor}];
                    
                    //显示分时图右侧百分比
                    if ([yAxisType isEqualToString:kFenShiLine]) {
                        
                        NSString *percentText = [NSString stringWithFormat:@"%.2f%%",(yaxis.baseValue + i * step - middleValue)/middleValue * 100];

                        [percentText drawInRect:CGRectMake(sec.frame.origin.x + sec.frame.size.width + 1, iy - offset, 40, kYFontSizeFenShi * 2) withAttributes:@{NSFontAttributeName:[UIFont fontWithName:KYFontName size:kYFontSizeFenShi],NSParagraphStyleAttributeName:style2,NSForegroundColorAttributeName:textColor}];

                    }
                    
                    if(yaxis.baseValue + i*step < yaxis.max){
                        CGContextSetStrokeColorWithColor(context, kDashColor.CGColor);
                        CGContextMoveToPoint(context,sec.frame.origin.x+sec.paddingLeft,iy);
                        CGContextAddLineToPoint(context,sec.frame.origin.x+sec.frame.size.width,iy);
                    }
                    
                    CGContextStrokePath(context);
                }
            }
            for(int i=1; i <= yaxis.tickInterval;i++){
                if(yaxis.baseValue - i*step >= yaxis.min && yaxis.min < MAXFLOAT){
                    float iy = [self getLocalY:(yaxis.baseValue - i*step) withSection:secIndex withAxis:aIndex];
                    
                    CGContextSetStrokeColorWithColor(context, kDashColor.CGColor);
                    CGContextMoveToPoint(context,sec.frame.origin.x+sec.paddingLeft,iy);
                    if(!isnan(iy)){
                        CGContextAddLineToPoint(context,sec.frame.origin.x+sec.paddingLeft-2,iy);
                    }
                    CGContextStrokePath(context);
                    
                    UIColor *textColor = [UIColor blackColor];
                    
                    //成交量显示缩写；
                    NSString *valueY = [@"" stringByAppendingFormat:format,yaxis.baseValue+i*step];
                    if ([yAxisType isEqualToString:kFenShiColumn]) {
                        valueY = [self roundFloatDisplay:yaxis.baseValue+i*step];
                        textColor = kFenShiVolumeYFontColor;
                    }else {
                        if (i == 1) {
                            textColor = kFenShiDownColor;
                        }else if(i == 2){
                            textColor = [UIColor blackColor];
                        }else if(i > 2){
                            textColor = kFenShiUpColor;
                        }
                    }
                    
                    [valueY drawInRect:CGRectMake(0, iy - 7, sec.frame.origin.x + sec.paddingLeft - 1, kYFontSizeFenShi * 2) withAttributes:@{NSFontAttributeName:[UIFont fontWithName:KYFontName size:kYFontSizeFenShi],NSParagraphStyleAttributeName:style,NSForegroundColorAttributeName:textColor}];
                    
                    if(yaxis.baseValue - i*step > yaxis.min){
                        CGContextSetStrokeColorWithColor(context, kDashColor.CGColor);
                        CGContextMoveToPoint(context,sec.frame.origin.x+sec.paddingLeft,iy);
                        CGContextAddLineToPoint(context,sec.frame.origin.x+sec.frame.size.width,iy);
                    }
                    
                    CGContextStrokePath(context);
                }
            }
        }
    }
    CGContextSetLineDash (context,0,NULL,0);
}

-(void)drawXAxis{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetShouldAntialias(context, NO);
    CGContextSetLineWidth(context, 1.f);
    CGContextSetStrokeColorWithColor(context, kBorderColor.CGColor);
    
    for(int secIndex=0;secIndex<self.sections.count;secIndex++){
        Section *sec = [self.sections objectAtIndex:secIndex];
        if(sec.hidden){
            continue;
        }
        
        //上边X轴
        CGContextMoveToPoint(context,sec.frame.origin.x+sec.paddingLeft,sec.frame.origin.y+sec.paddingTop);
        CGContextAddLineToPoint(context, sec.frame.origin.x+sec.frame.size.width,sec.frame.origin.y+sec.paddingTop);
        
        //下边X轴
        CGContextMoveToPoint(context,sec.frame.origin.x+sec.paddingLeft,sec.frame.size.height+sec.frame.origin.y);
        CGContextAddLineToPoint(context, sec.frame.origin.x+sec.frame.size.width,sec.frame.size.height+sec.frame.origin.y);
        
    }
    CGContextStrokePath(context);
}

-(void) setSelectedIndexByPoint:(CGPoint) point{
    
    if([self getIndexOfSection:point] == -1){
        return;
    }
    Section *sec = [self.sections objectAtIndex:[self getIndexOfSection:point]];
    
    for(int i=self.rangeFrom;i<self.rangeTo;i++){
        if((plotWidth*(i-self.rangeFrom))<=(point.x-sec.paddingLeft-self.paddingLeft) && (point.x-sec.paddingLeft-self.paddingLeft)<plotWidth*((i-self.rangeFrom)+1)){
            //			if (self.selectedIndex != i)
            {
                self.selectedIndex=i;
                [self setNeedsDisplay];
            }
            
            return;
        }
    }
}

-(void)appendToData:(NSArray *)data forName:(NSString *)name{
    for(int i=0;i<self.series.count;i++){
        if([[[self.series objectAtIndex:i] objectForKey:@"name"] isEqualToString:name]){
            if([[self.series objectAtIndex:i] objectForKey:@"data"] == nil){
                NSMutableArray *tempData = [[NSMutableArray alloc] init];
                [[self.series objectAtIndex:i] setObject:tempData forKey:@"data"];
            }
            
            for(int j=0;j<data.count;j++){
                [[[self.series objectAtIndex:i] objectForKey:@"data"] addObject:[data objectAtIndex:j]];
            }
        }
    }
}

-(void)clearDataforName:(NSString *)name{
    for(int i=0;i<self.series.count;i++){
        if([[[self.series objectAtIndex:i] objectForKey:@"name"] isEqualToString:name]){
            if([[self.series objectAtIndex:i] objectForKey:@"data"] != nil){
                [[[self.series objectAtIndex:i] objectForKey:@"data"] removeAllObjects];
            }
        }
    }
}

-(void)clearData{
    for(int i=0;i<self.series.count;i++){
        [[[self.series objectAtIndex:i] objectForKey:@"data"] removeAllObjects];
    }
}

-(void)setData:(NSMutableArray *)data forName:(NSString *)name{
    for(int i=0;i<self.series.count;i++){
        if([[[self.series objectAtIndex:i] objectForKey:@"name"] isEqualToString:name]){
            [[self.series objectAtIndex:i] setObject:data forKey:@"data"];
        }
    }
}

-(void)appendToCategory:(NSArray *)category forName:(NSString *)name{
    for(int i=0;i<self.series.count;i++){
        if([[[self.series objectAtIndex:i] objectForKey:@"name"] isEqualToString:name]){
            if([[self.series objectAtIndex:i] objectForKey:@"category"] == nil){
                NSMutableArray *tempData = [[NSMutableArray alloc] init];
                [[self.series objectAtIndex:i] setObject:tempData forKey:@"category"];
            }
            
            for(int j=0;j<category.count;j++){
                [[[self.series objectAtIndex:i] objectForKey:@"category"] addObject:[category objectAtIndex:j]];
            }
        }
    }
}

-(void)clearCategoryforName:(NSString *)name{
    for(int i=0;i<self.series.count;i++){
        if([[[self.series objectAtIndex:i] objectForKey:@"name"] isEqual:name]){
            if([[self.series objectAtIndex:i] objectForKey:@"category"] != nil){
                [[[self.series objectAtIndex:i] objectForKey:@"category"] removeAllObjects];
            }
        }
    }
}

-(void)clearCategory{
    for(int i=0;i<self.series.count;i++){
        [[[self.series objectAtIndex:i] objectForKey:@"category"] removeAllObjects];
    }
}

-(void)setCategory:(NSMutableArray *)category forName:(NSString *)name{
    for(int i=0;i<self.series.count;i++){
        if([[[self.series objectAtIndex:i] objectForKey:@"name"] isEqualToString:name]){
            [[self.series objectAtIndex:i] setObject:category forKey:@"category"];
        }
    }
}

/*
 * Sections
 */
-(Section *)getSection:(int) index{
    return [self.sections objectAtIndex:index];
}
-(int)getIndexOfSection:(CGPoint) point{
    for(int i=0;i<self.sections.count;i++){
        Section *sec = [self.sections objectAtIndex:i];
        if (CGRectContainsPoint(sec.frame, point)){
            return i;
        }
    }
    return -1;
}

/*
 * series
 */
-(NSMutableDictionary *)getSerie:(NSString *)name{
    NSMutableDictionary *serie = nil;
    for(int i=0;i<self.series.count;i++){
        if([[[self.series objectAtIndex:i] objectForKey:@"name"] isEqualToString:name]){
            serie = [self.series objectAtIndex:i];
            break;
        }
    }
    return serie;
}

-(void)addSerie:(NSObject *)serie{
    if([serie isKindOfClass:[NSArray class]]){
        NSArray *se = (NSArray *)serie;
        int section = 0;
        for (NSDictionary *ser in se) {
            section = [[ser objectForKey:@"section"] intValue];
            [self.series addObject:ser];
        }
        [[[self.sections objectAtIndex:section] series] addObject:serie];
    }else{
        NSDictionary *se = (NSDictionary *)serie;
        int section = [[se objectForKey:@"section"] intValue];
        [self.series addObject:serie];
        [[[self.sections objectAtIndex:section] series] addObject:serie];
    }
}

/*
 *  Chart Sections
 */
-(void)addSection:(NSString *)ratio{
    Section *sec = [[Section alloc] init];
    [self.sections addObject:sec];
    [self.ratios addObject:ratio];
}

-(void)removeSection:(int)index{
    [self.sections removeObjectAtIndex:index];
    [self.ratios removeObjectAtIndex:index];
}

-(void)addSections:(int)num withRatios:(NSArray *)rats{
    for (int i=0; i< num; i++) {
        Section *sec = [[Section alloc] init];
        [self.sections addObject:sec];
        [self.ratios addObject:[rats objectAtIndex:i]];
    }
}

-(void)removeSections{
    [self.sections removeAllObjects];
    [self.ratios removeAllObjects];
}

-(void)initSections{
    float height = self.frame.size.height-(self.paddingTop+self.paddingBottom);
    float width  = self.frame.size.width-(self.paddingLeft+self.paddingRight) - 40;
    
    int total = 0;
    for (int i=0; i< self.ratios.count; i++) {
        if([[self.sections objectAtIndex:i] hidden]){
            continue;
        }
        int ratio = [[self.ratios objectAtIndex:i] intValue];
        total+=ratio;
    }
    
    Section*prevSec = nil;
    for (int i=0; i< self.sections.count; i++) {
        int ratio = [[self.ratios objectAtIndex:i] intValue];
        Section *sec = [self.sections objectAtIndex:i];
        if([sec hidden]){
            continue;
        }
        float h = height*ratio/total;
        float w = width;
        
        if(i==0){
            [sec setFrame:CGRectMake(0+self.paddingLeft, 0+self.paddingTop, w,h)];
        }else{
            if(i==([self.sections count]-1)){
                [sec setFrame:CGRectMake(0+self.paddingLeft, prevSec.frame.origin.y+prevSec.frame.size.height, w,self.paddingTop+height-(prevSec.frame.origin.y+prevSec.frame.size.height))];
            }else {
                [sec setFrame:CGRectMake(0+self.paddingLeft, prevSec.frame.origin.y+prevSec.frame.size.height, w,h)];
            }
        }
        prevSec = sec;
        
    }
    self.isSectionInitialized = YES;
}


-(YAxis *)getYAxis:(int) section withIndex:(int) index{
    Section *sec = [self.sections objectAtIndex:section];
    YAxis *yaxis = [sec.yAxises objectAtIndex:index];
    return yaxis;
}

/*
 * UIView Methods
 */
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.enableSelection = YES;
        self.isInitialized   = NO;
        self.isSectionInitialized   = NO;
        self.selectedIndex   = -1;
        self.padding         = nil;
        self.paddingTop      = 0;
        self.paddingRight    = 0;
        self.paddingBottom   = 0;
        self.paddingLeft     = 0;
        self.rangeFrom       = 0;
        self.rangeTo         = 0;
        self.range           = 241;
        self.touchFlag       = 0;
        self.touchFlagTwo    = 0;
        NSMutableArray *rats = [[NSMutableArray alloc] init];
        self.ratios          = rats;
        
        NSMutableArray *secs = [[NSMutableArray alloc] init];
        self.sections        = secs;
        
        NSMutableDictionary *mods = [[NSMutableDictionary alloc] init];
        self.models        = mods;
        
        [self setMultipleTouchEnabled:YES];
        
        //init models
        [self initModels];
    }
    return self;
}

-(void)initModels{
    //line
    ChartModel *model = [[EverLineModel alloc] init];
    [self addModel:model withName:kFenShiLine];
    
    //column
    model = [[EverColumnModel alloc] init];
    [self addModel:model withName:kFenShiColumn];
    
}

-(void)addModel:(ChartModel *)model withName:(NSString *)name{
    [self.models setObject:model forKey:name];
}

-(ChartModel *)getModel:(NSString *)name{
    return [self.models objectForKey:name];
}

- (void)drawRect:(CGRect)rect {
    [self initChart];
    [self initSections];
    [self initXAxis];
    [self initYAxis];
    [self initBtn];
    [self drawXAxis];
    [self drawYAxis];
    [self drawChart];
}

#pragma mark -
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSArray *ts = [touches allObjects];
    self.touchFlag = 0;
    self.touchFlagTwo = 0;
    if([ts count]==1){
        UITouch* touch = [ts objectAtIndex:0];
        if([touch locationInView:self].x < 40){
            self.touchFlag = [touch locationInView:self].y;
        }
    }
//    else if ([ts count]==2) {
//        
//        self.touchFlag = [[ts objectAtIndex:0] locationInView:self].x ;
//        self.touchFlagTwo = [[ts objectAtIndex:1] locationInView:self].x;
//        
//    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    NSArray *ts = [touches allObjects];
    if([ts count]==1){
        UITouch* touch = [ts objectAtIndex:0];
        self.touchY = [touch locationInView:self].y;
        
        int i = [self getIndexOfSection:[touch locationInView:self]];
        if(i!=-1){
            Section *sec = [self.sections objectAtIndex:i];
            if([touch locationInView:self].x > sec.paddingLeft)
                [self setSelectedIndexByPoint:[touch locationInView:self]];
            int interval = 5;
            if([touch locationInView:self].x < sec.paddingLeft){
                
                if(fabs([touch locationInView:self].y - self.touchFlag) >= MIN_INTERVAL){
                    if([touch locationInView:self].y - self.touchFlag > 0){
                        if(self.plotCount > (self.rangeTo-self.rangeFrom)){
                            if(self.rangeFrom - interval >= 0){
                                self.rangeFrom -= interval;
                                self.rangeTo   -= interval;
                                if(self.selectedIndex >= self.rangeTo){
                                    self.selectedIndex = self.rangeTo-1;
                                }
                            }else {
                                self.rangeFrom = 0;
                                self.rangeTo  -= self.rangeFrom;
                                if(self.selectedIndex >= self.rangeTo){
                                    self.selectedIndex = self.rangeTo-1;
                                }
                            }
                            [self setNeedsDisplay];
                        }
                    }else{
                        if(self.plotCount > (self.rangeTo-self.rangeFrom)){
                            if(self.rangeTo + interval <= self.plotCount){
                                self.rangeFrom += interval;
                                self.rangeTo += interval;
                                if(self.selectedIndex < self.rangeFrom){
                                    self.selectedIndex = self.rangeFrom;
                                }
                            }else {
                                self.rangeFrom  += self.plotCount-self.rangeTo;
                                self.rangeTo     = self.plotCount;
                                
                                if(self.selectedIndex < self.rangeFrom){
                                    self.selectedIndex = self.rangeFrom;
                                }
                            }
                            [self setNeedsDisplay];
                        }
                    }
                    self.touchFlag = [touch locationInView:self].y;
                }
            }
        }
        
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    NSArray *ts = [touches allObjects];	
    UITouch* touch = [[event allTouches] anyObject];
    
    //先判断是否点击 btn
    CGPoint touchPoint = [touch locationInView:self];
    if (CGRectContainsPoint(sec1BtnRect, touchPoint)) {
        NSLog(@" k btn touch !");
        
        return;
    }
    if (CGRectContainsPoint(sec2BtnRect, touchPoint)) {
        NSLog(@" 成交量 btn touch !");
        
        return;
    }
    
    if([ts count]==1){
        
        self.touchY = [touch locationInView:self].y;
        
        int i = [self getIndexOfSection:[touch locationInView:self]];
        if(i!=-1){
            Section *sec = [self.sections objectAtIndex:i];
            if([touch locationInView:self].x > sec.paddingLeft){
                if(sec.paging){
                    [sec nextPage];
                    [self setNeedsDisplay];
                }else{
                    [self setSelectedIndexByPoint:[touch locationInView:self]];
                }
            }
        }
    }
    self.touchFlag = 0;
}

/**
 *  格式化float，显示单位，保留1位小数
 *
 *  @return 格式化后的字符串
 */
- (NSString *)roundFloatDisplay:(CGFloat)value{
    
    NSString *unit = @"";
    if (value > 100000) {
        value /= 10000.0;
        unit = @"万";
    }
    if (value > 100000) {
        value /= 10000.0;
        unit = @"亿";
    }
    if (value > 100000) {
        value /= 10000.0;
        unit = @"万亿";
    }
    
    if ([unit isEqualToString:@""]) {
        return [NSString stringWithFormat:@"%d",(int)value];
    }
    return [NSString stringWithFormat:@"%.1f%@",value,unit];
}

@end
