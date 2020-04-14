//
//  ViewController.swift
//  CustomEmoticonKeyboard
//
//  Created by 李贺 on 2020/4/14.
//  Copyright © 2020 Heli. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        title = "自定义表情键盘"
        
        view.addSubview(customTextView)
        view.addSubview(switchView)
        
        customTextView.snp_makeConstraints { (make) in
            make.left.right.top.equalTo(view)
            make.bottom.equalTo(view).offset(-AdaptTabHeight)
        }
        switchView.snp_makeConstraints { (make) in
            make.left.right.bottom.equalTo(view)
            make.height.equalTo(40 + AdaptTabHeight)
        }
        
        // 监听键盘将要改变frame通知
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification , object: nil)
        // 监听表情键盘的表情按钮点击
        NotificationCenter.default.addObserver(self, selector: #selector(emoticonButtonNoti), name: NSNotification.Name(rawValue: EMOTICONBUTTONCLICKNOTI), object: nil)
        // 监听表情键盘删除按钮点击
        NotificationCenter.default.addObserver(self, selector: #selector(emoticonDeleteButtonNoti), name: NSNotification.Name(rawValue: EMOTICONDELETEBUTTONCLICKNOTI), object: nil)
    }
    
    // 自定义textView
    private lazy var customTextView: CustomTextView = {
        let view = CustomTextView()
        // 设置占位文字
        view.placeholder = "设置占位文字设置占位文字设置占位文字设置占位文字设置占位文字设置占位文字设置占位文字"
        // 设置字体大小
        view.font = UIFont.systemFont(ofSize: 14)
        // 允许textView 垂直滚动
        view.alwaysBounceVertical = true
        // 设置代理, 滚动时, 推下键盘
        view.delegate = self
        return view
    }()
    
    // 切换自定义表情键盘控件
    private lazy var switchView: SwitchView = {
        let view = SwitchView()
        view.closure = { [weak self] in
            // 切换键盘
            // 切换键盘
            self?.switchKeyboard()
        }
        return view
    }()
    
    // 自定义的表情键盘 -> inputView
    fileprivate lazy var emoticonKeyboardView: HEmoticonKeyboardView = HEmoticonKeyboardView()
}

// MARK: 既然这里使用了代理, 那么customTextView 内部监听是否有文字输入就需要使用通知了!!!
extension ViewController: UITextViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 取消第一响应
        self.customTextView.resignFirstResponder()
    }
}

// MARK: - 切换键盘 -> 表情键盘/文字键盘
extension ViewController {

    // UITextView 自带的inputView 属性, 可以重新赋值来切换
    func switchKeyboard(){
        // 如果inputView == nil 就代表是系统键盘 改成自定义键盘
        if self.customTextView.inputView == nil {
            self.customTextView.inputView = self.emoticonKeyboardView
            // 改成true
            self.switchView.isEmoticon = true
        }else {
            // 如果inputView != nil 就代表你设置了自定义键盘 改成系统键盘
            self.customTextView.inputView = nil
            // 改成false
            self.switchView.isEmoticon = false
        }
        // 开启第一响应
        self.customTextView.becomeFirstResponder()
        // 刷新
        self.customTextView.reloadInputViews()
    }
}

// MARK: - 监听通知
extension ViewController {
    
    // 监听键盘的frame将要发生改变
    @objc func keyboardWillChangeFrame(noti: Notification){
        // 判断userInfo是否为nil 是否可以转成字典
        guard let userInfo = noti.userInfo as? [String: Any] else{
            return
        }
        // 获取键盘的frame
        let frame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        // 获取键盘动画时间
        let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        // 更改底部视图的bottom
        self.switchView.snp_updateConstraints { (make) in
            
            make.bottom.equalTo(view).offset(frame.origin.y - KSCREENHEIGHT)
            if frame.origin.y != KSCREENHEIGHT {
                make.height.equalTo(40)
            } else {
                make.height.equalTo(40 + AdaptTabHeight)
            }
        }

        // 设置动画
        UIView.animate(withDuration: duration) {
            // 刷新ui
            self.view.layoutIfNeeded()
        }
    }
    
    // 监听表情键盘按钮点击
    @objc private func emoticonButtonNoti(noti: Notification){
    
        // 判断是否为nil 且是否可以转成HEmoticonModel
        guard let emoticonModel = noti.object as? HEmoticonModel  else {
            return
        }

        // 保存用户点击的那个表情的模型 -> 存储到本地, 作为 最近 的数据
        HEmoticonTools.shared.saveRecentModel(emoticonModel: emoticonModel)
        // 刷新pageView
        self.emoticonKeyboardView.reloadRecentData()
        
        // 判断如果是emoji表情
        if emoticonModel.isEmoji {
            let code = ((emoticonModel.code ?? "") as NSString).emoji()
            self.customTextView.insertText(code!)
        }else {
            
            // 获取当前composeTextView上的富文本
            let allAttr = NSMutableAttributedString(attributedString: self.customTextView.attributedText)
            // 图片表情
            // 定义一个不可变的富文本
            let attr = NSAttributedString.emoticonAttributedString(emoticonModel: emoticonModel)
            // 获取当前composeText 的selectRange (光标)
            let selectRange = self.customTextView.selectedRange
            // 替换
            allAttr.replaceCharacters(in: selectRange, with: attr)
            // 范围
            let range = NSRange(location: 0, length: allAttr.length)
            // 设置字体大小
            allAttr.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 14), range: range)
            // 设置富文本给textView
            self.customTextView.attributedText = allAttr
            // 重新设置他的光标位置
            self.customTextView.selectedRange = NSRange(location: selectRange.location + 1, length: 0)

            // 要把composeTextView 的占位文字隐藏
            // 帮系统发送一个通知, 因为textView输入富文本图片, 不会触发系统监听和代理
            NotificationCenter.default.post(name: UITextView.textDidChangeNotification, object: nil)
        }
    }
    
    // 监听删除按钮点击
    @objc private func emoticonDeleteButtonNoti(){
        // 删除
        self.customTextView.deleteBackward()
    }
}


