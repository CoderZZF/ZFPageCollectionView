//
//  ZFPageCollectionView.swift
//  ZFPageView
//
//  Created by zhangzhifu on 2017/2/24.
//  Copyright © 2017年 seemygo. All rights reserved.
//

import UIKit

protocol ZFPageCollectionViewDataSource : class {
    // 有多少组
    func numberOfSectionInPageCollectionView(_ pageCollectionView : ZFPageCollectionView) -> Int
    
    // 每组里面有多少个数据
    func pageCollectionView(_ pageCollectionView : ZFPageCollectionView, numberOfItemInSection section : Int) -> Int
    
    // 每一个cell长什么样子
    func pageCollectionView(_ pageCollectionView : ZFPageCollectionView, _ collectionView : UICollectionView, cellAtIndexPath indexPath : IndexPath) -> UICollectionViewCell
}

class ZFPageCollectionView: UIView {
    
    weak var dataSource : ZFPageCollectionViewDataSource?
    
    fileprivate var titles : [String]
    fileprivate var style : ZFPageStyle
    fileprivate var layout : ZFPageCollectionLayout
    
    fileprivate lazy var currentIndexPath : IndexPath = IndexPath(item: 0, section: 0)
    
    fileprivate var collectionView : UICollectionView!
    fileprivate var pageControl : UIPageControl!
    fileprivate var titleView : ZFTitleView!
    
    init(frame: CGRect, titles : [String], style : ZFPageStyle, layout : ZFPageCollectionLayout) {
        self.titles = titles
        self.layout = layout
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
        let titleY = style.isTitleInTop ? 0 : bounds.height - style.titleHeight
        let titleFrame = CGRect(x: 0, y: titleY, width: bounds.width, height: style.titleHeight)
        let titleView = ZFTitleView(frame: titleFrame, titles: titles, style: style)
        titleView.delegate = self
        titleView.backgroundColor = UIColor.randomColor()
        self.titleView = titleView
        addSubview(titleView)
        
        // 2. UICollectionView
        let collectionY = style.isTitleInTop ? style.titleHeight : 0
        let collectionH = bounds.height - style.titleHeight - style.pageControlHeight
        let collectionFrame = CGRect(x: 0, y: collectionY, width: bounds.width, height: collectionH)
        let collectionView = UICollectionView(frame: collectionFrame, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.randomColor()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        addSubview(collectionView)
        self.collectionView = collectionView
        
        // 3. UIPageControl
        let pageFrame = CGRect(x: 0, y: collectionView.frame.maxY, width: bounds.width, height: style.pageControlHeight)
        let pageControl = UIPageControl(frame: pageFrame)
        pageControl.numberOfPages = 4
        pageControl.backgroundColor = UIColor.randomColor()
        self.pageControl = pageControl
        addSubview(pageControl)
    }
}


extension ZFPageCollectionView {
    func registerCell(_ cell : AnyClass?, reusableIdentifier : String) {
        collectionView.register(cell, forCellWithReuseIdentifier: reusableIdentifier)
    }
    
    func registerNib(_ nib : UINib?, reusableIdentifier : String) {
        collectionView.register(nib, forCellWithReuseIdentifier: reusableIdentifier)
    }
    
    func reloadData() {
        collectionView.reloadData()
    }
}

extension ZFPageCollectionView : UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource?.numberOfSectionInPageCollectionView(self) ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionItemCount = dataSource?.pageCollectionView(self, numberOfItemInSection: section) ?? 0
        if section == 0 {
            pageControl.numberOfPages = (sectionItemCount - 1) / (layout.cols * layout.rows) + 1
        }
        return sectionItemCount
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        return (dataSource?.pageCollectionView(self, collectionView, cellAtIndexPath: indexPath))!
    }
}


extension ZFPageCollectionView : UICollectionViewDelegate {
    // 有减速的停止
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewEndScroll()
    }
    // 没有减速,只是拖拽停止
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollViewEndScroll()
        }
    }
    
    private func scrollViewEndScroll() {
        // 1. 获取滚动位置对应的indexPath
        let point = CGPoint(x: layout.sectionInset.left + 1 + collectionView.contentOffset.x, y: layout.sectionInset.top + 1)
        guard let indexPath = collectionView.indexPathForItem(at: point) else { return }
        
        // 2. 判断是否需要改变组
        if indexPath.section != currentIndexPath.section {
            // 2.1 改变pageControl
            let itemsCount = dataSource?.pageCollectionView(self, numberOfItemInSection: indexPath.section) ?? 0
            pageControl.numberOfPages = (itemsCount - 1) / (layout.cols * layout.rows) + 1
          
            // 2.2 改变titleView的变化
            titleView.setCurrentIndex(indexPath.section)
            
            // 2.3 记录最新的indexPath
            currentIndexPath = indexPath
        }
        pageControl.currentPage = indexPath.item / (layout.cols * layout.rows)
    }
}

extension ZFPageCollectionView : ZFTitleViewDelegate {
    func titleView(_ titleView: ZFTitleView, targetIndex: Int) {
        // 1. 根据targetIndex创建对应组的indexPath
        let indexPath = IndexPath(item: 0, section: targetIndex)
        
        // 2. 滚动到正确的位置
        collectionView.scrollToItem(at: indexPath, at: .left, animated: false)
        
        // 3. 设置pageControl的个数
        let sectionNum = dataSource?.numberOfSectionInPageCollectionView(self) ?? 0
        let sectionItemNum = dataSource?.pageCollectionView(self, numberOfItemInSection: targetIndex) ?? 0
        pageControl.numberOfPages = (sectionItemNum - 1) / (layout.rows * layout.cols) + 1
        pageControl.currentPage = 0
        // (count - 1) / pageCount + 1 -> 知道总个数,求出页数
        // index / pageCount -> 知道下标值,求出该下标值在第几页
        
        // 4. 设置最新的indexPath
        currentIndexPath = indexPath
        
        // 5. 调整正确的位置
        if targetIndex == sectionNum - 1 && sectionItemNum <= layout.cols * layout.rows {
            return
        }
        collectionView.contentOffset.x -= layout.sectionInset.left
    }
}
