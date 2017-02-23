//
//  ZFTitleView.swift
//  ZFPageView
//
//  Created by zhangzhifu on 2017/2/21.
//  Copyright © 2017年 seemygo. All rights reserved.
//

import UIKit

// 表示该协议只能被类遵守
protocol ZFTitleViewDelegate : class {
    func titleView(_ titleView : ZFTitleView, targetIndex : Int)
}

class ZFTitleView: UIView {
    // MARK: 属性
    weak var delegate : ZFTitleViewDelegate?
    fileprivate var titles : [String]
    fileprivate var style : ZFPageStyle
    fileprivate lazy var titleLabels : [UILabel] = [UILabel]()
    fileprivate var currentIndex : Int = 0
    fileprivate lazy var normalRGB : (CGFloat, CGFloat, CGFloat) = self.style.normalColor.getRGBValue()
    fileprivate lazy var selectedRGB : (CGFloat, CGFloat, CGFloat) = self.style.selectedColor.getRGBValue()
    fileprivate lazy var deltaRGB : (CGFloat, CGFloat, CGFloat) = {
        let deltaR = self.selectedRGB.0 - self.normalRGB.0
        let deltaG = self.selectedRGB.1 - self.normalRGB.1
        let deltaB = self.selectedRGB.2 - self.normalRGB.2
        return(deltaR, deltaG, deltaB)
    }()
    
    fileprivate lazy var scrollView : UIScrollView = {
        let scrollView = UIScrollView(frame: self.bounds)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.scrollsToTop = false
        
        return scrollView
    }()
    fileprivate lazy var bottomLine : UIView = {
        let bottomLine = UIView()
        bottomLine.backgroundColor = self.style.bottomLineColor
        return bottomLine
    }()
    fileprivate lazy var coverView : UIView = {
        let coverView = UIView()
        coverView.backgroundColor = self.style.coverViewColor
        coverView.alpha = self.style.coverViewAlpha
        return coverView
    }()
    
    
    // MARK: 构造函数
    init(frame: CGRect, titles: [String], style: ZFPageStyle) {
        self.titles = titles
        self.style = style
        
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK:- 设置UI界面
extension ZFTitleView {
    fileprivate func setupUI() {
        // 1. 添加UIScrollView
        addSubview(scrollView)
        
        // 2. 初始化所有的labels
        setupTitleLabels()
        
        // 3. 初始化底部的line
        if style.isShowBottomLine {
            setupBottomLine()
        }
        
        // 4. 初始化遮盖的View
        if style.isShowCoverView {
            setupCoverView()
        }
    }
    
    private func setupCoverView() {
        scrollView.insertSubview(coverView, at: 0)
        
        guard let firstLabel = titleLabels.first else { return }
        var coverW : CGFloat = firstLabel.frame.width
        let coverH : CGFloat = style.coverViewHeight
        var coverX : CGFloat = firstLabel.frame.origin.x
        let coverY : CGFloat = (firstLabel.frame.height - coverH) * 0.5
        
        if style.isScrollEnabled {
            coverX -= style.coverViewMargin
            coverW += style.coverViewMargin * 2
        }
        coverView.frame = CGRect(x: coverX, y: coverY, width: coverW, height: coverH)
        
        coverView.layer.cornerRadius = style.coverViewRadius
        coverView.layer.masksToBounds = true
    }
    
    
    private func setupBottomLine() {
        scrollView.addSubview(bottomLine)
        bottomLine.frame = titleLabels.first!.frame
        bottomLine.frame.size.height = style.bottomLineHeight
        bottomLine.frame.origin.y = style.titleHeight - style.bottomLineHeight
    }
    
    private func setupTitleLabels() {
        // 1. 创建labels
        for (i, title) in titles.enumerated() {
            // 1. 创建UIlabel
            let titleLabel = UILabel()
            
            // 2. 设置label的属性
            titleLabel.text = title
            titleLabel.tag = i
            titleLabel.textAlignment = .center
            titleLabel.textColor = i == 0 ? style.selectedColor : style.normalColor
            titleLabel.font = style.titleFont
            titleLabel.isUserInteractionEnabled = true
            
            // 3. 将label添加到scrollView
            scrollView.addSubview(titleLabel)
            
            // 4. 监听label的点击
            // #selector(方法名称)
            let tapGes = UITapGestureRecognizer(target: self, action: #selector(titleLabelClick(_:)))
            titleLabel.addGestureRecognizer(tapGes)
            
            // 5. 将label添加到数组中
            titleLabels.append(titleLabel)
        }
        
        // 2. 设置label的frame
        let labelH : CGFloat = style.titleHeight
        let labelY : CGFloat = 0
        var labelW : CGFloat = bounds.width / CGFloat(titles.count)
        var labelX : CGFloat = 0
        for (i, titleLabel) in titleLabels.enumerated() {
            if style.isScrollEnabled {
                labelW = (titleLabel.text! as NSString).boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: 0), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName : style.titleFont], context: nil).width
                labelX = i == 0 ? style.titleMargin * 0.5 : (titleLabels[i-1].frame.maxX + style.titleMargin)
            } else {
                labelX = labelW * CGFloat(i)
            }
            titleLabel.frame = CGRect(x: labelX, y: labelY, width: labelW, height: labelH)
        }
        
        // 4. 设置contentSize
        if style.isScrollEnabled {
            scrollView.contentSize = CGSize(width: titleLabels.last!.frame.maxX + style.titleMargin * 0.5, height: 0)
        }
        
        // 5. 设置缩放
        if style.isNeedScale {
            titleLabels.first?.transform = CGAffineTransform(scaleX: style.maxScale, y: style.maxScale)
        }
    }
}

