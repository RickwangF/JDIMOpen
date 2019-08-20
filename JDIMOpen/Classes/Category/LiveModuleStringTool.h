//
//  RNLiveStringTool.h
//  RNLive
//
//  Created by Rick on 2019/8/13.
//  Copyright © 2019 Rick. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TimingMode) {
    TimingMode_12 = 12,
    TimingMode_24 = 24
};

@interface LiveModuleStringTool : NSObject

+ (NSString *)getDateStringFromTimeIntervalSince1970:(NSTimeInterval)interval WithFormat:(NSString*)format;
    
+ (NSString *)getTimeFrame:(NSTimeInterval)timeInterval
                showOclock:(BOOL)showOclock
           hideTodayOclock:(BOOL)hideTodayOclock
                timingMode:(TimingMode)timingMode;
    
+ (NSString *)getTimeTimestampAddTime:(NSTimeInterval)addTime type:(NSNumber *)number format:(NSString *)format;
    
+ (NSString *)getNowTimeTimestampMillisecondInt;
    
+ (NSString *)getJSONString:(id)param;
    
@end

NS_ASSUME_NONNULL_END
