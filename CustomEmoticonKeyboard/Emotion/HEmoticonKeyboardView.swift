//
//  HEmoticonKeyboardView.swift
//  WB
//
//  Created by 李贺 on 2020/4/13.
//  Copyright © 2020 Heli. All rights reserved.
//

import UIKit
import SnapKit

/// 判断是否为刘海屏幕
@available(iOS 11.0, *)
func iPhoneXSeries() -> Bool{
    let insets = UIApplication.shared.windows.first?.safeAreaInsets ?? UIEdgeInsets.zero
    return insets.bottom > CGFloat(0) ? true : false
}

/// 刘海高度
let AdaptNaviHeight = iPhoneXSeries() ? 24 : 0
/// 导航栏高度
let NaviHeight = iPhoneXSeries() ? 88 : 64
/// x 系列标签栏 底部横岗的高度
let AdaptTabHeight = iPhoneXSeries() ? 34 : 0
/// 标签栏高度
let TabBarHeight = iPhoneXSeries() ? 83 : 49

// MARK: 屏幕尺寸相关
let KSCREENBOUNDS = UIScreen.main.bounds
let KSCREENWIDTH = KSCREENBOUNDS.width
let KSCREENHEIGHT = KSCREENBOUNDS.height

class HEmoticonKeyboardView: UIView {
    
    // MARK: 点击过表情, 刷新最近表情的UI
    func reloadRecentData(){
        // 第一组 第一页
        let indexPath = IndexPath(item: 0, section: 0)
        self.pageView.reloadItems(at: [indexPath])
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 设置视图
    private func setupUI(){
        // 设置大小
        self.frame.size = CGSize(width: KSCREENHEIGHT, height: 216 + CGFloat(AdaptTabHeight))
        // 设置背景色
        backgroundColor = UIColor(patternImage: UIImage(named: "emoticon_keyboard_background")!)
        
        // 添加底部控件
        addSubview(bottomView)
        bottomView.snp_makeConstraints { (make) in
            make.left.right.equalTo(self)
            make.height.equalTo(35)
            make.bottom.equalTo(self).offset(-AdaptTabHeight)
        }
        
        // 添加表情集合view
        addSubview(pageView)
        pageView.snp_makeConstraints { (make) in
            make.left.top.right.equalTo(self)
            make.bottom.equalTo(bottomView.snp_top)
        }
        
        // 添加分页控制器
        addSubview(pageControl)
        pageControl.snp_makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.bottom.equalTo(pageView).offset(10)
        }
        
        // MARK: 设置pageView 的默认滚动位置
        // 因为当前滚动的时候pageView 还没有加载完成 所以无法看到效果 需要使用gcd 通过主线程异步才能解决该bug
        DispatchQueue.main.async {
            // 设置pageView 默认滚到第一组
            // indePath
            let indexPath = IndexPath(item: 0, section: 1)
            // pageView 滚动到指定的组
            self.pageView.scrollToItem(at: indexPath, at: .left, animated: false)
            // 设置pageControl
            self.setupPageControl(indexPath: indexPath)
        }
    }
    
    // 懒加载底部视图
    private lazy var bottomView: HEmoticonKeyboardBottomView = {
    
        let view = HEmoticonKeyboardBottomView()
        view.closure = { type in
            switch type {
            case .recent:
                print("最近")
            case .normal:
                print("默认")
            case .emoji:
                print("emoji")
            case .lxh:
                print("浪小花")
            }
            // MARK: - 点击底部视图的按钮, 滚动PageView 到指定组
            // indePath
            let indexPath = IndexPath(item: 0, section: type.rawValue - 100)
            // pageView 滚动到指定的组
            self.pageView.scrollToItem(at: indexPath, at: .left, animated: false)
            // 设置pageControl
            self.setupPageControl(indexPath: indexPath)
        }
        return view
    }()
    
    // 懒加载表情集合view
    private lazy var pageView: HEmoticonPageView = {
        
        let view = HEmoticonPageView()
        view.backgroundColor = self.backgroundColor
        // 设置代理 - 监听滚动
        view.delegate = self
        // 取消弹簧效果
        view.bounces = false
        // 设置分页
        view.isPagingEnabled = true
        // 取消滚动条
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        return view
    }()

    // 懒加载分页指示器
    private lazy var pageControl: UIPageControl = {
        let view = UIPageControl()
        // 设置总页数
        view.numberOfPages = 4
        // 当前页数
        view.currentPage = 1
        // 设置默认图片(使用KVC, 对两个只读属性赋值)
        view.setValue(UIImage(named: "compose_keyboard_dot_normal"), forKey: "pageImage")
        // 这种方式设置图片, 放图图片观察, 图片右侧被挤出来两个尖角, 有两个毛刺
        //        view.pageIndicatorTintColor = UIColor(patternImage: UIImage(named: "compose_keyboard_dot_normal")!)
        // 设置选中图片(KVC)
        view.setValue(UIImage(named: "compose_keyboard_dot_selected"), forKey: "currentPageImage")
        //        view.currentPageIndicatorTintColor = UIColor(patternImage: UIImage(named: "compose_keyboard_dot_selected")!)
        view.isUserInteractionEnabled = false
        // 如果UIPageControl 总页数为1的时候不显示
        view.hidesForSinglePage = true
        return view
    }()
}

// MARK: - UICollectionViewDelegate
extension HEmoticonKeyboardView: UICollectionViewDelegate {
    // 实时监听pageView 滚动
    /*
        - 我们是不是要得到indexPath 的对应的section(0,1,2,3) 通过section 得到对应按钮的tag 得到按钮 设置他的选中状态
        - 必须先要拿到那个indePath显示在屏幕的中间点上
        - 要获取屏幕的中心点
     */
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 获取中心点的x
        let centerX = KSCREENWIDTH/2 + scrollView.contentOffset.x
        // 获取中心点的y
        let centerY = CGFloat((216 - 35)/2)
        // 获取center
        let center = CGPoint(x: centerX, y: centerY)
        // 获取屏幕中心点对应的indexPath
        if let indexPath = self.pageView.indexPathForItem(at: center){
            // 设置选中的按钮状态
            self.bottomView.setupSelectButton(tag: indexPath.section + 100)
            // 设置pageControl
           self.setupPageControl(indexPath: indexPath)
        }
    }
}


extension HEmoticonKeyboardView{
    // 设置pagecntrol 的当前页和总页数
    func setupPageControl(indexPath: IndexPath){
        // 设置pageControl
        self.pageControl.numberOfPages = HEmoticonTools.shared.allEmoticons[indexPath.section].count
        self.pageControl.currentPage = indexPath.item
    }
}

