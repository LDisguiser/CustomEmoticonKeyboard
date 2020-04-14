//
//  HEmoticonKeyboardBottomView.swift
//  WB
//
//  Created by 李贺 on 2020/4/14.
//  Copyright © 2020 Heli. All rights reserved.
//

import UIKit

/*
    UIStackView ios 9 以后的新控件
       - 注意 他是一个容器视图
*/

enum HEmoticonKeyboardBottomViewType: Int{
    // 最近
    case recent = 100
    // 默认
    case normal = 101
    // emoji
    case emoji = 102
    // 浪小花
    case lxh = 103
}

class HEmoticonKeyboardBottomView: UIStackView {
    
    // 记录上一次选中的按钮
    var lastButton: UIButton?
    
    // 定义闭包, 传递点击事件
    var closure:((HEmoticonKeyboardBottomViewType)->())?
    
    // MARK: - 提供一个方法供外界设置当前类里面的按钮状态
    func setupSelectButton(tag: Int){
        // 通过tag 获取button
        let button = viewWithTag(tag) as! UIButton
        // 判断如果和lastbutton 一样
        if lastButton == button {
            return
        }
        button.isSelected = true
        lastButton?.isSelected = false
        lastButton = button
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 设置视图
    private func setupUI(){
        // 布局方式 - (垂直或者水平)
        axis = .horizontal
        // 填充方式 - 控件评分区域
        distribution = .fillEqually
        
        addChildButtons(imgName: "left", title: "最近", type:.recent)
        addChildButtons(imgName: "mid", title: "默认", type:.normal)
        addChildButtons(imgName: "mid", title: "Emoji", type:.emoji)
        addChildButtons(imgName: "right", title: "小浪花", type:.lxh)
    }
    
    
    // 创建按钮的公共方法
    private func addChildButtons(imgName: String, title: String, type: HEmoticonKeyboardBottomViewType){
        
        let button = UIButton()
        // 设置tag
        button.tag = type.rawValue
        if title == "默认" {
            button.isSelected = true
            // 记录
            lastButton = button
        }
        // 监听事件
        button.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitle(title, for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.setTitleColor(UIColor.darkGray, for: .selected)
        button.setBackgroundImage(UIImage(named:"compose_emotion_table_\(imgName)_normal"), for: .normal)
        button.setBackgroundImage(UIImage(named:"compose_emotion_table_\(imgName)_selected"), for: .selected)
        addArrangedSubview(button)
    }
}

extension HEmoticonKeyboardBottomView{
    
    @objc private func buttonClick(button: UIButton) {
        // 判断如果和lastbutton 一样
        if lastButton == button {
            return
        }
        button.isSelected = true
        lastButton?.isSelected = false
        lastButton = button
        // 执行闭包
        closure?(HEmoticonKeyboardBottomViewType(rawValue: button.tag)!)
    }
}

