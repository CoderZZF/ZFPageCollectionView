//
//  ZFPageCollectionView.swift
//  ZFPageView
//
//  Created by zhangzhifu on 2017/2/24.
//  Copyright © 2017年 seemygo. All rights reserved.
//

import UIKit

private let kPageCollectionViewCellID = "kPageCollectionViewCellID"

protocol ZFPageCollectionViewDataSource : class {
    // 有多少组
    func numberOfSectionInPageCollectionView(_ pageCollectionView : ZFPageCollectionView) -> Int
    
    // 每组里面有多少个数据
    func pageCollectionView(_ pageCollectionView : ZFPageCollectionView, numberOfItemInSection section : Int) -> Int
    
    // 每一个cell长什么样子
    func pageCollectionView(_ pageCollectionView : ZFPageCollectionView, cellAtIndexPath indexPath : IndexPath) -> UICollectionViewCell
}

class ZFPageCollectionView: UIView {
    
    weak var dataSource : ZFPageCollectionViewDataSource?
    
    fileprivate var titles : [String]
    fileprivate var isTitleInTop : Bool
    fileprivate var style : ZFPageStyle
    
    init(frame: CGRect, titles : [String], style : ZFPageStyle, isTitleInTop : Bool) {
        self.titles = titles
        self.isTitleInTop = isTitleInTop
        self.style = style
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension ZFPageCollectionView {
    fileprivate func setupUI() {
        // 1. titleView
        let titleY = isTitleInTop ? 0 : bounds.height - style.titleHeight
        let titleFrame = CGRect(x: 0, y: titleY, width: bounds.width, height: style.titleHeight)
        let titleView = ZFTitleView(frame: titleFrame, titles: titles, style: style)
        titleView.backgroundColor = UIColor.randomColor()
        addSubview(titleView)
        
        // 2. UICollectionView
        let layout = ZFPageCollectionLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.itemMargin = 5
        layout.lineMargin = 5
        
        let collectionY = isTitleInTop ? style.titleHeight : 0
        let collectionH = bounds.height - style.titleHeight - style.pageControlHeight
        let collectionFrame = CGRect(x: 0, y: collectionY, width: bounds.width, height: collectionH)
        let collectionView = UICollectionView(frame: collectionFrame, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.randomColor()
        collectionView.dataSource = self
//        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: kPageCollectionViewCellID)
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        addSubview(collectionView)
        
        // 3. UIPageControl
        let pageFrame = CGRect(x: 0, y: collectionView.frame.maxY, width: bounds.width, height: style.pageControlHeight)
        let pageControl = UIPageControl(frame: pageFrame)
        pageControl.numberOfPages = 4
        pageControl.backgroundColor = UIColor.randomColor()
        addSubview(pageControl)
    }
}


extension ZFPageCollectionView : UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource?.numberOfSectionInPageCollectionView(self) ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.pageCollectionView(self, numberOfItemInSection: section) ?? 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        return (dataSource?.pageCollectionView(self, cellAtIndexPath: indexPath))!
    }
    
    
}
