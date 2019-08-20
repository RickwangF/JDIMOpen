//
//  ZSToastView.swift
//  ZSToastView
//
//  Created by 张森 on 2019/8/14.
//  Copyright © 2019 张森. All rights reserved.
//

import UIKit

private enum KDevice {
    
    // MARK: - 屏幕宽高、frame
    static let width: CGFloat = UIScreen.main.bounds.width
    static let height: CGFloat = UIScreen.main.bounds.height
    static let frame: CGRect = UIScreen.main.bounds
    
    // MARK: - 屏幕16:9比例系数下的宽高
    static let width16_9: CGFloat = KDevice.height * 9.0 / 16.0
    static let height16_9: CGFloat = KDevice.width * 16.0 / 9.0
    
    // MARK: - 关于刘海屏幕适配
    static let tabbarHeight: CGFloat = KDevice.aboveiPhoneX ? 83 : 49
    static let homeHeight: CGFloat = KDevice.aboveiPhoneX ? 34 : 0
    static let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.height
    
    // MARK: - 设备类型
    static let isPhone: Bool = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone)
    static let isPad: Bool = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad)
    static let aboveiPhoneX: Bool = (Float(String(format: "%.2f", 9.0 / 19.5)) == Float(String(format: "%.2f", KDevice.width / KDevice.height)))
}

private let KWidthUnit: CGFloat = KDevice.width / (KDevice.isPad ? 768.0 : 375.0)
private let KHeightUnit: CGFloat = KDevice.isPad ? KDevice.height / 1024.0 : ( KDevice.aboveiPhoneX ? KDevice.height16_9 / 667.0 : KDevice.height / 667.0 )

private func KFont(_ font: CGFloat) -> UIFont {
    return UIFont.systemFont(ofSize: font * KHeightUnit)
}

private func KColor(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat) -> UIColor {
    return UIColor.init(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: alpha)
}



// MARK: - 弹窗按钮
@objc public enum ZSPopActionType: Int {
    case done = 0, cancel
}

@objcMembers public class ZSPopAction: UIButton {
    
    private var action: (()->Void)?
    private var type: ZSPopActionType = .done
    
    public var popAction: (()->Void)? {
        get {
            return action
        }
    }
    
    public var popType: ZSPopActionType {
        get {
            return type
        }
    }
    
    public class func zs_init(type: ZSPopActionType, action: (()->Void)?) -> ZSPopAction {
        
        let popAction = ZSPopAction(type: .system)
        popAction.tintColor = .clear
        popAction.setTitleColor(KColor(82, 82, 82, 1), for: .normal)
        popAction.titleLabel?.font = KDevice.isPad ? KFont(17) : KFont(15)
        popAction.type = type
        popAction.action = action
        
        return popAction
    }
    
}



// MARK: - ZSPopBaseView
public class ZSPopBaseView: UIView {
    
    fileprivate lazy var backView: UIScrollView = {
        
        let view = UIScrollView()
        view.backgroundColor = .white
        view.layer.shadowColor = KColor(189, 189, 189, 1).cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowOpacity = 1
        view.clipsToBounds = true
        addSubview(view)
        return view
    }()
    
    fileprivate lazy var titleLabel: UILabel = {
        
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = KColor(21, 23, 35, 1)
        label.font = KDevice.isPad ? KFont(20) : KFont(16)
        label.textAlignment = .center
        backView.addSubview(label)
        return label
    }()
    
    fileprivate var lineLabel: UILabel {
        get {
            let label = UILabel()
            label.backgroundColor = KColor(239, 239, 239, 1)
            backView.addSubview(label)
            return label
        }
    }
    
    fileprivate var actions: Array<ZSPopAction>? = []
    
    fileprivate func layoutToView() {
        frame = UIScreen.main.bounds
        alpha = 1
        backgroundColor = KColor(0, 0, 0, 0.5)
        
        var controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController
        
        while (controller?.presentedViewController != nil && !(controller?.presentedViewController is UIAlertController)) {
            controller = controller?.presentedViewController
        }
        controller?.view.addSubview(self)
    }
    
    @objc public func add(action: ZSPopAction) {
        actions?.append(action)
        backView.addSubview(action)
    }
}



