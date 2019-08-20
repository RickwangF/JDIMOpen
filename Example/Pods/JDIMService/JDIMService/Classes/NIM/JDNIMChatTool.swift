//
//  JDNIMP2PTool.swift
//  JadeKing
//
//  Created by 张森 on 2019/8/9.
//  Copyright © 2019 张森. All rights reserved.
//

import Foundation
import NIMSDK

@objc public protocol JDNIMChatDelegate {
    
    @objc optional func nim_onRecv(messages: Array<NIMMessage>)
    @objc optional func nim_onRecvChat(message: NIMMessage)
    @objc optional func nim_onRecvSystem(message: NIMMessage)
    @objc optional func nim_onRecvChatroom(message: NIMMessage)
    @objc optional func nim_onRecvRevoke(notification: NIMRevokeMessageNotification)
    
    @objc optional func nim_onRecvMessage(receipts: Array<NIMMessageReceipt>)
    @objc optional func nim_onRecvChatMessage(receipt: NIMMessageReceipt)
    @objc optional func nim_onRecvChatroomMessage(receipt: NIMMessageReceipt)
    
    @objc optional func nim_willSend(message: NIMMessage)
    @objc optional func nim_sendChat(message: NIMMessage, progress: Float)
    @objc optional func nim_sendChatroom(message: NIMMessage, progress: Float)
    @objc optional func nim_sendChatComplete(message: NIMMessage, error: Error?)
    @objc optional func nim_sendChatroomComplete(message: NIMMessage, error: Error?)
    
    @objc optional func nim_chatUploadAttachmentSuccess(_ urlString: String, message: NIMMessage)
    @objc optional func nim_ChatroomUploadAttachmentSuccess(_ urlString: String, message: NIMMessage)
    @objc optional func nim_chatFetchMessageAttachment(_ message: NIMMessage, progress: Float)
    @objc optional func nim_ChatroomFetchMessageAttachment(_ message: NIMMessage, progress: Float)
    @objc optional func nim_chatFetchMessageAttachment(_ message: NIMMessage, didCompleteWithError error: Error?)
    @objc optional func nim_ChatroomFetchMessageAttachment(_ message: NIMMessage, didCompleteWithError error: Error?)
}


// MARK: - JDNIMChat
@objcMembers public class JDNIMChatManager: NSObject, NIMChatManagerDelegate {
    
    override init() {
        super.init()
        NIMSDK.shared().chatManager.add(self)
    }
    
    private var chatDelegates: NSHashTable<JDNIMChatDelegate> = NSHashTable(options: .weakMemory)
    
    // TODO: 协议处理
    public func add(delegate: Any) {
        
        let `protocol`: JDNIMChatDelegate? = delegate as? JDNIMChatDelegate
        
        assert(`protocol` != nil, "\(delegate)必须遵循JDNIMChatDelegate协议")
        
        let isContains = chatDelegates.contains(`protocol`!)
        
        assert(!isContains, "请先将\(delegate)remove委托后再add，不可重复添加委托")
        
        chatDelegates.add(`protocol`!)
    }
    
    public func remove(delegate: Any) {
        
        guard let `protocol`: JDNIMChatDelegate = delegate as? JDNIMChatDelegate else { return }
        
        let isContains = chatDelegates.contains(`protocol`)
        
        guard isContains else { return }
        
        chatDelegates.remove(`protocol`)
    }
    
    private func removeAllDelegate() {
        
        chatDelegates.removeAllObjects()
    }
    
    // TODO: 获取历史记录
    public class func fetchMessageHistory(startTime: TimeInterval, session: NIMSession, result: @escaping NIMFetchMessageHistoryBlock) {
        
        let option = NIMHistoryMessageSearchOption()
        option.limit = 20
        option.startTime = startTime
        option.order = .desc
        NIMSDK.shared().conversationManager.fetchMessageHistory(session, option: option, result: result)
    }
    
    // TODO: NIMChatManagerDelegate
    /// 即将发送消息回调
    /// 因为发消息之前可能会有个准备过程,所以需要在收到这个回调时才将消息加入到 Datasource 中
    /// - Parameter message: 当前发送的消息
    public func willSend(_ message: NIMMessage) {
        for delegate in chatDelegates.allObjects {
            delegate.nim_willSend?(message: message)
        }
    }
    
