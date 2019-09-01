//
//  SminViewController.swift
//  Book
//
//  Created by cscoi030 on 2019. 8. 23..
//  Copyright © 2019년 Korea University. All rights reserved.

import UIKit
let nc = NotificationCenter.default


class SminViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet var fontSize: UILabel!
    @IBOutlet var fontSizeStepper: UIStepper!
    @IBOutlet var reminderSwitch: UISwitch!
    @IBOutlet var reminderTimePicker: UIDatePicker!
    
    /*Font Stepper*/
    @IBAction func stepperValueChanged(sender: UIStepper) {
        self.fontSize.text = "\(Int(sender.value))"
        
        let fontSizeResponse = ["fontSizeKey": fontSize.text]
        NotificationCenter.default.post(name: .fontSizeChanged,
                                        object: nil,
                                        userInfo: fontSizeResponse)
    }
    
    
    /*Font Picker*/
    var fonts: [String] = ["NanumSquareR","NanumBarunpen", "NanumPen"]
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return fonts.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return fonts[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        fontTextField.text = fonts[row]
        let fontTypeResponse = ["fontTypeKey": fontTextField.text]
        NotificationCenter.default.post(name: .fontTypeChanged,
                                        object: nil,
                                        userInfo: fontTypeResponse)
        
    }
    
    /* Reminder Time Picker*/
    
    @IBOutlet weak var reminderLabel: UILabel!
    @IBOutlet weak var fontTextField: UITextField!
    var whenToRemindText: String = ""
    let datePicker = UIDatePicker()
    let tappedFontPicker = UIPickerView()
    
    /* 나중참고 - 아래에 뜨는거 말고 popup으로 하려면 이 함수 사용
     @objc func tapFunction(sender: UITapGestureRecognizer) {
     let alertView = UIAlertController(title: "", message: "", preferredStyle: UIAlertControllerStyle.Alert)
     
     pickerView = UIPickerView(frame: CGRectMake(0, 0, 250, 60))
     pickerView?.dataSource = self
     pickerView?.delegate = self
     
     alertView.view.addSubview(pickerView!)
     
     let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
     
     alertView.addAction(action)
     presentViewController(alertView, animated: true, completion: nil)
     
     UIView.animate(withDuration: 0.3, animations: {
     self.view.layoutIfNeeded()
     self.bakcgroundButton.alpha = 0.5
     })
     
     print("success")
     
     } */
    
    
    @objc func switchStateDidChange(_ sender:UISwitch){
        if sender.isOn == true {
            reminderTimePicker.isHidden = false
            reminderLabel.text = "정해주신 시간에 시를 배송해드립니다"
            reminderLabel.isHidden = false
        } else {
            reminderTimePicker.isHidden = true
            reminderLabel.isHidden = true
        }
    }

    @objc func datePickerChanged(_ datePicker:UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        let whenToRemindText = dateFormatter.string(from: datePicker.date)
        reminderLabel.text = "네! \(whenToRemindText)에 시를 배송해드릴게요 :)"
        dateFormatter.dateFormat = "HHmm"
        let remindTimeSaved = dateFormatter.string(from: datePicker.date)
        UserDefaults.standard.set(remindTimeSaved, forKey: "defaultRemindTime")
        NotificationCenter.default.post(name: .remindTimeChanged,
                                        object: nil)
                                        //userInfo: fontSizeResponse)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tappedFontPicker.delegate = self
        tappedFontPicker.dataSource = self
        fontTextField.text = "NanumSquareR"
        fontSize.text = "15"
        fontTextField.inputView = tappedFontPicker
        
        
        
        reminderLabel.isHidden = true
        reminderSwitch.isOn = false
        reminderTimePicker.isHidden = true
        reminderSwitch.addTarget(self, action: #selector(SminViewController.switchStateDidChange(_:)), for: .valueChanged)
        reminderTimePicker.addTarget(self, action: #selector(SminViewController.datePickerChanged(_:)), for: UIControlEvents.valueChanged)
        
        self.hideKeyboard()
        
        
        
        /* 팝업으로 하고싶으면 이거 활성화
         let tap = UITapGestureRecognizer(target: self, action: #selector(SminViewController.tapFunction))
         
         fontTextField.isUserInteractionEnabled = true
         fontTextField.addGestureRecognizer(tap)
         
         popupView.layer.cornerRadius = 10
         popupViewlayer.masksToBounds = true
         */
        // 여기까지 주원 수정(2)
        
        /*나중에 해야함! 아래꺼 저장된 값으로 초기화*/
        fontSizeStepper.value = 15
        fontSize.text = "15"
        
        fontSizeStepper.wraps = true
        fontSizeStepper.autorepeat = true
        fontSizeStepper.minimumValue = 7
        fontSizeStepper.maximumValue = 50
        /* Reminder Time Picker 날짜 안 보이고 시간만 보이게 바꿈*/
        reminderTimePicker.datePickerMode = UIDatePickerMode.time
        datePicker.datePickerMode = UIDatePickerMode.time
        //datePicker.backgroundColor = UIColor.blue
        datePicker.tintColor = UIColor.blue // 추가
        //txtFildDeadLine.textField.inputView = datePicker
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


