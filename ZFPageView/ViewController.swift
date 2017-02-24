//
//  ViewController.swift
//  ZFPageView
//
//  Created by zhangzhifu on 2017/2/21.
//  Copyright © 2017年 seemygo. All rights reserved.
//

import UIKit

private let kPageCollectionViewCellID = "kPageCollectionViewCellID"

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
        
        // 4. 决定布局样式
        let layout = ZFPageCollectionLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.itemMargin = 5
        layout.lineMargin = 5
        layout.cols = 7
        layout.rows = 3
        
        // 5. 创建PageCollectionView
        let pageCollectionView = ZFPageCollectionView(frame: pageFrame, titles: titles, style: style, layout : layout)
        pageCollectionView.dataSource = self
        pageCollectionView.registerCell(UICollectionViewCell.self, reusableIdentifier: kPageCollectionViewCellID)
        view.addSubview(pageCollectionView)
    }
}



extension ViewController : ZFPageCollectionViewDataSource {
    func numberOfSectionInPageCollectionView(_ pageCollectionView: ZFPageCollectionView) -> Int {
        return 4
    }
    
    func pageCollectionView(_ pageCollectionView: ZFPageCollectionView, numberOfItemInSection section: Int) -> Int {
        if section == 0 {
            return 100
        } else if section == 1 {
            return 18
        } else if section == 2 {
            return 40
        } else {
            return 21
        }
    }
    
    func pageCollectionView(_ pageCollectionView: ZFPageCollectionView, _ collectionView: UICollectionView, cellAtIndexPath indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kPageCollectionViewCellID, for: indexPath)
        cell.backgroundColor = UIColor.randomColor()
        
        return cell
    }
}
