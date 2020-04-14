//
//  HEmoticonPageViewCell.swift
//  WB
//
//  Created by 李贺 on 2020/4/14.
//  Copyright © 2020 Heli. All rights reserved.
//

import UIKit

// 表情按钮点击通知
let EMOTICONBUTTONCLICKNOTI = "EMOTICONBUTTONCLICKNOTI"
// 删除按钮点击通知
let EMOTICONDELETEBUTTONCLICKNOTI = "EMOTICONDELETEBUTTONCLICKNOTI"

class HEmoticonPageViewCell: UICollectionViewCell {
    
    // indexPath - 点击cell 测试调用, 便于更好的理解.
    var indexPath: IndexPath?{
        didSet{
            print("第\(indexPath?.section ?? 0)组\n第\(indexPath?.item ?? 0)页")
        }
    }
    
    // 定义一个属性供外界赋值 (每一页通过一个一维数组完成赋值)
    var emoticons: [HEmoticonModel]? {
        didSet{
            // 把20个按钮全部隐藏
            for button in emoticonButtonArray {
                button.isHidden = true
            }

            // 遍历模型数组(0,7)
            for (i, emoticonModel) in emoticons!.enumerated(){
                // 获取button
                let button = emoticonButtonArray[i]
                // 赋值操作
                button.emoticonModel = emoticonModel
                // 显示button
                button.isHidden = false
                // 给button赋值
                // 判断是emoji
                if emoticonModel.isEmoji {
                    let code = ((emoticonModel.code ?? "") as NSString).emoji()
                    // 设置title
                    button.setTitle(code, for: .normal)
                    // imaeg 设置为nil
                    button.setImage(nil, for: .normal)
                } else {
                    
                    let path = emoticonModel.path ?? ""
                    // 获取bundle文件中图片
                    let image = UIImage(named: path, in: HEmoticonTools.shared.emoticonBundle, compatibleWith: nil)
                    // 图片表情
                    button.setImage(image, for: .normal)
                    // title 设置为nil
                    button.setTitle(nil, for: .normal)
                }
            }
        }
    }
    
    // 定义一个数组保存按钮
    var emoticonButtonArray: [HEmoticonButton] = [HEmoticonButton]()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addChildButtons()
        addSubview(deleteButton)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // MARK: - 设置添加20个表情按钮frame
        // 计算按钮的宽和高
        // 左右间距各位 5
        let buttonW = (KSCREENWIDTH - 10) / CGFloat(HEMOTICONMAXCOL)
        // pageControl 高度为20
        let buttonH = (216 - 35 - 20) / CGFloat(HEMOTICONMAXROW)
        // 设置frame
        // 遍历按钮数组
        for (i,button) in emoticonButtonArray.enumerated() {
            // 列索引
            let colIndex = CGFloat(i%HEMOTICONMAXCOL)
            // 行索引
            let rowIndex = CGFloat(i/HEMOTICONMAXCOL)
            // 设置frame
            button.frame = CGRect(x: 5 + colIndex*buttonW, y: rowIndex*buttonH, width: buttonW, height: buttonH)
        }
        
        // MARK: - 设置删除按钮的frame
        deleteButton.frame = CGRect(x: KSCREENWIDTH - buttonW - 5, y: buttonH*2, width: buttonW, height: buttonH)
    }
    
    // 循环添加20个表情按钮
    private func addChildButtons(){
        // 循环20次
        for _ in 0..<HEMOTICONMAXCOUNT {
            // 创建按钮
            let button =  HEmoticonButton()
            // 监听事件
            button.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
            // 设置字体
            button.titleLabel?.font = UIFont.systemFont(ofSize: 30)
            // 添加到数组中
            emoticonButtonArray.append(button)
            // 添加
            contentView.addSubview(button)
        }
    }
    
    // 键盘上删除按钮
    private lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(deleteButtonClick), for: .touchUpInside)
        button.setImage(UIImage(named:"compose_emotion_delete"), for: .normal)
        button.setImage(UIImage(named:"compose_emotion_delete_highlighted"), for: .highlighted)
        return button
    }()
}

extension HEmoticonPageViewCell {

    // 表情点击事件
    @objc private func buttonClick(button: HEmoticonButton) {
        // 发送通知 -> 传出按钮对应的模型
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: EMOTICONBUTTONCLICKNOTI), object: button.emoticonModel)
    }
    
    // 删除按钮点击事件
    @objc private func deleteButtonClick(){
        // 发送通知 -> 删除操作
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: EMOTICONDELETEBUTTONCLICKNOTI), object: nil)
    }
}
