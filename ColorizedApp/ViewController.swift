//
//  ViewController.swift
//  ColorizedApp
//
//  Created by Artem H on 25.10.24.
//

import UIKit

protocol EditViewControllerDelegate: AnyObject {
    func setViewColor(red: CGFloat, green: CGFloat, blue: CGFloat)
}

final class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.00, green: 0.00, blue: 0.00, alpha: 1)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let editVC = segue.destination as? EditViewController
        editVC?.delegate = self
        editVC?.uiColor = view.backgroundColor
    }
}

// MARK: - EditViewControllerDelegate
extension ViewController: EditViewControllerDelegate {
    func setViewColor(red: CGFloat, green: CGFloat, blue: CGFloat) {
        view.backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: 1)
    }
    
}
