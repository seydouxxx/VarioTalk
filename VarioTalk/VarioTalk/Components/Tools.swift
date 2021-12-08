//
//  Tools.swift
//  VarioTalk
//
//  Created by Seydoux on 2021/12/03.
//

import UIKit

func dateFormatterInTime(from timestamp: Int) -> String {
    var time = Date(timeIntervalSince1970: Double(timestamp))

    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = .autoupdatingCurrent
    dateFormatter.locale = Locale(identifier: "ko")
    dateFormatter.dateFormat = "a hh:mm"
    return dateFormatter.string(from: time)
}
func dateFormatterInDate(from timestamp: Int) -> String {
    var time = Date(timeIntervalSince1970: Double(timestamp))
    
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = .autoupdatingCurrent
    dateFormatter.locale = Locale(identifier: "ko")
    dateFormatter.dateFormat = "MM월 dd일"
    return dateFormatter.string(from: time)
}

extension UIColor {
    func image(_ size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { context in
            self.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
}

//MARK: - Extension for complement pushViewController with completion handler
extension UINavigationController {
    public func pushViewController(_ viewController: UIViewController,animated: Bool, completion: (() -> Void)?) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        pushViewController(viewController, animated: animated)
        CATransaction.commit()
    }
}