// MARK:- 点击事件监听
extension ZFTitleView {
    // ?. 可选链
    func titleLabelClick(_ tapGes: UITapGestureRecognizer) {
        // 0. 校验label是否有值
        guard let targetLabel = tapGes.view as? UILabel else {
            return
        }
        
        // 1. 判断是否是之前点击的label
        guard targetLabel.tag != currentIndex else {
            return
        }
        
        // 2. 让之前的label不选中,让新的label选中
        let sourceLabel = titleLabels[currentIndex]
        sourceLabel.textColor = style.normalColor
        targetLabel.textColor = style.selectedColor
        
        // 3. 让新的tag作为currentIndex
        currentIndex = targetLabel.tag
        
        // 4. 调整点击label的位置,滚动到中间去
        adjustLabelPosition()
        
        // 5. 通知代理
        // 可选连: 如果可选类型有值,则执行代码,如果没有值,什么事情都不会发生
        delegate?.titleView(self, targetIndex: currentIndex)
        
        // 6. 调整文字的缩放
        if style.isNeedScale {
            UIView.animate(withDuration: 0.25, animations: {
                sourceLabel.transform = CGAffineTransform.identity
                targetLabel.transform = CGAffineTransform(scaleX: self.style.maxScale, y: self.style.maxScale)
            })
        }
        
        // 7. 调整bottomLine的位置
        if style.isShowBottomLine {
            UIView.animate(withDuration: 0.25, animations: {
                self.bottomLine.frame.origin.x = targetLabel.frame.origin.x
                self.bottomLine.frame.size.width = targetLabel.frame.width
            })
        }
        
        // 8. 调整coverView的位置
        if style.isShowCoverView {
            UIView.animate(withDuration: 0.25, animations: {
                self.coverView.frame.origin.x = self.style.isScrollEnabled ? targetLabel.frame.origin.x - self.style.coverViewMargin : targetLabel.frame.origin.x
                self.coverView.frame.size.width = self.style.isScrollEnabled ? (targetLabel.frame.width + self.style.coverViewMargin * 2) : targetLabel.frame.width
            })
        }
    }
    
    fileprivate func adjustLabelPosition() {
        guard style.isScrollEnabled else { return }
        
        let targetLabel = titleLabels[currentIndex]
        var offsetX = targetLabel.center.x - scrollView.bounds.width * 0.5
        
        if offsetX < 0 {
            offsetX = 0
        }
        let maxOffsetX = scrollView.contentSize.width - scrollView.bounds.width
        if offsetX > maxOffsetX {
            offsetX = maxOffsetX
        }
        
        scrollView.setContentOffset(CGPoint(x:offsetX, y: 0), animated: true)
    }
}


extension ZFTitleView : ZFContentViewDelegate {
    func contentView(_ contentView: ZFContentView, didEndScroll inIndex: Int) {
        currentIndex = inIndex
        
        adjustLabelPosition()
    }
    
    func contentView(_ contentView: ZFContentView, sourceIndex: Int, targetIndex: Int, progress: CGFloat) {
        // 1. 根据sourceIndex/targetIndex获取对应的label
        let sourceLabel = titleLabels[sourceIndex]
        let targetLabel = titleLabels[targetIndex]
        
        // 2. 颜色渐变
        sourceLabel.textColor = UIColor(r: selectedRGB.0 - deltaRGB.0 * progress, g: selectedRGB.1 - deltaRGB.1 * progress, b: selectedRGB.2 - deltaRGB.2 * progress)
        targetLabel.textColor = UIColor(r: normalRGB.0 + deltaRGB.0 * progress, g: normalRGB.1 + deltaRGB.1 * progress, b: normalRGB.2 + deltaRGB.2 * progress)
        
        // 3. 缩放的变化
        if style.isNeedScale {
            let deltaScale = style.maxScale - 1.0
            sourceLabel.transform = CGAffineTransform(scaleX: style.maxScale - deltaScale * progress, y: style.maxScale - deltaScale * progress)
            targetLabel.transform = CGAffineTransform(scaleX: 1.0 + deltaScale * progress, y: 1.0 + deltaScale * progress)
        }
        
        // 4. 计算bottomLine的width/x变化
        let deltaWidth = targetLabel.frame.width - sourceLabel.frame.width
        let deltaX = targetLabel.frame.origin.x - sourceLabel.frame.origin.x
        if style.isShowBottomLine {
            bottomLine.frame.size.width = sourceLabel.frame.width + deltaWidth * progress
            bottomLine.frame.origin.x = deltaX * progress + sourceLabel.frame.origin.x
        }
        
        // 5. coverView的渐变
        if style.isShowCoverView {
            coverView.frame.origin.x = style.isScrollEnabled ? (sourceLabel.frame.origin.x - style.coverViewMargin) + deltaX * progress : (sourceLabel.frame.origin.x + deltaX * progress)
            coverView.frame.size.width = style.isScrollEnabled ? (sourceLabel.frame.width + style.coverViewMargin * 2) + deltaWidth * progress : (sourceLabel.frame.width + deltaWidth * progress)
        }
    }
}
