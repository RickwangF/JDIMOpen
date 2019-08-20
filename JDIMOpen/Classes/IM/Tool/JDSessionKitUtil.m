//
//  JDSessionKitUtil.m
//  JadeKing
//
//  Created by 张森 on 2018/9/8.
//  Copyright © 2018年 张森. All rights reserved.
//

#import "JDSessionKitUtil.h"
#import <ZSBaseUtil/ZSBaseUtil-Swift.h>
#import "UIImage+ProjectTool.h"
#import "FrameLayoutTool.h"
#import "JDIMTool.h"

@implementation JDSessionKitUtil

+ (NSAttributedString *)replaceEmoji:(NSString *)msg{
    
    if ([NSObject zs_isEmpty:msg]) {
        return nil;
    }

    NSError *error;
    NSRegularExpression *predcate = [NSRegularExpression regularExpressionWithPattern:@"\\[[^\\[\\]]+?\\]" options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *matches = [predcate matchesInString:msg options:NSMatchingReportProgress range:NSMakeRange(0, msg.length)];
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:msg];
    
    if (matches.count > 0) {
        for (NSTextCheckingResult *result in matches) {
            NSString *emojiEncode = [msg substringWithRange:result.range];
            NSString *imgFile = [JDIMTool getEmojiFileFromTag:emojiEncode];
            if (imgFile) {
                NSAttributedString *emojiString = [NSAttributedString imageAttribute:[UIImage img_setImageName:imgFile] textFont:[FrameLayoutTool UnitFont:15] imageFont:nil];
                //[NSAttributedString addAttributeImage:[UIImage img_setImageName:imgFile] font:KFONT(15)];
                NSRange emojiEncodeRange = [attributeString.string rangeOfString:emojiEncode];
                [attributeString replaceCharactersInRange:emojiEncodeRange withAttributedString:emojiString];
            }
        }
    }
    
    return [attributeString copy];
}

+ (BOOL)canMessageBeRevoked:(NIMMessage *)message{
    BOOL isFromMe = [message.from isEqualToString:[[NIMSDK sharedSDK].loginManager currentAccount]];
    BOOL isToMe   = [message.session.sessionId isEqualToString:[[NIMSDK sharedSDK].loginManager currentAccount]];
    BOOL isDeliverFailed = !message.isReceivedMsg && message.deliveryState == NIMMessageDeliveryStateFailed;
    BOOL isDelivering = message.deliveryState == NIMMessageDeliveryStateDelivering;
    
    if (!isFromMe || isToMe || isDeliverFailed || isDelivering) {
        return NO;
    }
    id<NIMMessageObject> messageobject = message.messageObject;
    if ([messageobject isKindOfClass:[NIMTipObject class]]
        || [messageobject isKindOfClass:[NIMNotificationObject class]]) {
        return NO;
    }
    if ([messageobject isKindOfClass:[NIMCustomObject class]]) {
        return NO;
    }
    return YES;
}

+ (NSString *)messageContent:(NIMMessage*)lastMessage{
    NSString *text = @"";
    switch (lastMessage.messageType) {
        case NIMMessageTypeText:
            text = lastMessage.text;
            break;
        case NIMMessageTypeAudio:
            text = @"[语音]";
            break;
        case NIMMessageTypeImage:
            text = @"[图片]";
            break;
        case NIMMessageTypeVideo:
            text = @"[视频]";
            break;
        case NIMMessageTypeLocation:
            text = @"[位置]";
            break;
        case NIMMessageTypeNotification:{
            return [self notificationMessageContent:lastMessage];
        }
        case NIMMessageTypeFile:
            text = @"[文件]";
            break;
        case NIMMessageTypeTip:
            text = lastMessage.text;
            break;
        case NIMMessageTypeRobot:
            text = [self robotMessageContent:lastMessage];
            break;
        default:
            text = @"[未知消息]";
    }
    if (lastMessage.session.sessionType == NIMSessionTypeP2P ||
        lastMessage.messageType == NIMMessageTypeTip){
        return text;
    }else{
        NSString *from = lastMessage.from;
        if (lastMessage.messageType == NIMMessageTypeRobot){
            NIMRobotObject *object = (NIMRobotObject *)lastMessage.messageObject;
            if (object.isFromRobot){
                from = object.robotId;
            }
        }
        return text;
    }
}

+ (NSString *)notificationMessageContent:(NIMMessage *)lastMessage{
    NIMNotificationObject *object = (NIMNotificationObject *)lastMessage.messageObject;
    if (object.notificationType == NIMNotificationTypeNetCall) {
        NIMNetCallNotificationContent *content = (NIMNetCallNotificationContent *)object.content;
        if (content.callType == NIMNetCallTypeAudio) {
            return @"[网络通话]";
        }
        return @"[视频聊天]";
    }
    if (object.notificationType == NIMNotificationTypeTeam) {
        NIMTeam *team = [[NIMSDK sharedSDK].teamManager teamById:lastMessage.session.sessionId];
        if (team.type == NIMTeamTypeNormal) {
            return @"[讨论组信息更新]";
        }else{
            return @"[群信息更新]";
        }
    }
    return @"[未知消息]";
}

+ (NSString *)robotMessageContent:(NIMMessage *)lastMessage{
    NIMRobotObject *object = (NIMRobotObject *)lastMessage.messageObject;
    if (object.isFromRobot){
        return @"[机器人消息]";
    }else{
        return lastMessage.text;
    }
}

+ (BOOL)isAdminSessionId:(NSString *)sessionId{
    return sessionId.length < 20 && sessionId.length > 0;
}

@end
