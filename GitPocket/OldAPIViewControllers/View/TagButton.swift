//
//  TagButton.swift
//  GitPocket
//
//  Created by yansong li on 2015-08-02.
//  Copyright © 2015 yansong li. All rights reserved.
//

import Foundation
import UIKit

class TagButton: UIButton {
    var textFont: UIFont = UIFont.systemFont(ofSize: 16) {
        didSet {
            titleLabel?.font = textFont
        }
    }
    
    var cornerRadis: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadis
            layer.masksToBounds = cornerRadis > 0
        }
    }
    
    var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }
    
    var paddingY: CGFloat = 2 {
        didSet {
            titleEdgeInsets.top = paddingY
            titleEdgeInsets.bottom = paddingY
        }
    }
    
    var paddingX: CGFloat = 5 {
        didSet {
            titleEdgeInsets.right = paddingX
            titleEdgeInsets.left = paddingY
        }
    }
    
    var textColor: UIColor = UIColor.black {
        didSet {
            setTitleColor(textColor, for: UIControlState())
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    init(title: String) {
        super.init(frame: CGRect.zero)
        setTitle(title, for: UIControlState())
        titleLabel?.font = textFont
        setTitleColor(textColor, for:UIControlState())
        titleLabel?.backgroundColor = UIColor.clear
        
        setupView()
    }
    
    func setupView() {
        frame.size = intrinsicContentSize
    }
    
    override var intrinsicContentSize : CGSize {
        var size = titleLabel?.text?.size(attributes: [NSFontAttributeName: textFont]) ?? CGSize.zero
        size.height = textFont.pointSize + paddingY*2
        size.width += paddingX*2
        return size;
    }
}
