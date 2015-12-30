//
//  YAxis.h
//  https://github.com/zhiyu/chartee/
//
//  Created by zhiyu on 7/11/11.
//  Copyright 2011 zhiyu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface YAxis : NSObject {
	bool isUsed;
	CGRect frame;
	float max;
	float min;
	float ext;
	float baseValue;
	bool  baseValueSticky;
	bool  symmetrical;
	float paddingTop;
	int tickInterval;
	int pos;
	int decimal;
}

@property(nonatomic) bool isUsed;

@property(nonatomic) CGRect frame;
@property(nonatomic) float max;
@property(nonatomic) float min;
@property(nonatomic) float ext;
@property(nonatomic) float baseValue;
/**
 *  Y轴是否对称显示（即0刻度在Y轴中间）
 */
@property(nonatomic) bool  symmetrical;
@property(nonatomic) bool  baseValueSticky;
@property(nonatomic) float paddingTop;
/**
 *  虚线间隔（= 虚线数量 + 1）
 */
@property(nonatomic) int tickInterval;
@property(nonatomic) int pos;
@property(nonatomic) int decimal; //保留几位小数

-(void)reset;

@end