    /// 发送消息进度回调
    ///
    /// - Parameters:
    ///   - message: 当前发送的消息
    ///   - progress: 进度
    public func send(_ message: NIMMessage, progress: Float) {
        
        for delegate in chatDelegates.allObjects {
            
            guard message.session?.sessionType == .chatroom else {
                delegate.nim_sendChat?(message: message, progress: progress)
                continue
            }
            
            delegate.nim_sendChatroom?(message: message, progress: progress)
        }
    }
    
    /// 发送消息完成回调
    ///
    /// - Parameters:
    ///   - message: 当前发送的消息
    ///   - error: 失败原因,如果发送成功则error为nil
    public func send(_ message: NIMMessage, didCompleteWithError error: Error?) {
        
        for delegate in chatDelegates.allObjects {
            
            guard message.session?.sessionType == .chatroom else {
                delegate.nim_sendChatComplete?(message: message, error: error)
                continue
            }
            
            delegate.nim_sendChatroomComplete?(message: message, error: error)
        }
    }
    
    /// 收到消息回调
    ///
    /// - Parameter messages: 消息列表,内部为NIMMessage
    public func onRecvMessages(_ messages: [NIMMessage]) {
        
        for delegate in chatDelegates.allObjects {
            
            delegate.nim_onRecv?(messages: messages)
            
            for message in messages {
                
                if message.from == "jaadee_live_helper" {
                    
                    NIMSDK.shared().conversationManager.markAllMessagesRead(in: NIMSession(message.from ?? "", type: .P2P))
                    delegate.nim_onRecvSystem?(message: message)
                    
                }else if message.session?.sessionType == .chatroom {
                    
                    delegate.nim_onRecvChatroom?(message: message)
                    
                }else {
                    
                    delegate.nim_onRecvChat?(message: message)
                    
                }
            }
        }
    }
    
    /// 收到消息被撤回的通知
    /// 云信在收到消息撤回后，会先从本地数据库中找到对应消息并进行删除，之后通知上层消息已删除
    /// - Parameter notification: 被撤回的消息信息
    public func onRecvRevokeMessageNotification(_ notification: NIMRevokeMessageNotification) {
        
        for delegate in chatDelegates.allObjects {
            delegate.nim_onRecvRevoke?(notification: notification)
        }
    }
    
    /// 上传资源文件成功的回调
    /// 对于需要上传资源的消息(图片，视频，音频等)，SDK
    /// 将在上传资源成功后通过这个接口进行回调，上层可以在收到该回调后进行推送信息的重新配置 (APNS payload)
    /// - Parameters:
    ///   - urlString: 当前消息资源获得的 url 地址
    ///   - message: 当前发送的消息
    public func uploadAttachmentSuccess(_ urlString: String, for message: NIMMessage) {
        
        for delegate in chatDelegates.allObjects {
            
            guard message.session?.sessionType == .chatroom else {
                delegate.nim_chatUploadAttachmentSuccess?(urlString, message: message)
                continue
            }
            
            delegate.nim_ChatroomUploadAttachmentSuccess?(urlString, message: message)
        }
    }
    
    /// 收到消息回执
    /// 当上层收到此消息时所有的存储和 model 层业务都已经更新，只需要更新 UI 即可。
    /// - Parameter receipts: 消息回执数组
    public func onRecvMessageReceipts(_ receipts: [NIMMessageReceipt]) {
        
        for delegate in chatDelegates.allObjects {
            
            delegate.nim_onRecvMessage?(receipts: receipts)
            
            for receipt in receipts {
                
                if receipt.session?.sessionType == .chatroom {
                    
                    delegate.nim_onRecvChatroomMessage?(receipt: receipt)
                    
                }else {
                    
                    delegate.nim_onRecvChatMessage?(receipt: receipt)
                    
                }
            }
        }
    }
    
    /// 收取消息附件回调
    /// 附件包括:图片,视频的缩略图,语音文件
    /// - Parameters:
    ///   - message: 当前收取的消息
    ///   - progress: 进度
    public func fetchMessageAttachment(_ message: NIMMessage, progress: Float) {
        
        for delegate in chatDelegates.allObjects {
            
            guard message.session?.sessionType == .chatroom else {
                delegate.nim_chatFetchMessageAttachment?(message, progress: progress)
                continue
            }
            
            delegate.nim_ChatroomFetchMessageAttachment?(message, progress: progress)
        }
    }
    
