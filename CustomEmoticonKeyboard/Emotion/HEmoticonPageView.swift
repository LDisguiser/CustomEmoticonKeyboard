//
//  HEmoticonPageView.swift
//  WB
//
//  Created by 李贺 on 2020/4/14.
//  Copyright © 2020 Heli. All rights reserved.
//

import UIKit

/* 自定义表情键盘
 
 - 表情数据结果分析
    - 分为几种表情(4种)
        - 最近 (1页表情, 20个)
            - [20]
        - 默认 (6页表情, 108个)
            - [20] [20] [20] [20] [20] [8]
        - emoji (4页表情, 80个)
            - [20] [20] [20] [20]
        - lxh (2页表情, 40个)
            - [20] [20]
 
    - 分析collectionView 怎么显示
        - 最近
            - 1 页
        - 默认
            - 6 页
        - emoji
            - 4 页
        - lxh
            - 2 页
    ? - 怎么确定collectionView 的组数?
        - [[[20]], [[20] [20] [20] [20] [20] [8]], [[20] [20] [20] [20]], [[20] [20]]].count = 4组.
        - 也就是section 数量 = 三维数组.count
        - 每一个section 的item 数量 = 三维数组[单个元素].count(也就是 二维数组.count).
        - 而每一个item 上有20 个表情控件.
 */

// cell 可重用标识符
private let pageViewCellId = "pageViewCell_Id"

class HEmoticonPageView: UICollectionView {

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        
        let flowLayout = UICollectionViewFlowLayout()
        // 设置itemSize
        flowLayout.itemSize = CGSize(width: KSCREENWIDTH, height: 216 - 35)
        // 设置滚动方向
        flowLayout.scrollDirection = .horizontal
        // 设置间距
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        super.init(frame: frame, collectionViewLayout: flowLayout)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK:- 设置视图
    private func setupUI(){
        // 设置代理
        dataSource = self
        // 注册cell
        register(HEmoticonPageViewCell.classForCoder(), forCellWithReuseIdentifier: pageViewCellId)
    }
}

// MARK: - UICollectionViewDataSource
extension HEmoticonPageView: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return HEmoticonTools.shared.allEmoticons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return HEmoticonTools.shared.allEmoticons[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: pageViewCellId, for: indexPath) as! HEmoticonPageViewCell
        cell.indexPath = indexPath // 测试使用
        // 赋值
        cell.emoticons = HEmoticonTools.shared.allEmoticons[indexPath.section][indexPath.item]
        return cell
    }
}
