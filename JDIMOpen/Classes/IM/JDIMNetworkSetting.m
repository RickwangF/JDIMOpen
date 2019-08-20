//
//  JDIMNetworkSetting.m
//  RNLive
//
//  Created by Rick on 2019/8/17.
//  Copyright © 2019 Rick. All rights reserved.
//


#import "JDIMNetworkSetting.h"
#import <UIKit/UIKit.h>
#import "ZSBaseUtil-Swift.h"
#import "JDNetService-Swift.h"
#import "JDIMTool.h"
#import <AdSupport/AdSupport.h>

@implementation JDIMNetworkSetting

+ (NSDictionary *)HttpHeaders{
    
    NSString *userToken = [JDIMTool userToken] == nil ? @"": [JDIMTool userToken];
    NSString *version = NSBundle.mainBundle.infoDictionary[@"CFBundleShortVersionString"];
    NSString *uuid = UIDevice.currentDevice.identifierForVendor.UUIDString;
    NSString *idfa = ASIdentifierManager.sharedManager.advertisingIdentifier.UUIDString;
    NSString *systemOS = UIDevice.currentDevice.systemVersion;
    NSString *deviceType = @"iOS";
    NSString *device = NSString.deviceVersion;
    NSString *network = NetWorkStatus.currentNetwork;
    NSString *position = @"";
    
    return @{
             @"userToken": userToken,
             @"version": version,
             @"uuid": uuid,
             @"idfa": idfa,
             @"systemOS": systemOS,
             @"deviceType": deviceType,
             @"device": device,
             @"network": network,
             @"position": position
             };
}

@end
