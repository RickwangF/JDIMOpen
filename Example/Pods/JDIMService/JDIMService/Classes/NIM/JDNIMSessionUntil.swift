//
//  JDNIMSessionUntil.swift
//  JadeKing
//
//  Created by 张森 on 2019/8/8.
//  Copyright © 2019 张森. All rights reserved.
//

import Foundation
import NIMSDK

public enum JDMessageType {
    
    enum Out: String {
        /// 未知消息
        case unknow = "unknow"
        /// 消息不支持
        case noSupport = "noSupport"
    }
    
    enum Card: String {
        /// 卡片消息
        case defult = "JDSessionMsgDefultCard"
        /// 订单卡片
        case order = "JDSessionMsgOrderCard"
        /// 商品卡片
        case goods = "JDSessionMsgGoodsCard"
        /// 拍卖卡片
        case auction = "JDSessionMsgAuctionCard"
        /// 小视频卡片
        case svideo = "JDSessionMsgSVideoCard"
    }
    
    enum Live: String {
        /// 文本消息
        case text = "groupchat"
        /// 点赞消息
        case like = "doLike"
        /// 欢迎消息
        case welcome = "presence"
        /// 禁言消息
        case shutUp = "liveRoomGap"
        /// 解除禁言消息
        case notShutUp = "liveRoomStopGap"
        /// 分享消息
        case share = "shareLive"
        /// 关注消息
        case care = "focusPerson"
        /// 主播暂时离开直播间的消息
        case leave = "liveExist"
        /// 主播返回直播间的消息
        case comeBack = "liveStart"
        /// 直播结束的消息
        case end = "liveEnd"
        /// 系统消息
        case system = "systemMessage"
        /// 提示消息
        case tip = "tip"
    }
}

@objc public protocol JDNIMLoginDelegate {
    @objc optional func nim_loginSuccess()
    @objc optional func nim_loginFail(_ error: Error)
    @objc optional func nim_loginOfOtherDevice()
    @objc optional func nim_loginOut()
    @objc optional func nim_loginOfAlready()
    @objc optional func nim_loginStatus(_ step: NIMLoginStep)
}

@objcMembers public class JDNIM: NSObject{

    public static let `defult` = JDNIM()
    
    public var loginManager: JDNIMLoginManager {
        get{
           return login
        }
    }
    
    public var chatManager: JDNIMChatManager {
        get{
             return chat
        }
    }
    
    private lazy var login: JDNIMLoginManager = {
        let manager = JDNIMLoginManager()
        return manager
    }()
    
    private lazy var chat: JDNIMChatManager = {
        let manager = JDNIMChatManager()
        return manager
    }()
    
    public class func register(to appkey: String, apnsCerName: String? = nil) {
        
        let option: NIMSDKOption = NIMSDKOption(appKey: appkey)
        if apnsCerName != nil {
            option.apnsCername = apnsCerName
        }
        NIMSDK.shared().register(with: option)
    }
    
    public class func getUserInfo(account: String, complete: @escaping (_ user: NIMUser?, _ error: Error?) -> Void) {
        
        let user = NIMSDK.shared().userManager.userInfo(account)
        
        guard user == nil else {
            complete(user, nil)
            return
        }
        
        NIMSDK.shared().userManager.fetchUserInfos([account]) { (users, error) in
            complete(users?.first, nil)
        }
    }
    
    public class func updateUserInfo(_ userInfo: Dictionary<NSNumber, Any>, fail: ((_ error: Error) -> Void)?) {
        
        NIMSDK.shared().userManager.updateMyUserInfo(userInfo) { (error) in
            
            guard fail != nil else { return }
            
            guard error != nil else { return }
            
            fail!(error!)
        }
    }
}


// MARK: - JDNIMLogin
@objcMembers public class JDNIMLoginManager: NSObject, NIMLoginManagerDelegate {
    
    override init() {
        super.init()
        NIMSDK.shared().loginManager.add(self)
    }

