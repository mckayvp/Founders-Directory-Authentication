//
//  CircleImageView.swift
//  Founders Directory
//
//  Created by Steve Liddle on 9/22/16.
//  Copyright © 2016 Steve Liddle. All rights reserved.
//

import UIKit

class CircleImageView : UIImageView {
    override func layoutSubviews() {
        layer.cornerRadius = frame.size.width / 2

        super.layoutSubviews()
    }
}
