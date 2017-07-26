//
//  NNDateFormatUtils.m
//  WeiyunHD
//
//  Created by Rico 13-2-1.
//  Copyright (c) 2013年 Rcio Wang. All rights reserved.
//

#import "NNDateFormatUtils.h"

@implementation NNDateFormatUtils


+ (NSDateFormatter*)getDateFormatter:(NSString *)formatter
{
    static NSMutableDictionary * formatterCache = nil;
    
    @synchronized(self){
        if (nil == formatterCache) {
            formatterCache = [[NSMutableDictionary alloc] init];
        }
        
        NSDateFormatter* result = [formatterCache objectForKey: formatter];
        if (nil == result) {
            NSLog(@"getAndCreateDateFormatter result=%@ new object", result);
            result = [[NSDateFormatter alloc] init];
            //设置固定时区，不随设备改变时区而改变。非国际化处理。
            NSTimeZone *hkTimeZone = [NSTimeZone timeZoneWithName:@"Asia/Hong_Kong"];
            [result setTimeZone:hkTimeZone];
            [result setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
            [result setDateFormat:formatter];
            [formatterCache setObject: result forKey: formatter];
            if (nil == result) {
                NSAssert(false, @"NNDateUtils getAndCreateDateFormatter invalid date format");
                NSLog(@"NNDateUtils getAndCreateDateFormatter invalid date format");
            }
        }
        
        return result;
    }
}



+ (NSString *)getDateString:(NSDate *)date dateFormatter:(NSString *)formatter
{
    if (nil == date || nil == formatter) {
        return nil;
    }
    
    NSDateFormatter* formatObj = [self getDateFormatter:formatter];
    @synchronized(formatObj) {
        if (formatObj != nil) {
            return [formatObj stringFromDate: date];
        }
    }
    
    return nil;
}


+ (NSString *)getDateStringFromTimestamp:(NSTimeInterval)timestamp dateFormatter:(NSString *)formatter
{
    if (nil == formatter) {
        return nil;
    }
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    return [self getDateString:date dateFormatter:formatter];
}


+ (NSDate *)getDateFromString:(NSString *)dateStr dateFormatter:(NSString *)formatter
{
    NSDateFormatter *formatterObj = [NNDateFormatUtils getDateFormatter:formatter];
    NSDate *resDate = nil;
    @synchronized(formatterObj) {
        resDate = [formatterObj dateFromString:dateStr];
    }
    
    return resDate;
}


+ (NSString *)formatedDateDescription:(NSDate *)date
{
    
    NSString * desc = nil;
        
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:[NSDate date]];
    NSDate *today = [cal dateFromComponents:components];
//    int thisYear = [components year];

    NSDate *yesterDay = [NSDate dateWithTimeInterval:-86400/*(24 * 60 * 60)*/ sinceDate:today];
    
    components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:date];
    NSDate *otherDate = [cal dateFromComponents:components];
//    int otherYear = [components year];
    
    NSDateFormatter * timeFormatter = [NNDateFormatUtils getDateFormatter:@"HH:mm"];
    NSString *timeStr = nil;
    @synchronized(timeFormatter){
        timeStr = [timeFormatter stringFromDate:date];   
    }
    
    
    if([today isEqualToDate:otherDate]) {
        desc = [NSString stringWithFormat:@"今天 %@", timeStr];
    } else if ([yesterDay isEqualToDate:otherDate]) {
        desc = [NSString stringWithFormat:@"昨天 %@", timeStr];
    } else {
        desc = [NNDateFormatUtils getDateString:date dateFormatter:@"yyyy-MM-dd HH:mm"];
    }

    
    return desc;
}



+ (NSString *)formatedDateStrDescription:(NSString *)dateStr
{
    if (dateStr.length < 16) {
        return dateStr;
    }
    
    NSString * desc = nil;
    
    NSString * yearStr = [dateStr substringToIndex:4];
    NSString * dayStr = [dateStr substringToIndex:10];
    NSString * timeStr = [dateStr substringWithRange:NSMakeRange(11, 5)];
    
    NSString *todayStr = [NNDateFormatUtils getDateString:[NSDate date] dateFormatter:@"yyyy-MM-dd"];
    NSString *yesterdayStr = [NNDateFormatUtils getDateString:[NSDate dateWithTimeInterval:-86400/*(24 * 60 * 60)*/ sinceDate:[NSDate date]] dateFormatter:@"yyyy-MM-dd"];
    NSString * thisYearStr = [todayStr substringToIndex:4];
    
    if ([thisYearStr isEqualToString:yearStr]) {
        if ([todayStr isEqualToString:dayStr]) {
            desc = [NSString stringWithFormat:@"今天 %@", timeStr];
        } else if ([yesterdayStr isEqualToString:dayStr]) {
            desc = [NSString stringWithFormat:@"昨天 %@", timeStr];
        } else {
            desc = [dateStr substringWithRange:NSMakeRange(6, 10)];
        }

    } else {
        desc = [dateStr substringToIndex:16];
    }
    

    return desc;
}

+ (NSCalendar *)sharedCalendar {
    static NSCalendar *calendar = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        [calendar setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
        [calendar setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Hong_Kong"]];
    });
    return calendar;
}