    private var loginDelegates: NSHashTable<JDNIMLoginDelegate> = NSHashTable(options: .weakMemory)
    
    // TODO: 协议处理
    public func add(delegate: Any) {
        
        let `protocol` = delegate as? JDNIMLoginDelegate
        
        assert(`protocol` != nil, "\(delegate)必须遵循JDNIMLoginDelegate协议")
        
        let isContains = loginDelegates.contains(`protocol`!)
        
        assert(!isContains, "请先将\(delegate)remove委托后再add，不可重复添加委托")

        loginDelegates.add(`protocol`!)
    }
    
    public func remove(delegate: Any) {
        
        guard let `protocol`: JDNIMLoginDelegate = delegate as? JDNIMLoginDelegate else { return }
        
        let isContains = loginDelegates.contains(`protocol`)
        
        guard isContains else { return }
        
        loginDelegates.remove(`protocol`)
    }
    
    private func removeAllDelegate() {
        
        loginDelegates.removeAllObjects()
    }
    
    // TODO: 登录相关
    public func login(_ account: String, password: String) {
        
        let isSelfLogined: Bool = NIMSDK.shared().loginManager.isLogined() && NIMSDK.shared().loginManager.currentAccount() == account
        
        if isSelfLogined {
            for delegate in loginDelegates.allObjects {
                delegate.nim_loginOfAlready?()
            }
            return
        }
        
        let data: NIMAutoLoginData = NIMAutoLoginData()
        data.account = account
        data.token = password
        data.forcedMode = true
        NIMSDK.shared().loginManager.autoLogin(data)
    }
    
    public func loginOut(_ fail: ((Error) -> Void)?) {
        
        guard NIMSDK.shared().loginManager.isLogined() else { return }
        
        NIMSDK.shared().loginManager.logout { [unowned self] (error) in
            
            guard error != nil else {
                for delegate in self.loginDelegates.allObjects {
                    delegate.nim_loginOut?()
                }
                return
            }
            
            guard fail != nil else { return }
            
            fail!(error!)
        }
    }
    
    
    // TODO: NIMLoginManagerDelegate
    /// 被踢(服务器/其他端)回调
    ///
    /// - Parameters:
    ///   - code: 被踢原因
    ///   - clientType: 发起踢出的客户端类型
    public func onKick(_ code: NIMKickReason, clientType: NIMLoginClientType) {
        for delegate in loginDelegates.allObjects {
            delegate.nim_loginOfOtherDevice?()
        }
    }

    /// 登录回调主要用于客户端UI的刷新
    ///
    /// - Parameter step: 登录步骤
    public func onLogin(_ step: NIMLoginStep) {
        
        for delegate in loginDelegates.allObjects {
            delegate.nim_loginStatus?(step)
            
            if step == .loginOK {
                delegate.nim_loginSuccess?()
            }
        }
    }
    
    /// 自动登录失败回调
    /// 自动重连不需要上层开发关心，但是如果发生一些需要上层开发处理的错误，
    /// SDK会通过这个方法回调用户需要处理的情况包括：AppKey
    /// 未被设置，参数错误，密码错误，多端登录冲突，账号被封禁，操作过于频繁等
    /// - Parameter error: 失败原因
    public func onAutoLoginFailed(_ error: Error) {
        
        for delegate in loginDelegates.allObjects {
            delegate.nim_loginFail?(error)
        }
    }
    
    /// 多端登录发生变化
    public func onMultiLoginClientsChanged() {
        
    }

    /// 群用户同步完成通知
    ///
    /// - Parameter success: 群用户信息同步是否成功
    public func onTeamUsersSyncFinished(_ success: Bool) {
        
    }
    
    /// 超大群用户同步完成通知
    ///
    /// - Parameter success: 群用户信息同步是否成功
    public func onSuperTeamUsersSyncFinished(_ success: Bool) {
        
    }
}
