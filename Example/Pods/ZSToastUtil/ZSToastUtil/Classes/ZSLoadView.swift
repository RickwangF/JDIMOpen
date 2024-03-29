//
//  ZSLoadView.swift
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


private extension Timer {
    
    class func zs_supportiOS_10EarlierTimer(_ interval: TimeInterval, repeats: Bool, block: @escaping (_ timer: Timer) -> Void) -> Timer {
        
        if #available(iOS 10.0, *) {
            return Timer.init(timeInterval: interval, repeats: repeats, block: block)
        } else {
            return Timer.init(timeInterval: interval, target: self, selector: #selector(runTimer(_:)), userInfo: block, repeats: repeats)
        }
    }
    
    @objc private class func runTimer(_ timer: Timer) -> Void {
        
        guard let block: ((Timer) -> Void) = timer.userInfo as? ((Timer) -> Void) else { return }
        
        block(timer)
    }
}



// MARK: - ZSLoadingView
@objcMembers public class ZSLoadingView: UIView {
    
    private static let `defult` = ZSLoadingView()
    
    private var startRatio: Double = 0.1 {
        willSet {
            setNeedsDisplay()
        }
    }
    
    private var endRatio: Double = 1.9 {
        willSet {
            setNeedsDisplay()
        }
    }
    
    private var timer: Timer?
    
    override public func draw(_ rect: CGRect) {
        
        let lineWidth: CGFloat = 2
        
        let bezierWidth: CGFloat = rect.width - 20
        let bezierHeight: CGFloat = rect.height - 20
        
        let radius = (min(bezierWidth, bezierHeight) - lineWidth) * 0.5
        
        let bezierPath = UIBezierPath()
        bezierPath.lineWidth = lineWidth
        UIColor.white.set()
        bezierPath.lineCapStyle = .round
        bezierPath.lineJoinStyle = .round
        
        bezierPath.addArc(withCenter: CGPoint(x: rect.width * 0.5, y: rect.height * 0.5), radius: radius, startAngle: CGFloat(Double.pi * (1.5 + startRatio)), endAngle: CGFloat(Double.pi * (1.5 + endRatio)), clockwise: true)
    
        bezierPath.stroke()
    }
    
    private func startTimer() {
        guard timer == nil else { return }
        
        timer = Timer.zs_supportiOS_10EarlierTimer(0.025, repeats: true, block: { [unowned self] (timer) in
            
            if self.startRatio >= 2.1 {
                self.startRatio = 0.1
                self.endRatio = 1.9
            }
            
            self.endRatio += 0.05
            self.startRatio += 0.05
        })
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func startAnimation(to view: UIView? = nil, isBackColorClear: Bool = false) {
        
        stopTimer()
        
        if view == nil {
            
            let viewWidth = view?.frame.width ?? 0
            let viewHeight = view?.frame.height ?? 0
            
            let size = viewWidth > 0 ? 80 * KHeightUnit : 0
            
            frame = CGRect(x: (viewWidth - size) * 0.5, y: (viewHeight - size) * 0.5, width: size, height: size)
            
            
            view?.addSubview(self)

        }else{
            
           frame = CGRect(x: (KDevice.width - 80 * KHeightUnit) * 0.5, y: (KDevice.height - 80 * KHeightUnit) * 0.5, width: 80 * KHeightUnit, height: 80 * KHeightUnit)
            
            var controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController
            
            while (controller?.presentedViewController != nil && !(controller?.presentedViewController is UIAlertController)) {
                controller = controller?.presentedViewController
            }
            controller?.view.addSubview(self)
        }

        backgroundColor = isBackColorClear ? .clear : KColor(0, 0, 0, 0.7)
        layer.cornerRadius = 10 * KHeightUnit
        clipsToBounds = true
        setNeedsDisplay()
        
        startTimer()
    }
    
    private func stopAnimation() {
        
        stopTimer()
        
        UIView.animate(withDuration: 0.25, animations: { [unowned self] in
            self.alpha = 0
        }) { [unowned self] (finished) in
            self.removeFromSuperview()
        }
    }
    
    
    public class func startAnimation(to view: UIView? = nil, isBackColorClear: Bool = false) {
        ZSLoadingView.defult.startAnimation(to: view, isBackColorClear: isBackColorClear)
    }
    
    public class func stopAnimation() {
        ZSLoadingView.defult.stopAnimation()
    }
}