+ (NSArray *)getWeekdayDescending:(NSDate *)date byFormat:(NSString *)format {

    NSCalendar *calendar = [self sharedCalendar];

    NSDateComponents *comps = [calendar components:(NSYearCalendarUnit
                                                    | NSMonthCalendarUnit
                                                    | NSDayCalendarUnit
                                                    | NSHourCalendarUnit
                                                    | NSMinuteCalendarUnit
                                                    | NSSecondCalendarUnit
                                                    | NSWeekdayCalendarUnit)
                                          fromDate:date];

    NSMutableArray *weekdays = [[NSMutableArray alloc] initWithCapacity:7];
    NSInteger weekday = comps.weekday;

    for (;;) {
        NSString *dayString = [self getDateString:[calendar dateFromComponents:comps]
                                    dateFormatter:format];
        [weekdays addObject:dayString];

        if (weekday == 1) {
            weekday = 8;
        }
        weekday --;
        comps.day = comps.day - 1;

        if (weekday < 2) {
            break;
        }
    }

    return weekdays;
}

+ (NSString *)getYesterdayString:(NSDate *)date byFormat:(NSString *)format {

    NSCalendar *calendar = [self sharedCalendar];

    NSDateComponents *comps = [calendar components:(NSYearCalendarUnit
                                                    | NSMonthCalendarUnit
                                                    | NSDayCalendarUnit
                                                    | NSHourCalendarUnit
                                                    | NSMinuteCalendarUnit
                                                    | NSSecondCalendarUnit
                                                    | NSWeekdayCalendarUnit)
                                          fromDate:date];
    comps.day = comps.day - 1;

    return [self getDateString:[calendar dateFromComponents:comps]
                 dateFormatter:format];
}

+ (NSString *)getTodayStringByFormat:(NSString *)format {
    return [self getDateString:[NSDate date] dateFormatter:format];
}

+ (NSString *)getWeekMondayString:(NSDate *)date byFormat:(NSString *)format {
    NSCalendar *calendar = [self sharedCalendar];

    NSDateComponents *comps = [calendar components:(NSYearCalendarUnit
                                                    | NSMonthCalendarUnit
                                                    | NSDayCalendarUnit
                                                    | NSHourCalendarUnit
                                                    | NSMinuteCalendarUnit
                                                    | NSSecondCalendarUnit
                                                    | NSWeekdayCalendarUnit)
                                          fromDate:date];
    NSInteger weekday = comps.weekday;
    if (weekday == 1) {
        weekday = 8;
    }

    NSInteger dayInterval = weekday - 2;
    comps.day = comps.day - dayInterval;

    return [self getDateString:[calendar dateFromComponents:comps]
                 dateFormatter:format];
}

+ (NSString *)dateStringAccurateToSeconds:(NSDate *)date
{
    if (nil == date) {
        return nil;
    }
    return [NNDateFormatUtils getDateString:date
                                             dateFormatter:@"yyyy年MM月dd HH:mm:ss"];
}


+ (NSInteger)minuteCountFrom:(NSDate *)date
{
    NSTimeInterval timeInterval = [date timeIntervalSinceNow];
    NSInteger minuteCount = (NSInteger)timeInterval / (60);
    return minuteCount;
}

+ (NSInteger)hourCountFrom:(NSDate *)date
{
    NSTimeInterval timeInterval = [date timeIntervalSinceNow];
    NSInteger hourCount = (NSInteger)timeInterval / (60 * 60);
    return hourCount;
}


+ (NSInteger)dayCountFrom:(NSDate *)date
{
    NSTimeInterval timeInterval = [date timeIntervalSinceNow];
    NSInteger dayCount = (NSInteger)timeInterval / (24 * 60 * 60);
    return dayCount;
}


/**
 * @brief 获取时间（只获取年月日，时分秒都为0）
 */
+ (NSDate *)todayDate:(NSDate *)now {
    NSCalendar *calendar = [self sharedCalendar];

    NSDateComponents *comps =
    [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit
                fromDate:now];

    comps.hour = 0;
    comps.minute = 0;
    comps.second = 0;

    return [calendar dateFromComponents:comps];
}

/**
 * @brief 获取昨天的时间（只获取年月日，时分秒都为0）
 */
+ (NSDate *)yesterdayDate:(NSDate *)now {
    NSCalendar *calendar = [NSCalendar currentCalendar];

    NSDateComponents *comps =
    [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit
                fromDate:now];

    comps.day--;
    comps.hour = 0;
    comps.minute = 0;
    comps.second = 0;

    return [calendar dateFromComponents:comps];
}

/**
 * @brief 获取最近七天的时间（只获取年月日，时分秒都为0）
 */
+ (NSDate *)thisWeekDate:(NSDate *)now {
    NSCalendar *calendar = [NSCalendar currentCalendar];

    NSDateComponents *comps =
    [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit
                fromDate:now];

    comps.day -= 7;
    comps.hour = 0;
    comps.minute = 0;
    comps.second = 0;

    return [calendar dateFromComponents:comps];
}

@end
