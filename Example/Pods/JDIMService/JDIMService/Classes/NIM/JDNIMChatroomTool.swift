//
//  JDNIMChatRoomTool.swift
//  JadeKing
//
//  Created by 张森 on 2019/8/10.
//  Copyright © 2019 张森. All rights reserved.
//

import Foundation
import NIMSDK

@objcMembers public class JDNIMChatroomManager: NSObject {
    
    public class func enterChatroom(_ roomId: String, roomNotifyExt: String? = nil, nickname: String, avatar: String, completion: @escaping NIMChatroomEnterHandler) {
        
        let request = NIMChatroomEnterRequest()
        request.roomId = roomId
        request.roomNickname = nickname
        request.roomAvatar = avatar
        request.roomNotifyExt = roomNotifyExt
        
        NIMSDK.shared().chatroomManager.enterChatroom(request, completion: completion)
    }
    
    public class func exitChatroom(_ roomId: String, completion: @escaping NIMChatroomHandler) {
        
        NIMSDK.shared().chatroomManager.exitChatroom(roomId, completion: completion)
    }
    
    public class func fetchMessageHistory(_ roomId: String, completion: @escaping NIMFetchChatroomHistoryBlock) {
        
        let option = NIMHistoryMessageSearchOption()
        option.limit = 30
        option.order = .desc
        option.messageTypes = [NSNumber(nonretainedObject: NIMMessageType.text)]
        NIMSDK.shared().chatroomManager.fetchMessageHistory(roomId, option: option, result: completion)
    }
    
}



// MARK: - 发送消息相关
extension Dictionary {
    var jsonString: String? {
        get{
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: self, options: [])
                return String.init(data: jsonData, encoding: .utf8)
            } catch {
                return nil
            }
        }
    }
}

@objcMembers public class JDNIMSendLiveMessageUntil: NSObject {
    
    private class func verfiyName(_ nickName: String) -> String {
        return nickName.count > 9 ? String(nickName.prefix(2)) + "***" + String(nickName.suffix(4)) : nickName
    }
    
    // TODO: 分享消息
    public class func getShareContent(_ sharePlat: String?, nickName: String) -> String {
        
        let name: String = verfiyName(nickName)

        guard sharePlat != nil else { return "感谢 " + name + " 分享了直播" }
        
        return "感谢 " + name + " 分享直播到" + sharePlat!
    }

    public class func getShareMessage(_ sharePlat: String?, nickName: String, content: Dictionary<AnyHashable, Any>) -> NIMMessage? {
        
        var params = content
        
        params["content"] = getShareContent(sharePlat, nickName: nickName)
        params["type"] = JDMessageType.Live.share
        
        guard let text = params.jsonString else { return nil }
        
        return JDNIMSendMessageUntil.getTextMessage(text)
    }
    
    public class func sendShareMessage(_ message: NIMMessage, roomId: String) -> Error? {
        
        return JDNIMSendMessageUntil.sendTextMessage(message, session: NIMSession(roomId, type: .chatroom))
    }
    
    // TODO: 关注消息
    public class func getFouceContent(_ nickName: String) ->String {
        
        return "感谢 " + verfiyName(nickName) + " 关注了主播"
    }
    
    public class func getFouceMessage(_ nickName: String, content: Dictionary<AnyHashable, Any>) -> NIMMessage? {
        
        var params = content
        
        params["content"] = getFouceContent(nickName)
        params["type"] = JDMessageType.Live.care

        guard let text = params.jsonString else { return nil }
        
        return JDNIMSendMessageUntil.getTextMessage(text)
    }
    
    public class func sendFouceMessage(_ message: NIMMessage, roomId: String) -> Error? {
        
        return JDNIMSendMessageUntil.sendTextMessage(message, session: NIMSession(roomId, type: .chatroom))
    }
    
    // TODO: 聊天消息
    public class func getChatMessage(_ text: String, content: Dictionary<AnyHashable, Any>) -> NIMMessage? {
        
        var params = content
        
        params["content"] = text
        params["type"] = JDMessageType.Live.text
        
        guard let text = params.jsonString else { return nil }
        
        return JDNIMSendMessageUntil.getTextMessage(text)
    }
    
    public class func sendChatMessage(_ message: NIMMessage, roomId: String) -> Error? {
        
        return JDNIMSendMessageUntil.sendTextMessage(message, session: NIMSession(roomId, type: .chatroom))
    }
    
    public class func sendChatRequest(_ urlString: String,
                                      params: Dictionary<String, Any>?,
                                      userToken: String,
                                      fail: ((String) -> Void)?) {
        
        let linkStr =  urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) ?? urlString
        let url = URL.init(string: linkStr)
  
        var request = URLRequest.init(url: url!)
        request.httpMethod = "POST"
        
        request.setValue(userToken, forHTTPHeaderField: "userToken")

        request.httpBody = try! JSONSerialization.data(withJSONObject: params ?? [:], options: .prettyPrinted)

        
        let postTask = URLSession.shared.dataTask(with: request) { ( data, response, error) in
            if (data != nil) && error == nil {
                guard fail != nil else { return }
                
                guard data != nil else { return }
                
                do {
                    let object = try JSONSerialization.jsonObject(with: data!, options: [])
                    
                    guard let responseObject: Dictionary<AnyHashable, Any> = object as? Dictionary<AnyHashable, Any> else { return }
                    
                    guard let status: String = responseObject["status"] as? String else { return }
                    
                    guard status != "0" else { return }
                    
                    guard let msg: String = responseObject["msg"] as? String else { return }
                    
                    fail!(msg)
                    
                } catch {
                    return
                }
            }
//            let  mutableResponse =  response as! HTTPURLResponse
        }
        postTask.resume()
    }
    
    // TODO: 系统消息
    public class func getSystemMessage(_ text: String, content: Dictionary<AnyHashable, Any>) -> NIMMessage? {
        
        var params = content
        
        params["content"] = text
        params["type"] = JDMessageType.Live.system
        
        guard let text = params.jsonString else { return nil }
        
        return JDNIMSendMessageUntil.getTextMessage(text)
    }
}
