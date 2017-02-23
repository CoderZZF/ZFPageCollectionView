//
//  ZFContentView.swift
//  ZFPageView
//
//  Created by zhangzhifu on 2017/2/21.
//  Copyright © 2017年 seemygo. All rights reserved.
//

import UIKit

private let kContentCellID = "kContentCellID"

protocol ZFContentViewDelegate : class {
    func contentView(_ contentView : ZFContentView, didEndScroll inIndex : Int)
    func contentView(_ contentView : ZFContentView, sourceIndex : Int, targetIndex : Int, progress : CGFloat)
}

class ZFContentView: UIView {
    // MARK: 属性
    weak var delegate : ZFContentViewDelegate?
    fileprivate var childVcs : [UIViewController]
    fileprivate var parentVc : UIViewController
    fileprivate var startOffsetX : CGFloat = 0
    fileprivate var isForbidDelegate : Bool = false
    fileprivate lazy var collectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = self.bounds.size
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        
        
        let collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: kContentCellID)
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = false
        collectionView.scrollsToTop = false
        
        return collectionView
    }()
    
    // MARK: 构造函数
    init(frame: CGRect, childVcs: [UIViewController], parentVc: UIViewController) {
        self.childVcs = childVcs
        self.parentVc = parentVc
        
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK:- 设置UI界面
extension ZFContentView {
    fileprivate func setupUI() {
        // 1. 将childVcs中的所有控制器添加到父控制器
        for childVc in childVcs {
            parentVc.addChildViewController(childVc)
        }
        
        // 2. 给collectionView添加属性
        addSubview(collectionView)
    }
}


// MARK:- 遵守UICollectionViewDataSource
extension ZFContentView: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return childVcs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // 1. 获取cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kContentCellID, for: indexPath)
        
        // 2. 添加内容
        // 2.1 将之前的内容删除掉
        for subview in cell.contentView.subviews {
            subview.removeFromSuperview()
        }
        
        // 2.2 将对应的view添加到cell中
        let childVc = childVcs[indexPath.item]
        cell.contentView.addSubview(childVc.view)
        
        return cell
    }
}

// MARK:- 遵守UICollectionViewDelegate
extension ZFContentView: UICollectionViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDidEndScroll()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollViewDidEndScroll()
        }
    }
    
    private func scrollViewDidEndScroll() {
        let index = Int(collectionView.contentOffset.x / collectionView.bounds.width)
        delegate?.contentView(self, didEndScroll: index)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isForbidDelegate = false
        startOffsetX = scrollView.contentOffset.x
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 0. 判断有没有完成滑动
        let contentOffsetX = scrollView.contentOffset.x
        guard contentOffsetX != startOffsetX  && !isForbidDelegate else {
            return
        }
        
        // 1. 定义出需要获取的变量
        var sourceIndex = 0
        var targetIndex = 0
        var progress : CGFloat = 0
        
        // 2. 获取需要的参数
        let collectionWidth = collectionView.bounds.width
        if contentOffsetX > startOffsetX { // 左划
            sourceIndex = Int(contentOffsetX / collectionWidth)
            targetIndex = sourceIndex + 1
            if targetIndex >= childVcs.count {
                targetIndex = childVcs.count - 1
            }
            progress = (contentOffsetX - startOffsetX) / collectionWidth
            
            if (contentOffsetX - startOffsetX) == collectionWidth {
                targetIndex = sourceIndex
            }
        } else { // 右划
            targetIndex = Int(contentOffsetX / collectionWidth)
            sourceIndex = targetIndex + 1
            progress = (startOffsetX - contentOffsetX) / collectionWidth
        }
        
//        print("sourceIndex:\(sourceIndex) targetIndex:\(targetIndex) progress:\(progress)")
        
        delegate?.contentView(self, sourceIndex: sourceIndex, targetIndex: targetIndex, progress: progress)
    }
}


// MARK:- 遵守ZFTitleViewDelegate协议
extension ZFContentView : ZFTitleViewDelegate {
    func titleView(_ titleView: ZFTitleView, targetIndex: Int) {
        // 0. 禁止执行代理方法
        isForbidDelegate = true
        
        // 1. 根据index创建indexPath
        let indexPath = IndexPath(item: targetIndex, section: 0)
        
        // 2. 滚动到正确的位置
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
    }
}
