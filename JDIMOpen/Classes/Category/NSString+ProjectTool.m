//
//  NSString+ProjectTool.m
//  RNLive
//
//  Created by Rick on 2019/8/13.
//  Copyright © 2019 Rick. All rights reserved.
//

#import "NSString+ProjectTool.h"

@implementation NSString (ProjectTool)

- (BOOL)stringIsValidURL{
    NSString *regex =@"http[s]{0,1}://[^\\s]*";
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [urlTest evaluateWithObject:self];
}

- (NSString *)getOSSImageURL{
    
    if (![self isKindOfClass:NSString.class]) {
        return nil;
    }
    
    if (self == nil || [self isEqualToString:@""]) {
        return nil;
    }
    
    if ([self stringIsValidURL]) {
        return self;
    }
    
    NSString *ossImagePath = [NSString stringWithFormat:@"%@/%@", @"https://res.jaadee.net", self];
    
    return ossImagePath;
}
    
- (NSURL *)URLWithString{
    return  [NSURL URLWithString:self];
}

@end
