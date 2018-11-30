//
//  CircleTagButton.swift
//  Founders Directory
//
//  Created by Steve Liddle on 10/3/16.
//  Copyright © 2016 Steve Liddle. All rights reserved.
//

import UIKit

@IBDesignable
class CircleTagButton : UIControl {
    
    // MARK: - Constants
    
    private struct Constant {
        static let AlphaFade: CGFloat = 0.3
        static let AlphaOpaque: CGFloat = 1.0
        static let DisabledCircleInset: CGFloat = 1.0
        static let DisabledColor = UIColor.lightGray
        static let Duration = 0.15
        static let EnabledColor = UIColor.init(r: 109, g: 180, b: 77)
        static let LabelOffset: CGFloat = 3
    }

    // MARK: - Public properties

    @IBInspectable
    var disabled: Bool = false {
        didSet {
            updateProperties()
        }
    }

    @IBInspectable
    var imageName: String? {
        didSet {
            updateImage()
        }
    }

    @IBInspectable
    var tagLabel: String? {
        didSet {
            updateLabel()
        }
    }

    // MARK: - Private properties

    /*
     * These cache the properties we need when drawing.  Since drawing can be expensive and
     * can be done frequently, we'll cache these values rather than compute them each time.
     */
    private var color = Constant.DisabledColor
    private var image: UIImage?
    private var text: NSAttributedString?
    private var textRect = CGRect.zero

    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageName = ""
        tagLabel = ""
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        imageName = ""
        tagLabel = ""
    }

    override func prepareForInterfaceBuilder() {
        updateProperties()

        super.prepareForInterfaceBuilder()
    }

    // MARK: - View lifecycle

    override func draw(_ rect: CGRect) {
        let circle = UIBezierPath()

        color.setFill()
        color.setStroke()

        if disabled {
            circle.addArc(withCenter: CGPoint(x: bounds.size.width / 2,
                                              y: bounds.size.width / 2),
                          radius: bounds.size.width / 2 - Constant.DisabledCircleInset,
                          startAngle: 0,
                          endAngle: CGFloat.pi * 2.0,
                          clockwise: true)
            circle.lineWidth = 1.0
            circle.stroke()
        } else {
            circle.addArc(withCenter: CGPoint(x: bounds.size.width / 2, y: bounds.size.width / 2),
                          radius: bounds.size.width / 2,
                          startAngle: 0,
                          endAngle: CGFloat.pi * 2.0,
                          clockwise: true)
            circle.fill()
            UIColor.white.setFill()
        }

        if let iconImage = image {
            iconImage.draw(at: CGPoint(x: (bounds.size.width - iconImage.size.width) / 2,
                                       y: (bounds.size.width - iconImage.size.height) / 2))
        }

        text?.draw(in: textRect)
    }

    override func layoutSubviews() {
        textRect.origin = CGPoint(x: (bounds.size.width - textRect.size.width) / 2,
                                  y: bounds.size.width + Constant.LabelOffset)
        super.layoutSubviews()
    }

    // MARK: - Touch events

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !disabled {
            UIView.animate(withDuration: Constant.Duration) {
                self.alpha = Constant.AlphaFade
            }
        }

        super.touchesBegan(touches, with: event)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !disabled {
            UIView.animate(withDuration: Constant.Duration) {
                self.alpha = Constant.AlphaOpaque
            }
        }
        
        super.touchesEnded(touches, with: event)
    }

    // MARK: - Private helpers

    private func updateImage() {
        if let name = imageName {
            image = UIImage(named: name)?.withRenderingMode(.alwaysTemplate)
        }
    }

    private func updateLabel() {
        if let label = tagLabel {
            let font = UIFont.preferredFont(forTextStyle: .caption2)

            text = NSAttributedString(string: label,
                                      attributes: [ NSAttributedString.Key.font : font,
                                                    NSAttributedString.Key.foregroundColor : color ])

            if let labelText = text {
                textRect.origin = CGPoint(x: (bounds.size.width - textRect.size.width) / 2,
                                          y: bounds.size.width + Constant.LabelOffset)
                textRect.size = labelText.size()
            }
        }
    }

    private func updateProperties() {
        if disabled {
            color = UIColor.lightGray
        } else {
            color = Constant.EnabledColor
        }

        updateImage()
        updateLabel()
    }
}