    /// 收取消息附件完成回调
    ///
    /// - Parameters:
    ///   - message: 当前收取的消息
    ///   - error: 错误返回,如果收取成功,error为nil
    public func fetchMessageAttachment(_ message: NIMMessage, didCompleteWithError error: Error?) {
        
        for delegate in chatDelegates.allObjects {
            
            guard message.session?.sessionType == .chatroom else {
                delegate.nim_chatFetchMessageAttachment?(message, didCompleteWithError: error)
                continue
            }
            
            delegate.nim_ChatroomFetchMessageAttachment?(message, didCompleteWithError: error)
        }
    }
}




// MARK: - 消息发送相关
@objcMembers public class JDNIMSendMessageUntil: NSObject {
    
    // TODO: 消息重发
    public class func resend(_ message: NIMMessage) -> Error? {
        
        do {
            try NIMSDK.shared().chatManager.resend(message)
        } catch {
            return error
        }
        return nil
    }
    
    // TODO: 消息撤回
    public class func revoke(_ message: NIMMessage, handle: @escaping NIMRevokeMessageBlock) {
        NIMSDK.shared().chatManager.revokeMessage(message, completion: handle)
    }
    
    public class func syncRevoke(_ message: Any, session: NIMSession, block: NIMUpdateMessageBlock? = nil) {
        
        var messageTime: TimeInterval?
        var fromAccount: String?
        
        if let msg: NIMMessage = message as? NIMMessage {
            messageTime = msg.timestamp
            fromAccount = msg.from
        }
        
        if let msgNotic: NIMRevokeMessageNotification = message as? NIMRevokeMessageNotification {
            messageTime = msgNotic.timestamp
            fromAccount = msgNotic.fromUserId
        }
        
        assert(fromAccount != nil, "\(message)消息类型不正确, 无法正确解析")
        
        let isMe: Bool = fromAccount == NIMSDK.shared().loginManager.currentAccount()
        let name: String = isMe ? "你" : "对方"
        
        let tipMessage = NIMMessage()
        let tipObject = NIMTipObject()
        tipMessage.messageObject = tipObject
        tipMessage.text = name + "撤回了一条消息"
        
        let setting = NIMMessageSetting()
        setting.apnsEnabled = false
        setting.shouldBeCounted = false
        
        tipMessage.setting = setting
        tipMessage.timestamp = messageTime ?? NSDate().timeIntervalSinceNow
        
        NIMSDK.shared().conversationManager.save(tipMessage, for: session, completion: block)
    }
    

    // TODO: 文本消息
    public class func getTextMessage(_ text: String) -> NIMMessage {
        let message: NIMMessage = NIMMessage()
        message.text = text
        return message
    }
    
    public class func sendText(_ text: String, session: NIMSession) -> Error? {
        return sendTextMessage(getTextMessage(text), session: session)
    }
    
    public class func sendTextMessage(_ message: NIMMessage, session: NIMSession) -> Error? {
        do {
            try NIMSDK.shared().chatManager.send(message, to: session)
        } catch {
            return error
        }
        return nil
    }
    
    // TODO: 语音消息
    public class func getAudioMessage(_ filePath: String) -> NIMMessage {
        let message: NIMMessage = NIMMessage()
        message.text = "发来了一段语音"
        message.messageObject = NIMAudioObject(sourcePath: filePath)
        return message
    }
    
    public class func sendAudio(_ filePath: String, session: NIMSession) -> Error? {
        return sendAudioMessage(getAudioMessage(filePath), session: session)
    }
    
    public class func sendAudioMessage(_ message: NIMMessage, session: NIMSession) -> Error? {
        do {
            try NIMSDK.shared().chatManager.send(message, to: session)
        } catch {
            return error
        }
        return nil
    }
    
    // TODO: 视频消息
    public class func getVideoMessage(_ filePath: String) -> NIMMessage {
    
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let object: NIMVideoObject = NIMVideoObject(sourcePath: filePath)
        object.displayName = "视频发送于" + formatter.string(from: Date())
        
        let message: NIMMessage = NIMMessage()
        message.text = "发来了一段视频"
        message.messageObject = object
        return message
    }
    
    public class func sendVideo(_ filePath: String, session: NIMSession) -> Error? {
        return sendVideoMessage(getVideoMessage(filePath), session: session)
    }
    
