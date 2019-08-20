//
//  NSString+ProjectTool.h
//  RNLive
//
//  Created by Rick on 2019/8/13.
//  Copyright © 2019 Rick. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (ProjectTool)
    
@property (nonatomic, strong, readonly) NSURL* URLWithString;

- (NSString*)getOSSImageURL;

@end

NS_ASSUME_NONNULL_END
