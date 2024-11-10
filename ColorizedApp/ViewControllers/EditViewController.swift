//
//  EditViewController.swift
//  ColorizedApp
//
//  Created by Artem H on 25.10.24.
//

import UIKit

protocol ColorSettable {
    func updateColorComponents()
}

final class EditViewController: UIViewController {
    
    //MARK: - IB Outlets
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
    
    //MARK: - Public properties
    var uiColor: UIColor!
    var colorDelegate: ColorSettable?
    weak var delegate: EditViewControllerDelegate?
    
    //MARK: - Private properties
    private var initialTextFieldValue: String = ""

    private var colorValue = ColorValue()

    private var red: Float {
        get { return colorValue.red ?? 0.0 }
        set { colorValue.red = newValue }
    }
    private var green: Float {
        get { return colorValue.green ?? 0.0}
        set { colorValue.green = newValue }
    }
    private var blue: Float {
        get { return colorValue.blue ?? 0.0}
        set { colorValue.blue = newValue }
    }
    
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        redTextField.delegate = self
        greenTextField.delegate = self
        blueTextField.delegate = self
        colorDelegate = self
        
        setUpTintColor()
        setUpModelColorValues()
        
        colorDelegate?.updateColorComponents()
        
        addDoneButtonToNumberPad()
        
        colorView.layer.cornerRadius = 8
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        updateColorComponents()
        view.endEditing(true)
    }
    
    // MARK: - Slider and Done Button
    @IBAction func rgbSliders(_ sender: UISlider) {
        
        switch sender.tag {
        case 0:
            red = sender.value
        case 1:
            green = sender.value
        default:
            blue = sender.value
        }
        updateColorComponents()
    }
    
    @IBAction func doneButton(_ sender: UIButton) {
        delegate?.setViewColor(
            red: red.cgFloat(),
            green: green.cgFloat(),
            blue:  blue.cgFloat()
        )
        dismiss(animated: true)
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

// MARK: - ColorSettable
extension EditViewController: ColorSettable {
    func updateColorComponents() {
        setUpLabels()
        setUpTextFields()
        setUpColorView()
        setUpSlidersValue()
    }
}

// MARK: - Set up labels, text fields, sliders and view
extension EditViewController {
    
    private func setUpTintColor() {
        [redSlider, greenSlider, blueSlider].forEach { slider in
            slider?.maximumTrackTintColor = .white.withAlphaComponent(0.5)
        }
    }
    
    private func setUpModelColorValues() {
        red = uiColor.rgba.red.toFloat()
        green = uiColor.rgba.green.toFloat()
        blue = uiColor.rgba.blue.toFloat()
    }
    
    private func setUpLabels() {
        redLabel.text = red.toString()
        greenLabel.text = green.toString()
        blueLabel.text = blue.toString()
    }
    
    private func setUpTextFields() {
        redTextField.text = red.toString()
        greenTextField.text = green.toString()
        blueTextField.text = blue.toString()
    }
    
    private func setUpSlidersValue() {
        redSlider.value = red
        greenSlider.value = green
        blueSlider.value = blue
    }
    
    private func setUpColorView() {
        colorView.backgroundColor = UIColor(
            red: red.cgFloat(),
            green: green.cgFloat(),
            blue: blue.cgFloat(),
            alpha: 1
        )
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
            UIBarButtonItem(
                barButtonSystemItem: .flexibleSpace,
                target: nil,
                action: nil
            ),
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

// MARK: - UITextFieldDelegate
extension EditViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField == redTextField {
            red = textField.text?.toFloat() ?? 0.0
        } else if textField == greenTextField {
            green = textField.text?.toFloat() ?? 0.0
        } else {
            blue = textField.text?.toFloat() ?? 0.0
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
            showAlert(
                withTitle: "Wrong format",
                andMessage: "The value cannot contain letters, special characters and must be in the range between 0.00 and 1.00."
            ) {
                textField.text = self.initialTextFieldValue
                textField.resignFirstResponder()
            }
            return
        }
        
        if textField == redTextField {
            red = textField.text?.toFloat() ?? 0.0
        } else if textField == greenTextField {
            green = textField.text?.toFloat() ?? 0.0
        } else {
            blue = textField.text?.toFloat() ?? 0.0
        }
        colorDelegate?.updateColorComponents()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}

// MARK: - Float convert to CGFloat
extension Float {
    func cgFloat() -> CGFloat {
        CGFloat(self)
    }
}

// MARK: - Float to String
extension Float {
    func toString() -> String {
        String(format: "%.2f",self)
    }
    
}

// MARK: - CGFloat to Float
extension CGFloat {
    func toFloat() -> Float {
        Float(self)
    }
}

// MARK: - String to Float
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

