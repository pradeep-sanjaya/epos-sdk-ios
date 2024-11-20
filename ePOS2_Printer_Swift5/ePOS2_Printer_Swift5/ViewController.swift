

import UIKit

class ViewController: UIViewController, DiscoveryViewDelegate, CustomPickerViewDelegate, Epos2PtrReceiveDelegate {
    let PAGE_AREA_HEIGHT: Int = 500
    let PAGE_AREA_WIDTH: Int = 500
    let FONT_A_HEIGHT: Int = 24
    let FONT_A_WIDTH: Int = 12
    let BARCODE_HEIGHT_POS: Int = 70
    let BARCODE_WIDTH_POS: Int = 110
    
    @IBOutlet weak var buttonDiscovery: UIButton!
    @IBOutlet weak var buttonLang: UIButton!
    @IBOutlet weak var buttonPrinterSeries: UIButton!
    @IBOutlet weak var buttonReceipt: UIButton!
    @IBOutlet weak var buttonCoupon: UIButton!
    @IBOutlet weak var textWarnings: UITextView!
    @IBOutlet weak var textTarget: UITextField!

    var printerList: CustomPickerDataSource?
    var langList: CustomPickerDataSource?
    
    var printerPicker: CustomPickerView?
    var langPicker: CustomPickerView?
    
    var printer: Epos2Printer?
    
    var valuePrinterSeries: Epos2PrinterSeries = EPOS2_TM_M10
    var valuePrinterModel: Epos2ModelLang = EPOS2_MODEL_ANK
    
    var target: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        printerList = CustomPickerDataSource()
        printerList!.addItem(NSLocalizedString("printerseries_m10", comment:""), value: EPOS2_TM_M10)
        printerList!.addItem(NSLocalizedString("printerseries_m30", comment:""), value: EPOS2_TM_M30)
        printerList!.addItem(NSLocalizedString("printerseries_p20", comment:""), value: EPOS2_TM_P20)
        printerList!.addItem(NSLocalizedString("printerseries_p60", comment:""), value: EPOS2_TM_P60)
        printerList!.addItem(NSLocalizedString("printerseries_p60ii", comment:""), value: EPOS2_TM_P60II)
        printerList!.addItem(NSLocalizedString("printerseries_p80", comment:""), value: EPOS2_TM_P80)
        printerList!.addItem(NSLocalizedString("printerseries_t20", comment:""), value: EPOS2_TM_T20)
        printerList!.addItem(NSLocalizedString("printerseries_t60", comment:""), value: EPOS2_TM_T60)
        printerList!.addItem(NSLocalizedString("printerseries_t70", comment:""), value: EPOS2_TM_T70)
        printerList!.addItem(NSLocalizedString("printerseries_t81", comment:""), value: EPOS2_TM_T81)
        printerList!.addItem(NSLocalizedString("printerseries_t82", comment:""), value: EPOS2_TM_T82)
        printerList!.addItem(NSLocalizedString("printerseries_t83", comment:""), value: EPOS2_TM_T83)
        printerList!.addItem(NSLocalizedString("printerseries_t83iii", comment:""), value: EPOS2_TM_T83III)
        printerList!.addItem(NSLocalizedString("printerseries_t88", comment:""), value: EPOS2_TM_T88)
        printerList!.addItem(NSLocalizedString("printerseries_t90", comment:""), value: EPOS2_TM_T90)
        printerList!.addItem(NSLocalizedString("printerseries_t90kp", comment:""), value: EPOS2_TM_T90KP)
        printerList!.addItem(NSLocalizedString("printerseries_t100", comment:""), value: EPOS2_TM_T100)
        printerList!.addItem(NSLocalizedString("printerseries_u220", comment:""), value: EPOS2_TM_U220)
        printerList!.addItem(NSLocalizedString("printerseries_u330", comment:""), value: EPOS2_TM_U330)
        printerList!.addItem(NSLocalizedString("printerseries_l90", comment:""), value: EPOS2_TM_L90)
        printerList!.addItem(NSLocalizedString("printerseries_h6000", comment:""), value: EPOS2_TM_H6000)
        printerList!.addItem(NSLocalizedString("printerseries_m30ii", comment:""), value: EPOS2_TM_M30II)
        printerList!.addItem(NSLocalizedString("printerseries_ts100", comment:""), value: EPOS2_TS_100)
        printerList!.addItem(NSLocalizedString("printerseries_m50", comment:""), value: EPOS2_TM_M50)
        printerList!.addItem(NSLocalizedString("printerseries_t88vii", comment:""), value: EPOS2_TM_T88VII)
        printerList!.addItem(NSLocalizedString("printerseries_l90lfc", comment:""), value: EPOS2_TM_L90LFC)
        printerList!.addItem(NSLocalizedString("printerseries_l100", comment:""), value: EPOS2_TM_L100)
        printerList!.addItem(NSLocalizedString("printerseries_p20ii", comment:""), value: EPOS2_TM_P20II)
        printerList!.addItem(NSLocalizedString("printerseries_p80ii", comment:""), value: EPOS2_TM_P80II)
        printerList!.addItem(NSLocalizedString("printerseries_m30iii", comment:""), value: EPOS2_TM_M30III)
        printerList!.addItem(NSLocalizedString("printerseries_m50ii", comment:""), value: EPOS2_TM_M50II)
        printerList!.addItem(NSLocalizedString("printerseries_m55", comment:""), value: EPOS2_TM_M55)
        printerList!.addItem(NSLocalizedString("printerseries_u220ii", comment:""), value: EPOS2_TM_U220II)
        
