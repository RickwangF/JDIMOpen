//
//  RNLiveStringTool.m
//  RNLive
//
//  Created by Rick on 2019/8/13.
//  Copyright © 2019 Rick. All rights reserved.
//

#import "LiveModuleStringTool.h"
#import <ZSBaseUtil/ZSBaseUtil-Swift.h>


@implementation LiveModuleStringTool

+ (NSString *)getDateStringFromTimeIntervalSince1970:(NSTimeInterval)interval WithFormat:(NSString *)format{
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:format];
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"]; // 设置时区,这个对于时间的处理有时很重要
    [formatter setTimeZone:timeZone];
    
    NSString *dateString = [formatter stringFromDate:date];
    
    return dateString;
    
}
    
+ (NSDateComponents *)getComponentsMinuteToYearFromDate:(NSDate *)date{
    NSCalendarUnit components = (NSCalendarUnit)
    (NSCalendarUnitYear    |
     NSCalendarUnitMonth   |
     NSCalendarUnitWeekday |
     NSCalendarUnitDay     |
     NSCalendarUnitHour    |
     NSCalendarUnitMinute);
    return [[NSCalendar currentCalendar] components:components fromDate:date];
}
    
+(NSString*)weekdayStr:(NSInteger)dayOfWeek{
    static NSDictionary *daysOfWeekDict = nil;
    daysOfWeekDict = @{@(1):@"星期日",
                       @(2):@"星期一",
                       @(3):@"星期二",
                       @(4):@"星期三",
                       @(5):@"星期四",
                       @(6):@"星期五",
                       @(7):@"星期六",};
    return [daysOfWeekDict objectForKey:@(dayOfWeek)];
}

+ (NSString *)getPeriodOfTime:(NSInteger)time withMinute:(NSInteger)minute{
    NSInteger totalMin = time *60 + minute;
    NSString *showPeriodOfTime = @"";
    
    if (totalMin >= 0 && totalMin < 12 * 60) {
        showPeriodOfTime = @"am";
    }else if(totalMin >= 12 * 60 && totalMin <= (23 * 60 + 59)){
        showPeriodOfTime = @"pm";
    }
#if 0
    if (totalMin > 0 && totalMin <= 5 * 60)
    {
        showPeriodOfTime = @"凌晨";
    }
    else if (totalMin > 5 * 60 && totalMin < 12 * 60)
    {
        showPeriodOfTime = @"上午";
    }
    else if (totalMin >= 12 * 60 && totalMin <= 18 * 60)
    {
        showPeriodOfTime = @"下午";
    }
    else if ((totalMin > 18 * 60 && totalMin <= (23 * 60 + 59)) || totalMin == 0)
    {
        showPeriodOfTime = @"晚上";
    }
#endif
    return showPeriodOfTime;
}
    
+ (NSString *)getTimeFrame:(NSTimeInterval)timeInterval
                    showOclock:(BOOL)showOclock
               hideTodayOclock:(BOOL)hideTodayOclock
                    timingMode:(TimingMode)timingMode{
        
    if (timeInterval == 0) {
        return nil;
    }
    
    //今天的时间
    NSDate *nowDate = [NSDate date];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSDateComponents *nowComponents = [self getComponentsMinuteToYearFromDate:nowDate];
    NSDateComponents *dateComponents = [self getComponentsMinuteToYearFromDate:date];
    
    NSInteger hour = dateComponents.hour;
    
    if (hour >= timingMode){
        hour = hour - timingMode;
    }
    
    NSString *clock = [NSString stringWithFormat:@"%@:%02d", @(hour), (int)dateComponents.minute];
    
    if (showOclock) {
        clock = (timingMode == TimingMode_12 ? [NSString stringWithFormat:@"%@%@", clock, [self getPeriodOfTime:hour withMinute:dateComponents.minute]] : clock);
    }
    
    double OnedayTimeIntervalValue = 24*60*60;  // 一天的秒数n  n
    if ([nowDate timeIntervalSinceDate:date] >= 7 * OnedayTimeIntervalValue) { // 显示日期
        return [NSString stringWithFormat:@"%@/%@/%@",
                @(dateComponents.year),
                @(dateComponents.month),
                @(dateComponents.day)];
    }
    
    if (nowComponents.day == dateComponents.day) { // 同一天,显示时间
        return (!hideTodayOclock && showOclock) ? clock : @"今天";
    }
    
    NSString *day = @"";
    
    if(nowComponents.day == (dateComponents.day + 1)) { // 昨天
        day = @"昨天";
    }else if(nowComponents.day == (dateComponents.day+2)) { // 前天
        day = @"前天";
    }else{ // 一周内
        day = [self weekdayStr:dateComponents.weekday];
    }
    
    return showOclock ? [NSString stringWithFormat:@"%@ %@", day, clock] : day;
}
    
+ (NSString *)getTimeTimestampAddTime:(NSTimeInterval)addTime type:(NSNumber *)number format:(NSString *)format{
    //[self getNSDateFormatter:format];
    NSDate *datenow = [NSDate date];
    NSDate *datefuture = [datenow initWithTimeIntervalSinceNow:addTime];
    if ([[number stringValue] zs_isFloat]) {
        return [NSString stringWithFormat:@"%0.f", [datefuture timeIntervalSince1970]];
    }
    if ([[number stringValue] zs_isInt]) {
        return [NSString stringWithFormat:@"%ld", (long)[datefuture timeIntervalSince1970]];
    }
    return nil;
}
    
+ (NSString *)getNowTimeTimestampMillisecondInt{
    return [self getTimeTimestampAddTime:0 type:@(1) format:@"YYYY-MM-dd HH:mm:ss SSS"];
}
    
+ (NSString *)getJSONString:(id)param{
    if ([param isKindOfClass:[NSArray class]] || [param isKindOfClass:[NSDictionary class]]) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:param options:kNilOptions error:nil];
        return jsonData == nil ? @"" : [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }else if([param isKindOfClass:[NSString class]]){
        return param;
    }
    return nil;
}

@end
