//
//  ViewController.swift
//  ZFPageView
//
//  Created by zhangzhifu on 2017/2/21.
//  Copyright © 2017年 seemygo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        automaticallyAdjustsScrollViewInsets = false
        
        // 创建ZFPageView
        // 1. 获取pageView的frame
        let pageFrame = CGRect(x: 0, y: 64, width: view.bounds.width, height: view.bounds.height - 64)
        
        // 2. 获取pageView显示的标题
        let titles = ["推荐", "游戏", "娱乐", "趣玩"];
//        let titles = ["推荐", "游戏游戏游戏", "娱游戏乐", "趣玩游戏游戏游戏游戏游戏", "推荐", "游戏", "娱乐", "趣玩", "推荐", "游戏", "娱乐", "趣玩"];
        
        // 3. 获取pageView中所有的内容控制器
        var childVcs = [UIViewController]()
        for _ in 0..<titles.count {
            let vc = UIViewController()
            // 十六进制: ## # 0x 0X
            vc.view.backgroundColor = UIColor.randomColor()
            childVcs.append(vc)
        }
        
        // 4. 样式
        var style = ZFPageStyle()
        style.isShowBottomLine = false
        style.isShowCoverView = true
//        style.isScrollEnabled = true
//        style.isNeedScale = true
        
        // 5. 创建pageView
        let pageView = ZFPageView(frame: pageFrame, titles: titles, style: style, childVcs: childVcs, parentVc: self)
        view.addSubview(pageView)
    }
}

