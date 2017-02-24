//
//  ZFPageCollectionLayout.swift
//  ZFPageView
//
//  Created by zhangzhifu on 2017/2/24.
//  Copyright © 2017年 seemygo. All rights reserved.
//

import UIKit

class ZFPageCollectionLayout: UICollectionViewLayout {
    var sectionInset : UIEdgeInsets = UIEdgeInsets.zero
    var itemMargin : CGFloat = 0
    var lineMargin : CGFloat = 0
    var cols : Int = 4
    var rows : Int = 2

    fileprivate lazy var attributes : [UICollectionViewLayoutAttributes] = [UICollectionViewLayoutAttributes]()
    fileprivate var totalWidth : CGFloat = 0
}


extension ZFPageCollectionLayout {
    override func prepare() {
        super.prepare()
        
        // 0. 对collectionView进行校验
        guard let collectionView = collectionView else {
            return
        }
        
        // 1. 获取collectionView中有多少组数据
        let sections = collectionView.numberOfSections
        
        // 2. 遍历所有的组
        // 2.1 计算itemSize
        let itemW = (collectionView.bounds.width - sectionInset.left - sectionInset.right - itemMargin * CGFloat(cols - 1)) / CGFloat(cols)
        let itemH = (collectionView.bounds.height - sectionInset.top - sectionInset.bottom - lineMargin * CGFloat(rows - 1)) / CGFloat(rows)
        var previousNumOfPage = 0
        for section in 0..<sections {
            // 3. 获取每组中有多少个item
            let items = collectionView.numberOfItems(inSection: section)
            
            // 4. 遍历所有的items
            for item in 0..<items {
                // 5. 根据secion/item创建UICollectionViewLayoutAttribute
                let indexPath = IndexPath(item: item, section: section)
                let attribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                
                // 6. 给attribute中的frame进行赋值
                let currentPage = item / (cols * rows)
                let currentIndex = item % (cols * rows)
                let itemX = CGFloat(previousNumOfPage + currentPage) * collectionView.bounds.width + sectionInset.left + (itemW + itemMargin) * CGFloat(currentIndex % cols)
                let itemY = sectionInset.top + (itemH + lineMargin) * CGFloat(currentIndex / cols)
                attribute.frame = CGRect(x: itemX, y: itemY, width: itemW, height: itemH)
                
                // 7. 将attribute放入数组中
                attributes.append(attribute)
            }
            previousNumOfPage += (items - 1) / (cols * rows) + 1
        }
        
        // 8. 获取totalWidth
        totalWidth = CGFloat(previousNumOfPage) * collectionView.bounds.width
    }
}


extension ZFPageCollectionLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attributes
    }
}


extension ZFPageCollectionLayout {
    override var collectionViewContentSize: CGSize {
        return CGSize(width: totalWidth, height: 0)
    }
}

