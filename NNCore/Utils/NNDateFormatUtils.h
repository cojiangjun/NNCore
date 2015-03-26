//
//  NNDateFormatUtils.h
//  WeiyunHD
//
//  Created by Rico 13-2-1.
//  Copyright (c) 2013年 Rcio Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NNDateFormatUtils : NSObject


+ (NSString *)getDateString:(NSDate *)date dateFormatter:(NSString *)formatter;
+ (NSString *)getDateStringFromTimestamp:(NSTimeInterval)timestamp dateFormatter:(NSString *)formatter;

+ (NSDate *)getDateFromString:(NSString *)dateStr dateFormatter:(NSString *)formatter;

+ (NSString *)formatedDateDescription:(NSDate *)date;
+ (NSString *)formatedDateStrDescription:(NSString *)dateStr;

+ (NSArray *)getWeekdayDescending:(NSDate *)date byFormat:(NSString *)format;
+ (NSString *)getYesterdayString:(NSDate *)date byFormat:(NSString *)format;
+ (NSString *)getWeekMondayString:(NSDate *)date byFormat:(NSString *)format;

+ (NSString *)dateStringAccurateToSeconds:(NSDate *)date;


/*
 * 返回从现在到date之间，相距n分钟
 *  @param date
 *  @return
 */
+ (NSInteger)minuteCountFrom:(NSDate *)date;

/*
 * 返回从现在到date之间，相距n小时
 *  @param date 
 *  @return 
 */
+ (NSInteger)hourCountFrom:(NSDate *)date;

/*
 * 返回从现在到date之间，相距n小时
 *  @param date
 *  @return
 */
+ (NSInteger)dayCountFrom:(NSDate *)date;


/**
 * @brief 获取时间（只获取年月日，时分秒都为0）
 */
+ (NSDate *)todayDate:(NSDate *)now;

/**
 * @brief 获取昨天的时间（只获取年月日，时分秒都为0）
 */
+ (NSDate *)yesterdayDate:(NSDate *)now;

/**
 * @brief 获取最近七天的时间（只获取年月日，时分秒都为0）
 */
+ (NSDate *)thisWeekDate:(NSDate *)now;

@end
