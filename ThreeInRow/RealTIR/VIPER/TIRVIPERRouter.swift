//
//  TIRVIPERRouter.swift
//  ThreeInRow
//
//  Created by DMITRY SINYOV on 21.08.17.
//  Copyright © 2017 DMITRY SINYOV. All rights reserved.
//

import UIKit

protocol TIRVIPERRouterProtocol {
    static func createTIRModule() -> UIViewController
}

class TIRVIPERRouter: TIRVIPERRouterProtocol {
    class func createTIRModule() -> UIViewController {
        
        let storyboard = UIStoryboard(name: "TIRVIPERView", bundle: Bundle.main)
        
        let view = storyboard.instantiateViewController(withIdentifier: "TIRVIPERView")
        
        return view
    }
}
