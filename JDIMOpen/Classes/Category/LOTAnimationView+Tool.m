//
//  LOTAnimationView+Tool.m
//  RNLive
//
//  Created by Rick on 2019/8/13.
//  Copyright © 2019 Rick. All rights reserved.
//

#import "LOTAnimationView+Tool.h"

@implementation LOTAnimationView (Tool)

+ (NSString *)animationFilePathFromFlieName:(NSString *)fileName{
    
    return [NSString stringWithFormat:@"%@/%@/%@.json", [[NSBundle mainBundle] pathForResource:@"animations" ofType:@"bundle"], fileName, fileName];
            
}

@end