    public class func sendVideoMessage(_ message: NIMMessage, session: NIMSession) -> Error? {
        do {
            try NIMSDK.shared().chatManager.send(message, to: session)
        } catch {
            return error
        }
        return nil
    }
    
    // TODO: 图片消息
    public class func getImageMessage(_ filePath: String?, image: UIImage?) -> NIMMessage {
        
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        var object: NIMImageObject?
        
        if filePath != nil {
            object = NIMImageObject(filepath: filePath!)
        }else if image != nil  {
            object = NIMImageObject(image: image!)
            let option = NIMImageOption()
            option.compressQuality = 0.7
            object?.option = option
        }
        
        assert(object != nil, "filePath和image必须有一个不为空")
        
        object!.displayName = "图片发送于" + formatter.string(from: Date())
        
        let message: NIMMessage = NIMMessage()
        message.text = "发来了一张图片"
        message.messageObject = object
        return message
    }
    
    public class func sendImage(_ filePath: String?, image: UIImage?, session: NIMSession) -> Error? {
        return sendImageMessage(getImageMessage(filePath, image: image), session: session)
    }
    
    public class func sendImageMessage(_ message: NIMMessage, session: NIMSession) -> Error? {
        do {
            try NIMSDK.shared().chatManager.send(message, to: session)
        } catch {
            return error
        }
        return nil
    }
    
    // TODO: 卡片消息
    public class func getCardMessage(_ text: String, remoteExt: Dictionary<AnyHashable, Any>?) -> NIMMessage {
        let message: NIMMessage = NIMMessage()
        message.text = text
        message.remoteExt = remoteExt
        return message
    }
    
    // 订单卡片
    public class func sendOrderCard(_ orderSn: String, content: Dictionary<AnyHashable, Any>, session: NIMSession) -> Error? {
        
        let remoteExt: Dictionary<AnyHashable, Any> =
            ["content" : content,
             "messageType" : JDMessageType.Card.order]
        
        return sendOrderCardMessage(getCardMessage("[订单] " + orderSn, remoteExt: remoteExt), session: session)
    }
    
    public class func sendOrderCardMessage(_ message: NIMMessage, session: NIMSession) -> Error? {
        do {
            try NIMSDK.shared().chatManager.send(message, to: session)
        } catch {
            return error
        }
        return nil
    }
    
    // 商品卡片
    public class func sendGoodsCard(_ goodSn: String, content: Dictionary<AnyHashable, Any>, session: NIMSession) -> Error? {
        
        let remoteExt: Dictionary<AnyHashable, Any> =
            ["content" : content,
             "messageType" : JDMessageType.Card.goods]
        
        return sendGoodsCardMessage(getCardMessage("[宝贝] " + goodSn, remoteExt: remoteExt), session: session)
    }
    
    public class func sendGoodsCardMessage(_ message: NIMMessage, session: NIMSession) -> Error? {
        do {
            try NIMSDK.shared().chatManager.send(message, to: session)
        } catch {
            return error
        }
        return nil
    }
    
    // 小视频卡片
    public class func sendSVideoCard(_ title: String, content: Dictionary<AnyHashable, Any>, session: NIMSession) -> Error? {
        
        let remoteExt: Dictionary<AnyHashable, Any> =
            ["content" : content,
             "messageType" : JDMessageType.Card.svideo]
        
        return sendSVideoCardMessage(getCardMessage("[小视频] " + title, remoteExt: remoteExt), session: session)
    }
    
    public class func sendSVideoCardMessage(_ message: NIMMessage, session: NIMSession) -> Error? {
        do {
            try NIMSDK.shared().chatManager.send(message, to: session)
        } catch {
            return error
        }
        return nil
    }
    
    // 拍卖卡片
    public class func sendAuctionCard(_ title: String, content: Dictionary<AnyHashable, Any>, session: NIMSession) -> Error? {
        
        let remoteExt: Dictionary<AnyHashable, Any> =
            ["content" : content,
             "messageType" : JDMessageType.Card.auction]
        
        return sendAuctionCardMessage(getCardMessage("[拍卖] " + title, remoteExt: remoteExt), session: session)
    }
    
    public class func sendAuctionCardMessage(_ message: NIMMessage, session: NIMSession) -> Error? {
        do {
            try NIMSDK.shared().chatManager.send(message, to: session)
        } catch {
            return error
        }
        return nil
    }
}
