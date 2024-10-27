//
//  EditViewController.swift
//  ColorizedApp
//
//  Created by Artem H on 25.10.24.
//

import UIKit

final class EditViewController: UIViewController {
    
    @IBOutlet var colorView: UIView!
    
    @IBOutlet var redLabel: UILabel!
    @IBOutlet var blueLabel: UILabel!
    @IBOutlet var greenLabel: UILabel!
    
    @IBOutlet var redTextField: UITextField!
    @IBOutlet var blueTextField: UITextField!
    @IBOutlet var greenTextField: UITextField!
    
    @IBOutlet var redSlider: UISlider!
    @IBOutlet var greenSlider: UISlider!
    @IBOutlet var blueSlider: UISlider!
    
    weak var delegate: EditViewControllerDelegate?
    
    private var rgb = ColorValues()
    private var initialTextFieldValue: String = ""
    
    var uiColor: UIColor!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        redTextField.delegate = self
        greenTextField.delegate = self
        blueTextField.delegate = self
        
        setUpTintColor()
        
        setUpLabels()
        setUpTextFields()
        setUpSlidersValue()
        setUpColorView()
        
        addDoneButtonToNumberPad()
        
        colorView.layer.cornerRadius = 8
    }
    
    @IBAction func rgbSliders(_ sender: UISlider) {
        setUpColorView()
        
        let selectedValue = String(format: "%.2f", sender.value)
        
        switch sender.tag {
        case 0:
            redLabel.text = selectedValue
            redTextField.text = selectedValue
        case 1:
            greenLabel.text = selectedValue
            greenTextField.text = selectedValue
        default:
            blueLabel.text = selectedValue
            blueTextField.text = selectedValue
        }
        
    }
    
    @IBAction func doneButton(_ sender: UIButton) {
        delegate?.setViewColor(
            red: redSlider.value.cgFloat(),
            green: greenSlider.value.cgFloat(),
            blue:  blueSlider.value.cgFloat()
        )
        dismiss(animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    private func setUpTintColor() {
        [redSlider, greenSlider, blueSlider].forEach { slider in
            slider?.maximumTrackTintColor = .white.withAlphaComponent(0.5)
        }
    }
    
    private func setUpLabels() {
        redLabel.text = String(format: "%.2f", uiColor.rgba.red)
        greenLabel.text = String(format: "%.2f", uiColor.rgba.green)
        blueLabel.text = String(format: "%.2f", uiColor.rgba.blue)
    }
    
    private func setUpTextFields() {
        redTextField.text = redLabel.text
        greenTextField.text = greenLabel.text
        blueTextField.text = blueLabel.text
    }
    
    private func setUpSlidersValue() {
        redSlider.value = redLabel.text?.toFloat() ?? 0.0
        greenSlider.value = greenLabel.text?.toFloat() ?? 0.0
        blueSlider.value = blueLabel.text?.toFloat() ?? 0.0
    }
    
    private func setUpColorView() {
        colorView.backgroundColor = UIColor(
            red: redSlider.value.cgFloat(),
            green: greenSlider.value.cgFloat(),
            blue: blueSlider.value.cgFloat(),
            alpha: 1
        )
    }
    
    private func showAlert(
        withTitle title: String,
        andMessage message: String,
        completion: (() -> Void)? = nil
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        }
        alert.addAction(okAction)
        present(alert, animated: true)
    }
}

// MARK: - Float convert to CGFloat
extension Float {
    func cgFloat() -> CGFloat {
        CGFloat(self)
    }
}

// MARK: - String convert to Float
extension String {
    func toFloat() -> Float {
        Float(self) ?? 0.0
    }
}

// MARK: - Get of Red, Green and Blue
extension UIColor {
    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (red, green, blue, alpha)
    }
}

// MARK: - UITextFieldDelegate
extension EditViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField == redTextField {
            rgb.redValue = textField.text ?? ""
        } else if textField == greenTextField {
            rgb.greenValue = textField.text ?? ""
        } else {
            rgb.blueValue = textField.text ?? ""
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        initialTextFieldValue = textField.text ?? "0.00"
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        guard let inputText = textField.text, !inputText.isEmpty else {
            showAlert(withTitle: "No value", andMessage: "Value field cannot be empty") {
                textField.text = self.initialTextFieldValue
            }
            return
        }
        
        let regex = #"^(0[.,]\d{1,2}|1([.,]00?)?)$"#
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
            .evaluate(with: textField.text)
        
        if !predicate {
            showAlert(withTitle: "Wrong format", andMessage: "The value cannot contain letters, special characters and must be in the range between 0.00 and 1.00.") {
                textField.text = self.initialTextFieldValue
            }
            return
        }
        
        if textField == redTextField {
            rgb.redValue = textField.text ?? ""
            redSlider.setValue(textField.text?.toFloat() ?? 0.0, animated: true)
            redLabel.text = textField.text
        } else if textField == greenTextField {
            rgb.greenValue = textField.text ?? ""
            greenSlider.setValue(textField.text?.toFloat() ?? 0.0, animated: true)
            greenLabel.text = textField.text
        } else {
            rgb.blueValue = textField.text ?? ""
            blueSlider.setValue(textField.text?.toFloat() ?? 0.0, animated: true)
            blueLabel.text = textField.text
        }
        
        setUpColorView()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}

// MARK: - Keyboard add .decimalPad and Done button
extension EditViewController {
    func addDoneButtonToNumberPad() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: self,
            action: #selector(doneButtonTapped)
        )
        toolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            doneButton
        ]
        
        greenTextField.inputAccessoryView = toolbar
        greenTextField.keyboardType = .decimalPad
    }
    
    @objc private func doneButtonTapped() {
        view.endEditing(true)
        textFieldDidEndEditing(greenTextField)
    }
}
