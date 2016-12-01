/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit

class HorizontalLineView: UIView {

    var color: UIColor = .white
    var startX: CGFloat?
    var endX: CGFloat?
    var startY: CGFloat?
    var endY: CGFloat?

    // draw the horizontal line at the bottom of the view
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let ctx = UIGraphicsGetCurrentContext() else {
            return
        }
        
        let startEnd = [
            CGPoint(x: startX ?? rect.width, y: startY ?? rect.height),
            CGPoint(x: endX ?? rect.width, y: endY ?? rect.height)
        ]

        ctx.setLineWidth(1.5)
        ctx.setStrokeColor(color.cgColor)
        ctx.strokeLineSegments(between: startEnd)
    }
}