        langList = CustomPickerDataSource()
        langList!.addItem(NSLocalizedString("language_ank", comment:""), value: EPOS2_MODEL_ANK)
        langList!.addItem(NSLocalizedString("language_japanese", comment:""), value: EPOS2_MODEL_JAPANESE)
        langList!.addItem(NSLocalizedString("language_chinese", comment:""), value: EPOS2_MODEL_CHINESE)
        langList!.addItem(NSLocalizedString("language_taiwan", comment:""), value: EPOS2_MODEL_TAIWAN)
        langList!.addItem(NSLocalizedString("language_korean", comment:""), value: EPOS2_MODEL_KOREAN)
        langList!.addItem(NSLocalizedString("language_thai", comment:""), value: EPOS2_MODEL_THAI)
        langList!.addItem(NSLocalizedString("language_southasia", comment:""), value: EPOS2_MODEL_SOUTHASIA)
        
        printerPicker = CustomPickerView()
        langPicker = CustomPickerView()
        let window = UIApplication.shared.keyWindow
        if (window != nil) {
            window!.addSubview(printerPicker!)
            window!.addSubview(langPicker!)
        }
        else{
            self.view.addSubview(printerPicker!)
            self.view.addSubview(langPicker!)
        }
        printerPicker!.delegate = self
        langPicker!.delegate = self
        
        printerPicker!.dataSource = printerList
        langPicker!.dataSource = langList
        
        valuePrinterSeries = printerList!.valueItem(0) as! Epos2PrinterSeries
        buttonPrinterSeries.setTitle(printerList!.textItem(0), for:UIControl.State())
        valuePrinterModel = langList!.valueItem(0) as! Epos2ModelLang
        buttonLang.setTitle(langList!.textItem(0), for:UIControl.State())
        
        setDoneToolbar()
        
