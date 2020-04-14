//
//  HEmoticonModel.swift
//  WB
//
//  Created by 李贺 on 2020/4/14.
//  Copyright © 2020 Heli. All rights reserved.
//

import UIKit
@objcMembers
class HEmoticonModel: NSObject, NSCoding, NSSecureCoding {
    static var supportsSecureCoding: Bool {
        return true
    }
    
    // 从object 解析回来
    required init?(coder: NSCoder) {
        super.init()
        code = coder.decodeObject(forKey: "code") as? String ?? ""
        chs = coder.decodeObject(forKey: "chs") as? String ?? ""
        png = coder.decodeObject(forKey: "png") as? String ?? ""
        path = coder.decodeObject(forKey: "path") as? String ?? ""
        isEmoji = coder.decodeObject(forKey: "isEmoji") as? Bool ?? false
    }
    
    // 编码成object
    func encode(with coder: NSCoder) {
        coder.encode(code, forKey: "code")
        coder.encode(chs, forKey: "chs")
        coder.encode(png, forKey: "png")
        coder.encode(path, forKey: "path")
        coder.encode(isEmoji, forKey: "isEmoji")
    }
    
    // emoji表情需要的, 十六进制字符串
    var code: String?
    
    // 图片表情需要的, 图片描述
    var chs: String?
    // 图片名
    var png: String?
    
    // 类型(1是emoji表情 0 是图片表情)
    var type: String?{
        didSet{
            isEmoji = (type == "1")
        }
    }
    
    // 是否是emoji表情
    var isEmoji: Bool = false
    // 全路径
    var path: String?
    
    init(dict: [String: Any]) {
        super.init()
        setValuesForKeys(dict)
    }
    
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
        
    }
}
