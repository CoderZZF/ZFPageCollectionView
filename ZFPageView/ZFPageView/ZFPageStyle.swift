//
//  ZFPageStyle.swift
//  ZFPageView
//
//  Created by zhangzhifu on 2017/2/21.
//  Copyright © 2017年 seemygo. All rights reserved.
//

import UIKit

struct ZFPageStyle {
    
    var titleHeight : CGFloat = 44 // 标题view的高度
    var normalColor: UIColor = UIColor(r: 255, g: 255, b: 255) // 文本普通颜色
    var selectedColor : UIColor = UIColor(r: 255, g: 127, b: 0) // 文本选中颜色
    var titleFont : UIFont = UIFont.systemFont(ofSize: 14) // 文本字体大小
    var isScrollEnabled : Bool = false // 是否能够滚动
    var titleMargin : CGFloat = 20 // 能滚动的情况下,文字的间距
    
    var isShowBottomLine : Bool = true // 是否显示底部的line
    var bottomLineColor : UIColor = UIColor.orange // 底部line的默认颜色
    var bottomLineHeight : CGFloat = 2 // 底部line默认高度
    
    var isNeedScale : Bool = false // 是否需要缩放动画
    var maxScale : CGFloat = 1.2 // 最大缩放比例
    
    var isShowCoverView : Bool = false // 默认不显示
    var coverViewColor : UIColor = UIColor.black // 遮盖的颜色
    var coverViewAlpha : CGFloat = 0.3 // 遮盖的透明度
    var coverViewHeight : CGFloat = 25 // 遮盖的高度
    var coverViewRadius : CGFloat = 12 // 圆角的大小
    var coverViewMargin : CGFloat = 8 // 遮盖的间距
}
