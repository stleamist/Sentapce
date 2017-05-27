//
//  FullCompositionSentenceTableViewCell.swift
//  Sentapce
//
//  Created by 김동규 on 2017. 5. 28..
//  Copyright © 2017년 Stleam. All rights reserved.
//

import UIKit

class SentenceCompositionCell: UITableViewCell {
    
    @IBOutlet weak var answerTextView: UITextView!
    @IBOutlet weak var enteredTextView: UITextView!
    @IBOutlet weak var placeholderTextView: UITextView!
    
    private var isShowingHint: Bool = false
    
    func toggleHint() {
        if isShowingHint {
            hideHint()
        } else {
            showHint()
        }
    }
    
    func showHint() {
        self.answerTextView.isHidden = false
        self.enteredTextView.isHidden = true
        self.placeholderTextView.isHidden = true
        self.isShowingHint = true
    }
    
    func hideHint() {
        self.answerTextView.isHidden = true
        self.enteredTextView.isHidden = false
        self.placeholderTextView.isHidden = false
        self.isShowingHint = false
    }
}
