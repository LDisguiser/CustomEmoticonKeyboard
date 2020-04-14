//
//  SwitchView.swift
//  CustomEmoticonKeyboard
//
//  Created by 李贺 on 2020/4/14.
//  Copyright © 2020 Heli. All rights reserved.
//

import UIKit

class SwitchView: UIView {

    var closure:(()->())?
    
    var emoticonButton: UIButton?
    
    // 提供一个属性判断是表情键盘还是系统键盘, 切换显示图片
    var isEmoticon: Bool = false{
        didSet{
            
            var imgName = ""
            // 如果是自定义表情键盘
            if isEmoticon {
                // 图片改成的是键盘的图片
                imgName = "compose_keyboardbutton_background"
                
            }else {
                // 如果是系统键盘
                // 图片改成的是笑脸图片
                imgName = "compose_emoticonbutton_background"
            }
            
            emoticonButton?.setImage(UIImage(named:imgName), for: .normal)
            emoticonButton?.setImage(UIImage(named:"\(imgName)_highlighted"), for: .highlighted)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(red: 248.0/255.0, green: 248.0/255.0, blue: 248.0/255.0, alpha: 1.0)
        
        let button = UIButton()
        button.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
        button.setImage(UIImage(named:"compose_emoticonbutton_background"), for: .normal)
        button.setImage(UIImage(named:"compose_emoticonbutton_background_highlighted"), for: .highlighted)
        addSubview(button)
        emoticonButton = button
        
        button.snp_makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.top.equalTo(self)
            make.width.equalTo(40)
            make.height.equalTo(40)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func buttonClick() {
        closure?()
    }
}
