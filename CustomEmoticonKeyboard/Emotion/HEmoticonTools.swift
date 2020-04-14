//
//  HEmoticonTools.swift
//  WB
//
//  Created by 李贺 on 2020/4/14.
//  Copyright © 2020 Heli. All rights reserved.
//

import UIKit

// 最大列数
let HEMOTICONMAXCOL = 7
// 最大行数
let HEMOTICONMAXROW = 3
// 每一页显示最多的表情个数
let HEMOTICONMAXCOUNT = HEMOTICONMAXCOL*HEMOTICONMAXROW - 1

class HEmoticonTools: NSObject {
    // 单例 : 避免外界重复多次的访问沙盒资源
    static let shared: HEmoticonTools = HEmoticonTools()
    
    // 最近表情存储在沙盒的路径
    let file = (NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last! as NSString).appendingPathComponent("recent.archiver")
    
    // 表情bundle
    lazy var emoticonBundle:Bundle = {
        // 路径
        let path = Bundle.main.path(forResource: "Emoticons.bundle", ofType: nil)!
        // 获取bundle
        let bundle = Bundle(path: path)!
        return bundle
    }()
    
    // 最近表情一维数组 最多就是20个
    lazy var recentEmoticons: [HEmoticonModel] = {
        return self.getRecentEmoticons()
    }()
    // 默认表情一维数组
    lazy var normalEmoticons: [HEmoticonModel] = {
        return self.loadSingledimensionalEmoticonsArray(name: "default")
    }()
    // emoji表情一维数组
    lazy var emojiEmoticons: [HEmoticonModel] = {
        return self.loadSingledimensionalEmoticonsArray(name: "emoji")
    }()
    // 浪小花表情一维数组
    lazy var lxhEmoticons: [HEmoticonModel] = {
        return self.loadSingledimensionalEmoticonsArray(name: "lxh")
    }()
    
    // 三维数组
    lazy var allEmoticons: [[[HEmoticonModel]]] = {
        return [
            [self.recentEmoticons],
            self.loadTwoDimensionalEmoticonsArray(emoticons: self.normalEmoticons),
            self.loadTwoDimensionalEmoticonsArray(emoticons: self.emojiEmoticons),
            self.loadTwoDimensionalEmoticonsArray(emoticons: self.lxhEmoticons)
        ]
    }()
}

// MARK: 不同表情包的资源文件转模型
extension HEmoticonTools{
    
    // 通过该方法分别获取不同的表情包的 一维数组
    func loadSingledimensionalEmoticonsArray(name: String) -> [HEmoticonModel]{
        // 路径
        let file = emoticonBundle.path(forResource: "\(name)/info.plist", ofType: nil)!
        // plist 数组
        let plistArray = NSArray(contentsOfFile: file)!
        // 创建临时可变字典
        var tempArray: [HEmoticonModel] = [HEmoticonModel]()
        // 字典转模型
        for dict in plistArray {
            let model = HEmoticonModel(dict: dict as! [String : Any])
            // 给path 赋值
            model.path = "\(name)" + "/" + "\(model.png ?? "")"
            tempArray.append(model)
        }
        return tempArray
    }
    
    // 通过该方法把一维数组转成 二维数组
    func loadTwoDimensionalEmoticonsArray(emoticons: [HEmoticonModel]) -> [[HEmoticonModel]]{
        
        // 得到一维数组将要在表情键盘显示的页数
        let pageCount = (emoticons.count + HEMOTICONMAXCOUNT - 1)/HEMOTICONMAXCOUNT
        
        // 创建一个二维数组可变的 空数组
        var groupArray: [[HEmoticonModel]] = [[HEmoticonModel]]()
        
        for i in 0..<pageCount{
            // 位置: 截取子数组的起始页数, 与HEMOTICONMAXCOUNT 做积, 代表从一位数组的那个位置开始截取
            let loc = i * HEMOTICONMAXCOUNT
            // 长度: 将要截取的子数组的长度
            var len = HEMOTICONMAXCOUNT
            // 反之越界
            if len + loc > emoticons.count {
                len = emoticons.count - loc
            }
            // 范围
            let range = NSRange(location: loc, length: len)
            // 截取数组 -> NSArray 的方法, 通过起始位置和每次截取的数量, 来获取子数组
            let tempArray = (emoticons as NSArray).subarray(with: range) as! [HEmoticonModel]
            // 添加到二维数组中
            groupArray.append(tempArray)
        }
        // 返回
        return groupArray
    }
}

// MARK: 最近表情相关
extension HEmoticonTools {
    
    // 保存表情模型 -> 为 最近表情 提供数据
    func saveRecentModel(emoticonModel: HEmoticonModel){
        
        // 遍历当前的最近表情的数组 -> 去重 -> 有一样的先移除, 然后添加到最后
        for (i, model) in recentEmoticons.enumerated() {
            // 判断你的类型 emoji 还是 图片
            if model.isEmoji {
                // emoji
                if model.code == emoticonModel.code {
                    recentEmoticons.remove(at: i)
                }
            }else {
                //图标表情
                if model.png == emoticonModel.png {
                    recentEmoticons.remove(at: i)
                }
            }
        }
        
        // 添加到最近表情数组中
        recentEmoticons.insert(emoticonModel, at: 0)
        // 判断如果超过20个 干掉最后一个
        if recentEmoticons.count > 20 {
            recentEmoticons.removeLast()
        }
        
        // 三维数组中的最近表情的数组进行更改
        allEmoticons[0][0] = recentEmoticons
        
        // 保存到沙盒中
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: recentEmoticons, requiringSecureCoding: false)
            do {
                _ = try data.write(to: URL(fileURLWithPath: file))
                print("最近表情写入成功")
            } catch {
                print("最近表情写入本地失败: \(error)")
            }
        } catch {
            
        }
    }
    
    // 从沙盒中获取是否有没有最近表情的数组
    func getRecentEmoticons() -> [HEmoticonModel]{

        do {
            let data = try Data.init(contentsOf: URL(fileURLWithPath: file))
            do {
                let emoticons: [HEmoticonModel] = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as!
                    [HEmoticonModel]
                return emoticons
            } catch {
                return [HEmoticonModel]()
            }
        } catch {
            return [HEmoticonModel]()
        }
    }
}
