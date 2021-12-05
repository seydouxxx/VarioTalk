//
//  Tools.swift
//  VarioTalk
//
//  Created by Seydoux on 2021/12/03.
//

import UIKit

extension UIColor {
    func image(_ size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { context in
            self.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
}