// MARK: - ZSAlertView
@objcMembers public class ZSAlertView: ZSPopBaseView {
    
    private lazy var messageLabel: UILabel = {
        
        let label = UILabel()
        label.numberOfLines = 0
        backView.addSubview(label)
        return label
    }()
    
    private func getMessageAttribute(_ message: String, textMaxSize: CGSize) -> Dictionary<NSAttributedString.Key, Any> {
        
        let msgFont = KDevice.isPad ? KFont(16) : KFont(14)
        var tempAttribute: Dictionary<NSAttributedString.Key, Any>? = [.font : msgFont]
        
        let msgHeight = message.boundingRect(with: textMaxSize, options: .usesLineFragmentOrigin, attributes: tempAttribute, context: nil).size.height
        let lineHeight = 8 * KHeightUnit
        
        let paraStyle = NSMutableParagraphStyle()
        
        paraStyle.lineSpacing = msgHeight > msgFont.lineHeight ? lineHeight : 0
        paraStyle.alignment = .center
 
        tempAttribute?[.foregroundColor] = KColor(82, 82, 82, 1)
        tempAttribute?[.paragraphStyle] = paraStyle
        return tempAttribute!
    }
    
    private func layoutBackView(_ backX: CGFloat, backHeight: CGFloat) {
        
        let backH = min(backHeight, 470 * KHeightUnit)
        backView.frame = CGRect(x: backX, y: (KDevice.height - backH) * 0.5, width: KDevice.width - 2 * backX, height: backH)
        backView.contentSize = CGSize(width: 0, height: backHeight)
        backView.layer.cornerRadius = 15 * KHeightUnit
        backView.layer.shadowRadius = 15 * KHeightUnit
    }
    
    private func layoutAction() {
        
        var actionWidth = backView.frame.width
        var actionHeight = (KDevice.isPad ? 50 : 40) * KHeightUnit
        var actionY = messageLabel.frame.maxY + 32 * KHeightUnit
        
        if actions?.count == 2 {
            actionWidth = backView.frame.width * 0.5
            lineLabel.frame = CGRect(x: actionWidth, y: actionY, width: 1, height: actionHeight)
            lineLabel.frame = CGRect(x: 0, y: actionY, width: backView.frame.width, height: 1)
            actionY += 1
            actionHeight += 1
        }
        
        guard let tempActions = actions else { return }
        
        for (index, action) in tempActions.enumerated() {
            
            action.frame = CGRect(x: 0, y: actionY + actionHeight * CGFloat(index), width: actionWidth, height: actionHeight)
            action.addTarget(self, action: #selector(popAction(_:)), for: .touchUpInside)
            
            lineLabel.frame = CGRect(x: 0, y: actionY + actionHeight * CGFloat(index), width: actionWidth, height: 1)
            actionY += 1
            actionHeight -= 1
            
            switch action.popType {
            case .done:
                
                if actions?.count == 2 {
                    action.frame = CGRect(x: actionWidth + 1, y: actionY - 1, width: actionWidth - 1, height: actionHeight + 1)
                    continue
                }
                action.restorationIdentifier = "done_\(index)"
                continue
                
            case .cancel:
                
                if actions?.count == 2 {
                    action.frame = CGRect(x: 0, y: actionY - 1, width: actionWidth, height: actionHeight + 1)
                    continue
                }
                action.restorationIdentifier = "cancel_\(index)"
                continue
                
            default: continue
            }
        }
    }
    
    private func animation(_ values: Array<Any>?) {
        let keyFrameAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        keyFrameAnimation.duration = 0.25
        keyFrameAnimation.values = values
        keyFrameAnimation.isCumulative = false
        keyFrameAnimation.isRemovedOnCompletion = false
        backView.layer.add(keyFrameAnimation, forKey: "Scale")
    }
    
    private func dismiss() {
        
        animation([1.2, 1, 0.8, 0.6, 0])
        UIView.animate(withDuration: 0.2, animations: { [unowned self] in
            self.alpha = 0.1
        }) { [unowned self] (finished) in
            self.removeFromSuperview()
        }
    }
    
    @objc private func popAction(_ button: ZSPopAction) {
        dismiss()
        guard button.popAction != nil else { return }
        button.popAction!()
    }
    
    public func alert(title: String, message: String) {
        
        let backX = (KDevice.isPad ? 220 : 45) * KWidthUnit
        let labelX = 31 * KWidthUnit
        let labelW = KDevice.width - (backX + labelX) * 2
        let textSize = CGSize(width: labelW, height: CGFloat(MAXFLOAT))
        
        let messageAttribute = NSAttributedString(string: message, attributes: getMessageAttribute(message, textMaxSize: textSize))
        
        let titleHeight = title.boundingRect(with: textSize, options: .usesLineFragmentOrigin, attributes: [.font : titleLabel.font ?? KFont(0)], context: nil).size.height
        
        let msgAttributeHeight = messageAttribute.boundingRect(with: textSize, options: [.usesFontLeading, .usesLineFragmentOrigin], context: nil).size.height
        
        let textSpace = 32 * KHeightUnit
        
        let actionHeight = (KDevice.isPad ? 50 : 40) * KHeightUnit * CGFloat(actions?.count != 2 ? (actions?.count ?? 0) : 1)
        
        let space = textSpace * (titleHeight > 0 ? (msgAttributeHeight > 0 ? 2.5 : 2) : (msgAttributeHeight > 0 ? 1.5 : 1))
        
        layoutBackView(backX, backHeight: space + titleHeight + msgAttributeHeight + actionHeight)
        
        titleLabel.frame = CGRect(x: labelX, y: titleHeight > 0 ? textSpace : 0, width: labelW, height: titleHeight)
        titleLabel.text = title
        
        messageLabel.frame = CGRect(x: labelX, y: titleLabel.frame.maxY + textSpace * (msgAttributeHeight > 0 ? 0.5 : 0), width: labelW, height: msgAttributeHeight)
        messageLabel.attributedText = messageAttribute
        
        layoutToView()
        layoutAction()
        animation([0, 1, 1.1, 1])
    }
}



// MARK: - ZSSheetView
@objcMembers public class ZSSheetView: ZSPopBaseView {
    
