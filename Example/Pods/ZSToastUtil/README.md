# ZSToastUtil

[![CI Status](https://img.shields.io/travis/zhangsen093725/ZSToastUtil.svg?style=flat)](https://travis-ci.org/zhangsen093725/ZSToastUtil)
[![Version](https://img.shields.io/cocoapods/v/ZSToastUtil.svg?style=flat)](https://cocoapods.org/pods/ZSToastUtil)
[![License](https://img.shields.io/cocoapods/l/ZSToastUtil.svg?style=flat)](https://cocoapods.org/pods/ZSToastUtil)
[![Platform](https://img.shields.io/cocoapods/p/ZSToastUtil.svg?style=flat)](https://cocoapods.org/pods/ZSToastUtil)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

1. ZSAlertView
```
let alert = ZSAlertView()
let doneAction = ZSPopAction.zs_init(type: .done) {
ZSTipView.showTip("alert done and tip")
}
doneAction.setTitle("done and tip", for: .normal)
doneAction.setTitleColor(.white, for: .normal)
doneAction.backgroundColor = .red

let cancelAction = ZSPopAction.zs_init(type: .cancel) {
ZSTipView.showTip("alert cancel and tip duration 5", duration: 5)
}
cancelAction.setTitle("cancel and tip duration 5", for: .normal)
cancelAction.setTitleColor(.red, for: .normal)
cancelAction.backgroundColor = .white

alert.add(action: doneAction)
alert.add(action: cancelAction)

alert.alert(title: "alert title", message: "alert message alert message alert message")
```

2. ZSSheetView
```
let sheet = ZSSheetView()

let cancel2Action = ZSPopAction.zs_init(type: .cancel) {
ZSTipView.showTip("cancel and tip numberOfLines 2\ncancel and tip numberOfLines 2\ncancel and tip numberOfLines 2", numberOfLines: 2)
}
cancel2Action.setTitle("cancel and tip numberOfLines 2", for: .normal)
cancel2Action.setTitleColor(.red, for: .normal)
cancel2Action.backgroundColor = .white

let done2Action = ZSPopAction.zs_init(type: .done) {
ZSTipView.showTip("alert done and tip")
}
done2Action.setTitle("done and tip", for: .normal)
done2Action.setTitleColor(.white, for: .normal)
done2Action.backgroundColor = .red

sheet.add(action: done2Action)
sheet.add(action: cancel2Action)

sheet.sheet(title: "sheet title")
```

3. ZSTipView

```
ZSTipView.showTip("tip text")
```

4. ZSLoadingView

```
ZSLoadingView.startAnimation(to: nil, isBackColorClear: false)
```

## Requirements

## Installation

ZSToastUtil is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'ZSToastUtil'
```

## Author

zhangsen093725, 376019018@qq.com

## License

ZSToastUtil is available under the MIT license. See the LICENSE file for more info.
