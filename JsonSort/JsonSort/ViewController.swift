//
//  ViewController.swift
//  JsonSort
//
//  Created by Garenge on 2022/11/13.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var sourceTextView: UITextView!
    @IBOutlet weak var resultTextView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    
        self.sourceTextView.layer.borderColor = UIColor.lightGray.cgColor
        self.resultTextView.layer.borderColor = UIColor.lightGray.cgColor
    }

    @IBAction func pasteBtnClickedAction(_ sender: Any) {
        self.sourceTextView.text = UIPasteboard.general.string
    }
    
    @IBAction func clearBtnClickedAction(_ sender: Any) {
        self.sourceTextView.text = ""
        self.resultTextView.text = ""
    }
    
    @IBAction func sortBtnClickedAction(_ sender: Any) {
        
        let jsonStr = self.sourceTextView.text
        if let data = jsonStr?.data(using: .utf8), var json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) {
            
            if let array = json as? NSArray {
                let arrayS = array.sortedArray(using: #selector(NSString.localizedStandardCompare(_:)))
                json = arrayS
            }
            
            if let resultData = try? JSONSerialization.data(withJSONObject: json, options: .sortedKeys) {
                let resultStr = String(data: resultData, encoding: .utf8)
                self.resultTextView.text = resultStr
            }
        }
    }
    
    @IBAction func copyBtnClickedAction(_ sender: Any) {
        UIPasteboard.general.string = self.resultTextView.text
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}