    public var sheetSpace: CGFloat = 0
    public var sheetActionHeight: CGFloat = (KDevice.isPad ? 120 : 40) * KHeightUnit
    
    public func sheet(title: String? = nil) {
        
        let titleLabelX = 20 * KWidthUnit
        let backWidth = KDevice.width - 2 * sheetSpace
        let titleWidth = backWidth - 2 * titleLabelX
        
        let titleHeight: CGFloat = title?.boundingRect(with: CGSize(width: titleWidth, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [.font : titleLabel.font ?? KFont(0)], context: nil).size.height ?? 0
        
        let textSpace = titleHeight > 0 ? 12 * KHeightUnit : 0
        
        var actionHeight = sheetActionHeight
        actionHeight *= CGFloat(actions?.count ?? 0)
        
        titleLabel.frame = CGRect(x: titleLabelX, y: textSpace, width: titleWidth, height: titleHeight)
        titleLabel.text = title
        
        layoutToView()
        layoutBackView(sheetSpace, backHeight: titleLabel.frame.maxY + actionHeight)
        layoutAction()
    }
    
    
    private func layoutBackView(_ backX: CGFloat, backHeight: CGFloat) {
        
        let backH = min(backHeight, 500 * KHeightUnit)
        backView.frame = CGRect(x: backX, y: (KDevice.height - backH) - (sheetSpace > 0 ? 5 : 0) * KHeightUnit - KDevice.homeHeight, width: KDevice.width - 2 * backX, height: backH + KDevice.homeHeight)
        backView.contentSize = CGSize(width: 0, height: backHeight)
        backView.layer.cornerRadius = sheetSpace > 0 ? 15 * KHeightUnit : 0
        backView.layer.shadowRadius = sheetSpace > 0 ? 15 * KHeightUnit : 0
    }
    
    private func layoutAction() {
        
        let actionWidth = backView.frame.width
        var actionHeight = sheetActionHeight
        var actionY = titleLabel.frame.maxY + 20 * KHeightUnit
        
        guard let tempActions = actions else { return }
        
        for (index, action) in tempActions.enumerated() {
            
            action.frame = CGRect(x: 0, y: actionY + actionHeight * CGFloat(index), width: actionWidth, height: actionHeight)
            
            if titleLabel.bounds.height > 0 &&
                index + 1 < (actions?.count ?? 0) {
                
                lineLabel.frame = CGRect(x: 0, y: actionY + actionHeight * CGFloat(index + 1), width: actionWidth, height: 1)
                actionY += 1
                actionHeight -= 1
                continue
            }
            
            action.addTarget(self, action: #selector(popAction(_:)), for: .touchUpInside)
            
            switch action.popType {
            case .done:
                
                action.restorationIdentifier = "done_\(index)"
                continue
                
            case .cancel:
                
                action.restorationIdentifier = "cancel_\(index)"
                continue
                
            default: continue
            }
        }
    }
    
    private func animation(_ values: Array<Any>?) {
        UIView.animate(withDuration: 0.2, animations: { [unowned self] in
            self.alpha = 0.1
            self.backView.frame.origin.y = KDevice.height
        }) { [unowned self] (finished) in
            self.removeFromSuperview()
        }
    }
    
    private func dismiss() {
        UIView.animate(withDuration: 0.2, animations: { [unowned self] in
            self.alpha = 0.1
            self.backView.frame.origin.y = KDevice.height
        }) { [unowned self] (finished) in
            self.removeFromSuperview()
        }
    }
    
    @objc private func popAction(_ button: ZSPopAction) {
        dismiss()
        guard button.popAction != nil else { return }
        button.popAction!()
    }
}




// MARK: - ZSTipView
@objcMembers public class ZSTipView: UIView {
    
    private lazy var tipLabel: UILabel = {
        
        let label = UILabel()
        label.font = KFont(14)
        label.textAlignment = .center
        label.textColor = KColor(254, 253, 253, 1)
        label.clipsToBounds = true
        addSubview(label)
        return label
    }()
    
    public class func tip(title: String,
                          alpha: CGFloat = 1,
                          duration: TimeInterval = 2,
                          numberOfLines: Int = 0,
                          spaceHorizontal: CGFloat = 20,
                          spaceVertical: CGFloat = 12) {
        
        let tipView = ZSTipView()
        tipView.alpha = 0
        tipView.isUserInteractionEnabled = false
        
        let titleSize: CGSize = title.boundingRect(with: CGSize(width: KDevice.width - (20 + spaceHorizontal) * KWidthUnit, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [.font : tipView.tipLabel.font ?? KFont(0)], context: nil).size
        
        let tipSize = CGSize(width: titleSize.width, height: numberOfLines > 0 ? CGFloat(numberOfLines) * 15.0 * KHeightUnit : titleSize.height)
        
        tipView.frame = CGRect(x: (KDevice.width - tipSize.width - spaceHorizontal) * 0.5, y: (KDevice.height - tipSize.height - spaceVertical) * 0.5, width: tipSize.width + spaceHorizontal, height: tipSize.height + spaceVertical)
        
        tipView.tipLabel.frame = tipView.bounds
        tipView.tipLabel.layer.cornerRadius = (tipSize.height > 15 * KHeightUnit ? 8 * KWidthUnit : (tipSize.height + spaceVertical) * 0.5)
        tipView.tipLabel.backgroundColor = KColor(0, 0, 0, alpha)
        tipView.tipLabel.numberOfLines = numberOfLines
        tipView.tipLabel.text = title
        
        var controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController
        
        while (controller?.presentedViewController != nil && !(controller?.presentedViewController is UIAlertController)) {
            controller = controller?.presentedViewController
        }
        controller?.view.addSubview(tipView)
        
        UIView.animate(withDuration: 0.3, animations: { [unowned tipView] in
            
            tipView.alpha = 1
            
        }) { (finished) in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: {
                
                UIView.animate(withDuration: 0.3, animations: { [unowned tipView] in
                    
                    tipView.alpha = 0
                    
                }) { [unowned tipView] (finished) in
                    
                    tipView.removeFromSuperview()
                }
            })
        }
    }
    
    public class func showTip(_ title: String) {
        self.tip(title: title)
    }
    
    public class func showTip(_ title: String,
                              duration: TimeInterval) {
        self.tip(title: title, duration: duration)
    }
    
    public class func showTip(_ title: String,
                              numberOfLines: Int) {
        self.tip(title: title, numberOfLines: numberOfLines)
    }
}
