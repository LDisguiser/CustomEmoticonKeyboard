//
//  CustomTextView.swift
//  CustomEmoticonKeyboard
//
//  Created by 李贺 on 2020/4/14.
//  Copyright © 2020 Heli. All rights reserved.
//

import UIKit

class CustomTextView: UITextView {
    
    /// 共外界设置占位文字
    var placeholder: String?{
        didSet{
            // 设置占位文字
            placeholderLabel.text = placeholder
        }
    }
    
    /// 重写font 属性 在didSet方法中监听它设置了多大的字体
    override var font: UIFont?{
        didSet{
            // 设置占位文字的font
            placeholderLabel.font = font
        }
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - 设置视图
    private func setupUI(){
        // 添加控件
        addSubview(placeholderLabel)
        // 添加约束
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        addConstraints([NSLayoutConstraint(item: placeholderLabel, attribute: NSLayoutConstraint.Attribute.left, relatedBy: .equal, toItem: self, attribute: NSLayoutConstraint.Attribute.left, multiplier: 1, constant: 5)])
        addConstraints([NSLayoutConstraint(item: placeholderLabel, attribute: NSLayoutConstraint.Attribute.top, relatedBy: .equal, toItem: self, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 8)])
        addConstraints([NSLayoutConstraint(item: placeholderLabel, attribute: NSLayoutConstraint.Attribute.width, relatedBy: .equal, toItem: self, attribute: NSLayoutConstraint.Attribute.width, multiplier: 1, constant: -10)])
        
        // 通过监听系统通知来监听textView 的文字改变
        // 注: 这里不能够使用代理, 因为外界已经使用代理来根据是否输入了文字判断导航栏的按钮状态(代理一对一, 已经被使用了, 这里就不能用了)
        NotificationCenter.default.addObserver(self, selector: #selector(textChange), name: UITextView.textDidChangeNotification, object: nil)
    }
    
    // 监听文字改变
    @objc private func textChange(){
        placeholderLabel.isHidden = self.hasText
    }
    
    //MARK: - 懒加载控件
    // 占位label
    private lazy var placeholderLabel: UILabel = {
        let lab = UILabel()
        // 设置颜色
        lab.textColor = UIColor.darkGray
        // 换行
        lab.numberOfLines = 0
        return lab
    }()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}
