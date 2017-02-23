//
//  ZFPageView.swift
//  ZFPageView
//
//  Created by zhangzhifu on 2017/2/21.
//  Copyright © 2017年 seemygo. All rights reserved.
//

import UIKit

class ZFPageView: UIView {
    // MARK: 属性
    var titles : [String]
    var style : ZFPageStyle
    var childVcs : [UIViewController]
    var parentVc : UIViewController
    
    // MARK: 构造函数
    // 在构造函数调用super.init()之前,必须保证所有的属性有被初始化
    init(frame: CGRect, titles: [String], style: ZFPageStyle, childVcs: [UIViewController], parentVc: UIViewController) {
        self.titles = titles;
        self.style = style;
        self.childVcs = childVcs;
        self.parentVc = parentVc;
        super.init(frame: frame)
        
        setupUI()
    }
    
    // 用required修饰的构造函数
    // 如果子类有重写/自定义其他的构造函数,那么必须重写required修饰的构造函数
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK:- 设置UI界面
extension ZFPageView {
    fileprivate func setupUI() {
        // 1. 创建ZFTitleView
        let titleFrame = CGRect(x: 0, y: 0, width: bounds.width, height: style.titleHeight)
        let titleView = ZFTitleView(frame: titleFrame, titles: titles, style: style)
        titleView.backgroundColor = UIColor.blue
        addSubview(titleView)
        
        // 2. 创建ZFContentView
        let contentFrame = CGRect(x: 0, y: titleFrame.maxY, width: bounds.width, height: bounds.height - style.titleHeight)
        let contentView = ZFContentView(frame: contentFrame, childVcs: childVcs, parentVc: parentVc)
        contentView.backgroundColor = UIColor.red
        addSubview(contentView)
        
        // 3. 让titleView和contentView进行沟通
        titleView.delegate = contentView
        contentView.delegate = titleView
    }
}
