//
//  Ext+NSAttributedString.swift
//  WB
//
//  Created by 李贺 on 2020/4/14.
//  Copyright © 2020 Heli. All rights reserved.
//

import UIKit
extension NSAttributedString {
    
    class func emoticonAttributedString(emoticonModel: HEmoticonModel?) -> NSAttributedString{
        // 创建一个文本附件
        let att = HTextAttachment()
        // 赋值
        att.emoticonModel = emoticonModel
        let path = emoticonModel?.path ?? ""
        // 获取bundle文件中图片
        let image = UIImage(named: path, in: HEmoticonTools.shared.emoticonBundle, compatibleWith: nil)
        // 设置image
        att.image = image
        // 得到行号
        let font = UIFont.systemFont(ofSize: 14)
        let lineHeight = font.lineHeight
        // bounds (给image 设置大小)
        att.bounds = CGRect(x: 0, y: -4, width: lineHeight, height: lineHeight)
        // 定义一个不可变的富文本
        let attr = NSAttributedString(attachment: att)
        return attr
    }
}

class HTextAttachment: NSTextAttachment {
    // 模型
    var emoticonModel: HEmoticonModel?
}
