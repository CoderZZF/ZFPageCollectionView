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
        
        // 创建ZFPageCollectionView
        // 1. 获取ZFPageCollectionView的frame
        let pageFrame = CGRect(x: 0, y: 100, width: view.bounds.width, height: 300)
        // 2. 获取标题
        let titles = ["热门", "高级", "专属", "豪华"]
        // 3. 获取样式
        var style = ZFPageStyle()
        style.isShowBottomLine = true
        // 4. 创建PageCollectionView
        let pageCollectionView = ZFPageCollectionView(frame: pageFrame, titles: titles, style: style, isTitleInTop: true)
        view.addSubview(pageCollectionView)
    }
}

