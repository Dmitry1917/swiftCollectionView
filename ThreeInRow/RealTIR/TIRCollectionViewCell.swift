//
//  TIRCollectionViewCell.swift
//  ThreeInRow
//
//  Created by DMITRY SINYOV on 12.05.17.
//  Copyright © 2017 DMITRY SINYOV. All rights reserved.
//

import UIKit

class TIRCollectionViewCell: UICollectionViewCell
{

    @IBOutlet weak private var mainContentView: UIView!
    @IBOutlet weak private var someContentView: UIView!
    @IBOutlet weak private var contentHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
        mainContentView.layer.cornerRadius = 4.0
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes)
    {
        super.apply(layoutAttributes)
        
        if let attributes = layoutAttributes as? TIRCollectionViewLayoutAttributes
        {
            contentHeightConstraint.constant = attributes.contentCustomHeight
        }
    }
    
    func setType(newType: TIRElementMainTypes)
    {
        self.someContentView.backgroundColor = UIColor.white
        switch newType
        {
        case .elementUndefined:
            self.mainContentView.backgroundColor = UIColor.clear
            self.someContentView.backgroundColor = UIColor.clear
        case .elementRed:
            self.mainContentView.backgroundColor = UIColor(red: 0.8, green: 0.1, blue: 0.2, alpha: 1.0)
        case .elementGreen:
            self.mainContentView.backgroundColor = UIColor(red: 0.1, green: 0.8, blue: 0.2, alpha: 1.0)
        case .elementBlue:
            self.mainContentView.backgroundColor = UIColor(red: 0.2, green: 0.1, blue: 0.8, alpha: 1.0)
        case .elementYellow:
            self.mainContentView.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.1, alpha: 1.0)
        case .elementOrange:
            self.mainContentView.backgroundColor = UIColor(red: 0.9, green: 0.6, blue: 0.1, alpha: 1.0)
        case .elementPurple:
            self.mainContentView.backgroundColor = UIColor(red: 0.7, green: 0.1, blue: 0.7, alpha: 1.0)
        }
    }
    
    func showBorder()
    {
        self.layer.borderColor = UIColor.red.cgColor
        self.layer.borderWidth = 2.0
    }
    func hideBorder()
    {
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.borderWidth = 0.0
    }

}
