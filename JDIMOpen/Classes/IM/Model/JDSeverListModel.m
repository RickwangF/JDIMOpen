//
//  JDSeverListModel.m
//  JadeKing
//
//  Created by 张森 on 2018/11/20.
//  Copyright © 2018年 张森. All rights reserved.
//

#import "JDSeverListModel.h"
#import "NSString+ProjectTool.h"
#import <MJExtension/MJExtension.h>

@implementation JDSeverModel

- (void)setAvatar:(NSString *)avatar{
    _avatar = [avatar getOSSImageURL];
    //[JDOSSTool getOSSImageUrl:avatar];
}

@end


@implementation JDSeverListModel

- (void)setCustomerServices:(NSArray *)customerServices{
    _customerServices = [JDSeverModel mj_objectArrayWithKeyValuesArray:customerServices];
}

//- (void)setPlatID:(NSNumber *)platID{
//    _platID = platID;
//    
//    switch ([platID integerValue]) {
//        case 1:{
//            _platCode = @"fcwc";
//            break;
//        }
//        case 2:{
//            _platCode = @"zbly";
//            break;
//        }
//        case 3:{
//            _platCode = @"nhzm";
//            break;
//        }
//        case 4:{
//            _platCode = @"ydj";
//            break;
//        }
//        case 5:{
//            _platCode = @"dfgd";
//            break;
//        }
//        default:
//            break;
//    }
//}

@end