        let result = Epos2Log.setLogSettings(EPOS2_PERIOD_TEMPORARY.rawValue, output: EPOS2_OUTPUT_STORAGE.rawValue, ipAddress:nil, port:0, logSize:1, logLevel:EPOS2_LOGLEVEL_LOW.rawValue)
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method: "setLogSettings")
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        initializePrinterObject()
        target = textTarget.text
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        finalizePrinterObject()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setDoneToolbar() {
        let doneToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44))
        doneToolbar.barStyle = UIBarStyle.blackTranslucent
        
        doneToolbar.sizeToFit()
        let space = UIBarButtonItem(barButtonSystemItem:UIBarButtonItem.SystemItem.flexibleSpace, target:self, action:nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem:UIBarButtonItem.SystemItem.done, target:self, action:#selector(ViewController.doneKeyboard(_:)))
        
        doneToolbar.setItems([space, doneButton], animated:true)
        textTarget.inputAccessoryView = doneToolbar
    }
    
    @objc func doneKeyboard(_ sender: AnyObject) {
        textTarget.resignFirstResponder()
        target = textTarget.text
    }

    @IBAction func didTouchUpInside(_ sender: AnyObject) {
        textTarget.resignFirstResponder()
        
        switch sender.tag {
        case 1:
            printerPicker!.showPicker()
        case 2:
            langPicker!.showPicker()
        case 3:
            showIndicator(NSLocalizedString("wait", comment:""));
            textWarnings.text = ""
            let queue = OperationQueue()
            queue.addOperation({ [self] in
                if !runPrinterReceiptSequence() {
                    hideIndicator();
                }
            })
            break
        case 4:
            showIndicator(NSLocalizedString("wait", comment:""));
            textWarnings.text = ""
            let queue = OperationQueue()
            queue.addOperation({ [self] in
                if !runPrinterCouponSequence() {
                    hideIndicator();
                }
            })
            break
        default:
            break
        }
    }
    
    func customPickerView(_ pickerView: CustomPickerView, didSelectItem text: String, itemValue value: Any) {
        if pickerView == printerPicker {
            self.buttonPrinterSeries.setTitle(text, for:UIControl.State())
            self.valuePrinterSeries = value as! Epos2PrinterSeries
        }
        if pickerView == langPicker {
            self.buttonLang.setTitle(text, for:UIControl.State())
            self.valuePrinterModel = value as! Epos2ModelLang
        }

        finalizePrinterObject()
        initializePrinterObject()
    }
    
    func runPrinterReceiptSequence() -> Bool {
        if !createReceiptData() {
            return false
        }
        
        if !printData() {
            return false
        }
        
        return true
    }
    
    func runPrinterCouponSequence() -> Bool {

        if !createCouponData() {
            return false
        }
        
        if !printData() {
            return false
        }
        
        return true
    }
    
    func createReceiptData() -> Bool {
        let barcodeWidth = 2
        let barcodeHeight = 100
        
        var result = EPOS2_SUCCESS.rawValue
        
        let textData: NSMutableString = NSMutableString()
        let logoData = UIImage(named: "store.png")
        
        if logoData == nil {
            return false
        }

        result = printer!.addTextAlign(EPOS2_ALIGN_CENTER.rawValue)
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addTextAlign")
            return false;
        }
        
        result = printer!.add(logoData, x: 0, y:0,
            width:Int(logoData!.size.width),
            height:Int(logoData!.size.height),
            color:EPOS2_COLOR_1.rawValue,
            mode:EPOS2_MODE_MONO.rawValue,
            halftone:EPOS2_HALFTONE_DITHER.rawValue,
            brightness:Double(EPOS2_PARAM_DEFAULT),
            compress:EPOS2_COMPRESS_AUTO.rawValue)
        
        if result != EPOS2_SUCCESS.rawValue {
            printer!.clearCommandBuffer()
            MessageView.showErrorEpos(result, method:"addImage")
            return false
        }

        // Section 1 : Store information
        result = printer!.addFeedLine(1)
        if result != EPOS2_SUCCESS.rawValue {
            printer!.clearCommandBuffer()
            MessageView.showErrorEpos(result, method:"addFeedLine")
            return false
        }
        
        textData.append("THE STORE 123 (555) 555 – 5555\n")
        textData.append("STORE DIRECTOR – John Smith\n")
        textData.append("\n")
        textData.append("7/01/07 16:58 6153 05 0191 134\n")
        textData.append("ST# 21 OP# 001 TE# 01 TR# 747\n")
        textData.append("------------------------------\n")
        result = printer!.addText(textData as String)
        if result != EPOS2_SUCCESS.rawValue {
            printer!.clearCommandBuffer()
            MessageView.showErrorEpos(result, method:"addText")
            return false;
        }
        textData.setString("")
        
        // Section 2 : Purchaced items
        textData.append("400 OHEIDA 3PK SPRINGF  9.99 R\n")
        textData.append("410 3 CUP BLK TEAPOT    9.99 R\n")
        textData.append("445 EMERIL GRIDDLE/PAN 17.99 R\n")
        textData.append("438 CANDYMAKER ASSORT   4.99 R\n")
        textData.append("474 TRIPOD              8.99 R\n")
        textData.append("433 BLK LOGO PRNTED ZO  7.99 R\n")
        textData.append("458 AQUA MICROTERRY SC  6.99 R\n")
        textData.append("493 30L BLK FF DRESS   16.99 R\n")
        textData.append("407 LEVITATING DESKTOP  7.99 R\n")
        textData.append("441 **Blue Overprint P  2.99 R\n")
        textData.append("476 REPOSE 4PCPM CHOC   5.49 R\n")
        textData.append("461 WESTGATE BLACK 25  59.99 R\n")
        textData.append("------------------------------\n")
        
        result = printer!.addText(textData as String)
        if result != EPOS2_SUCCESS.rawValue {
            printer!.clearCommandBuffer()
            MessageView.showErrorEpos(result, method:"addText")
            return false;
        }
        textData.setString("")

        
        // Section 3 : Payment infomation
        textData.append("SUBTOTAL                160.38\n");
        textData.append("TAX                      14.43\n");
        result = printer!.addText(textData as String)
        if result != EPOS2_SUCCESS.rawValue {
            printer!.clearCommandBuffer()
            MessageView.showErrorEpos(result, method:"addText")
            return false
        }
        textData.setString("")
        
        result = printer!.addTextSize(2, height:2)
        if result != EPOS2_SUCCESS.rawValue {
            printer!.clearCommandBuffer()
            MessageView.showErrorEpos(result, method:"addTextSize")
            return false
        }
        
        result = printer!.addText("TOTAL    174.81\n")
        if result != EPOS2_SUCCESS.rawValue {
            printer!.clearCommandBuffer()
            MessageView.showErrorEpos(result, method:"addText")
            return false;
        }
        
        result = printer!.addTextSize(1, height:1)
        if result != EPOS2_SUCCESS.rawValue {
            printer!.clearCommandBuffer()
            MessageView.showErrorEpos(result, method:"addTextSize")
            return false;
        }
        
        result = printer!.addFeedLine(1)
        if result != EPOS2_SUCCESS.rawValue {
            printer!.clearCommandBuffer()
            MessageView.showErrorEpos(result, method:"addFeedLine")
            return false;
        }
        
        textData.append("CASH                    200.00\n")
        textData.append("CHANGE                   25.19\n")
        textData.append("------------------------------\n")
        result = printer!.addText(textData as String)
        if result != EPOS2_SUCCESS.rawValue {
            printer!.clearCommandBuffer()
            MessageView.showErrorEpos(result, method:"addText")
            return false
        }
        textData.setString("")
        
        // Section 4 : Advertisement
        textData.append("Purchased item total number\n")
        textData.append("Sign Up and Save !\n")
        textData.append("With Preferred Saving Card\n")
        result = printer!.addText(textData as String)
        if result != EPOS2_SUCCESS.rawValue {
            printer!.clearCommandBuffer()
            MessageView.showErrorEpos(result, method:"addText")
            return false;
        }
        textData.setString("")
        
        result = printer!.addFeedLine(2)
        if result != EPOS2_SUCCESS.rawValue {
            printer!.clearCommandBuffer()
            MessageView.showErrorEpos(result, method:"addFeedLine")
            return false
        }
        
        result = printer!.addBarcode("01209457",
            type:EPOS2_BARCODE_CODE39.rawValue,
            hri:EPOS2_HRI_BELOW.rawValue,
            font:EPOS2_FONT_A.rawValue,
            width:barcodeWidth,
            height:barcodeHeight)
        if result != EPOS2_SUCCESS.rawValue {
            printer!.clearCommandBuffer()
            MessageView.showErrorEpos(result, method:"addBarcode")
            return false
        }
        
        result = printer!.addCut(EPOS2_CUT_FEED.rawValue)
        if result != EPOS2_SUCCESS.rawValue {
            printer!.clearCommandBuffer()
            MessageView.showErrorEpos(result, method:"addCut")
            return false
        }
        
        return true
    }
    
    func createCouponData() -> Bool {
        let barcodeWidth = 2
        let barcodeHeight = 64
        
        var result = EPOS2_SUCCESS.rawValue
        
        if printer == nil {
            return false
        }
        
        let coffeeData = UIImage(named: "coffee.png")
        let wmarkData = UIImage(named: "wmark.png")
        
        if coffeeData == nil || wmarkData == nil {
            return false
        }
        
        result = printer!.add(wmarkData, x:0, y:0,
                              width:Int(wmarkData!.size.width),
                              height:Int(wmarkData!.size.height),
                              color:EPOS2_PARAM_DEFAULT,
                              mode:EPOS2_PARAM_DEFAULT,
                              halftone:EPOS2_PARAM_DEFAULT,
                              brightness:Double(EPOS2_PARAM_DEFAULT),
                              compress:EPOS2_PARAM_DEFAULT)
        if result != EPOS2_SUCCESS.rawValue {
            printer!.clearCommandBuffer()
            MessageView.showErrorEpos(result, method:"addImage")
            return false
        }
        
        result = printer!.add(coffeeData, x:0, y:0,
                              width:Int(coffeeData!.size.width),
                              height:Int(coffeeData!.size.height),
                              color:EPOS2_PARAM_DEFAULT,
                              mode:EPOS2_PARAM_DEFAULT,
                              halftone:EPOS2_PARAM_DEFAULT,
                              brightness:3,
                              compress:EPOS2_PARAM_DEFAULT)
        
        if result != EPOS2_SUCCESS.rawValue {
            printer!.clearCommandBuffer()
            MessageView.showErrorEpos(result, method:"addImage")
            return false
        }
        
        result = printer!.addBarcode("01234567890", type:EPOS2_BARCODE_UPC_A.rawValue, hri:EPOS2_PARAM_DEFAULT, font: EPOS2_PARAM_DEFAULT, width:barcodeWidth, height:barcodeHeight)
        if result != EPOS2_SUCCESS.rawValue {
            printer!.clearCommandBuffer()
            MessageView.showErrorEpos(result, method:"addBarcode")
            return false
        }
        
        result = printer!.addCut(EPOS2_CUT_FEED.rawValue)
        if result != EPOS2_SUCCESS.rawValue {
            printer!.clearCommandBuffer()
            MessageView.showErrorEpos(result, method:"addCut")
            return false
        }
        
        return true
    }
    
    func printData() -> Bool {
        if printer == nil {
            return false
        }
        
        if !connectPrinter() {
            printer!.clearCommandBuffer()
            return false
        }
        
        let result = printer!.sendData(Int(EPOS2_PARAM_DEFAULT))
        if result != EPOS2_SUCCESS.rawValue {
            printer!.clearCommandBuffer()
            MessageView.showErrorEpos(result, method:"sendData")
            printer!.disconnect()
            return false
        }
        
        return true
    }

    @discardableResult
    func initializePrinterObject() -> Bool {
        printer = Epos2Printer(printerSeries: valuePrinterSeries.rawValue, lang: valuePrinterModel.rawValue)
        
        if printer == nil {
            return false
        }
        printer!.setReceiveEventDelegate(self)
        
        return true
    }
    
    func finalizePrinterObject() {
        if printer == nil {
            return
        }

        printer!.setReceiveEventDelegate(nil)
        printer = nil
    }
    
    func connectPrinter() -> Bool {
        var result: Int32 = EPOS2_SUCCESS.rawValue
        
        if printer == nil {
            return false
        }
        
        //Note: This API must be used from background thread only
        result = printer!.connect(target, timeout:Int(EPOS2_PARAM_DEFAULT))
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"connect")
            return false
        }
        
        return true
    }
    
    func disconnectPrinter() {
        var result: Int32 = EPOS2_SUCCESS.rawValue
        
        if printer == nil {
            return
        }
        
        //Note: This API must be used from background thread only
        result = printer!.disconnect()
        if result != EPOS2_SUCCESS.rawValue {
            DispatchQueue.main.async(execute: {
                MessageView.showErrorEpos(result, method:"disconnect")
            })
        }

        printer!.clearCommandBuffer()
    }
    
    func onPtrReceive(_ printerObj: Epos2Printer!, code: Int32, status: Epos2PrinterStatusInfo!, printJobId: String!) {
        
        let queue = OperationQueue()
        queue.addOperation({ [self] in
            self.disconnectPrinter()
            self.hideIndicator();
            MessageView.showResult(code, errMessage: makeErrorMessage(status))
            dispPrinterWarnings(status)
        })
    }
    
    func dispPrinterWarnings(_ status: Epos2PrinterStatusInfo?) {
        if status == nil {
            return
        }
        
        OperationQueue.main.addOperation({ [self] in
            textWarnings.text = ""
        })
        let wanringMsg = NSMutableString()
        
        if status!.paper == EPOS2_PAPER_NEAR_END.rawValue {
            wanringMsg.append(NSLocalizedString("warn_receipt_near_end", comment:""))
        }
        
        if status!.batteryLevel == EPOS2_BATTERY_LEVEL_1.rawValue {
            wanringMsg.append(NSLocalizedString("warn_battery_near_end", comment:""))
        }
        
        if status!.paperTakenSensor == EPOS2_REMOVAL_DETECT_PAPER.rawValue {
            wanringMsg.append(NSLocalizedString("warn_detect_paper", comment:""))
        }
        
        if status!.paperTakenSensor == EPOS2_REMOVAL_DETECT_UNKNOWN.rawValue {
            wanringMsg.append(NSLocalizedString("warn_detect_unknown", comment:""))
        }
        
        OperationQueue.main.addOperation({ [self] in
            textWarnings.text = wanringMsg as String
        })
        
    }

    func makeErrorMessage(_ status: Epos2PrinterStatusInfo?) -> String {
        let errMsg = NSMutableString()
        if status == nil {
            return ""
        }
    
        if status!.online == EPOS2_FALSE {
            errMsg.append(NSLocalizedString("err_offline", comment:""))
        }
        if status!.connection == EPOS2_FALSE {
            errMsg.append(NSLocalizedString("err_no_response", comment:""))
        }
        if status!.coverOpen == EPOS2_TRUE {
            errMsg.append(NSLocalizedString("err_cover_open", comment:""))
        }
        if status!.paper == EPOS2_PAPER_EMPTY.rawValue {
            errMsg.append(NSLocalizedString("err_receipt_end", comment:""))
        }
        if status!.paperFeed == EPOS2_TRUE || status!.panelSwitch == EPOS2_SWITCH_ON.rawValue {
            errMsg.append(NSLocalizedString("err_paper_feed", comment:""))
        }
        if status!.errorStatus == EPOS2_MECHANICAL_ERR.rawValue || status!.errorStatus == EPOS2_AUTOCUTTER_ERR.rawValue {
            errMsg.append(NSLocalizedString("err_autocutter", comment:""))
            errMsg.append(NSLocalizedString("err_need_recover", comment:""))
        }
        if status!.errorStatus == EPOS2_UNRECOVER_ERR.rawValue {
            errMsg.append(NSLocalizedString("err_unrecover", comment:""))
        }
    
        if status!.errorStatus == EPOS2_AUTORECOVER_ERR.rawValue {
            if status!.autoRecoverError == EPOS2_HEAD_OVERHEAT.rawValue {
                errMsg.append(NSLocalizedString("err_overheat", comment:""))
                errMsg.append(NSLocalizedString("err_head", comment:""))
            }
            if status!.autoRecoverError == EPOS2_MOTOR_OVERHEAT.rawValue {
                errMsg.append(NSLocalizedString("err_overheat", comment:""))
                errMsg.append(NSLocalizedString("err_motor", comment:""))
            }
            if status!.autoRecoverError == EPOS2_BATTERY_OVERHEAT.rawValue {
                errMsg.append(NSLocalizedString("err_overheat", comment:""))
                errMsg.append(NSLocalizedString("err_battery", comment:""))
            }
            if status!.autoRecoverError == EPOS2_WRONG_PAPER.rawValue {
                errMsg.append(NSLocalizedString("err_wrong_paper", comment:""))
            }
        }
        if status!.batteryLevel == EPOS2_BATTERY_LEVEL_0.rawValue {
            errMsg.append(NSLocalizedString("err_battery_real_end", comment:""))
        }
        if (status!.removalWaiting == EPOS2_REMOVAL_WAIT_PAPER.rawValue) {
            errMsg.append(NSLocalizedString("err_wait_removal", comment:""))
        }
        if (status!.unrecoverError == EPOS2_HIGH_VOLTAGE_ERR.rawValue ||
            status!.unrecoverError == EPOS2_LOW_VOLTAGE_ERR.rawValue) {
            errMsg.append(NSLocalizedString("err_voltage", comment:""));
        }
    
        return errMsg as String
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DiscoveryView" {
            let view: DiscoveryViewController? = segue.destination as? DiscoveryViewController
            view?.delegate = self
        }
    }
    func discoveryView(_ sendor: DiscoveryViewController, onSelectPrinterTarget target: String) {
        textTarget.text = target
    }
}

