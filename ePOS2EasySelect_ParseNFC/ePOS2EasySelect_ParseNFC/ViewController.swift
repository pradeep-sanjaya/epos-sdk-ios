import UIKit
import CoreNFC


class ViewController: UIViewController {
    
    // MARK: - Properties
    
    private var easySelectInfo: EposEasySelectInfo?
    private var printer: Epos2Printer?
    private var indicatorView: IndicatorView?
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var scanningStatusLabel: UILabel!
    @IBOutlet weak var stepDescriptionLabel: UILabel!
    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var targetNameLabel: UILabel!
    @IBOutlet weak var targetInterfaceLabel: UILabel!
    @IBOutlet weak var targetAddressLabel: UILabel!
    @IBOutlet weak var connectingLabel: UILabel!
    @IBOutlet weak var printButton: UIButton!
    
    // MARK: - Actions
    
    @IBAction func beginScanning(_ sender: Any) {
        beginScanningNFC()
    }
    
    @IBAction func printSample(_ sender: Any) {
        self.showIndicator()
        
        let isSuccess = runPrintSequence()
        
        if !isSuccess {
            self.hideIndicator()
            AlertUtility.localizableAlert(title: "title_error", message: "err_fail_print", buttonTitle: "button_ok", currentViewController: self)
        }
    }
    
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stepDescriptionLabel.text =
            NSLocalizedString("nfc_step_title", comment: "") + "\n\n" +
            NSLocalizedString("nfc_step_1", comment: "") + "\n" +
            NSLocalizedString("nfc_step_2", comment: "") + "\n" +
            NSLocalizedString("nfc_step_3", comment: "")
        
        roundButton(button: scanButton)
        roundButton(button: printButton)
        
        setupNFCScanning()
        
        connectingLabel.text = ""
        update(targetInfo: nil)
        update(isPrintEnabled: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func update(targetInfo: EposEasySelectInfo?) {
        if let targetInfo = targetInfo {
            targetNameLabel.text = targetInfo.printerName ?? ""
            targetInterfaceLabel.text = ConvertUtility.convertEposConnectionTypeToInterfaceString(connectionType: targetInfo.deviceType)
            targetAddressLabel.text = targetInfo.macAddress ?? ""
        } else {
            targetNameLabel.text = ""
            targetInterfaceLabel.text = ""
            targetAddressLabel.text = ""
        }
    }
    
    private func update(isPrintEnabled: Bool) {
        printButton.isEnabled = isPrintEnabled
    }
    
    private func roundButton (button: UIButton) {
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8.0
        button.layer.masksToBounds = true
        
        UIGraphicsBeginImageContext(button.bounds.size)
        let color = UIColor(red: 65/255, green: 114/255, blue: 1.0, alpha: 1.0).cgColor
        let rect = CGRect(origin: CGPoint.zero, size: button.bounds.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color)
        context?.fill(rect)
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        button.setBackgroundImage(colorImage, for: .normal)
    }
    
    private func setupNFCScanning() {
        let result = scanningNFCAvailable()
        
        scanningStatusLabel.text = result.message
        scanButton.isEnabled = result.isAvailable
    }
    
    private func showIndicator() {
        let indicatorView = IndicatorView()
        self.indicatorView = indicatorView
        indicatorView.show(baseView: UIApplication.shared.keyWindow)
    }
    
    private func hideIndicator() {
        guard let indicatorView = self.indicatorView else {
            return
        }
        
        indicatorView.hide()
        self.indicatorView = nil
    }
}

// MARK: - NFCNDEFReaderSessionDelegate
@available(iOS 11.0, *)
extension ViewController: NFCNDEFReaderSessionDelegate {
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        guard let targetList = EposEasySelect().parseNFC(messages, timeout: Int(PARSE_NFC_TIMEOUT_DEFAULT.rawValue)), !targetList.isEmpty else {
            DispatchQueue.main.async {
                AlertUtility.localizableAlert(title: "title_error", message: "err_fail_parse_nfc", buttonTitle: "button_ok", currentViewController: self)
            }
            return
        }
                
        var isPrintEnabled = false
        
        DispatchQueue.main.async {
            self.connectingLabel.text = NSLocalizedString("select_printer_connecting", comment: "")
            self.showIndicator()
        }
        
        for targetInfo in targetList {
            if targetInfo.printerName == nil || targetInfo.printerName.isEmpty {
                // Please specify the printer name of the use printers.
                targetInfo.printerName = "TM-T88V"
            }
            
            self.easySelectInfo = targetInfo

            DispatchQueue.main.async {
                self.update(targetInfo: targetInfo)
            }

            if isAlivePrinter(targetInfo: targetInfo) {
                isPrintEnabled = true
                break
            }
        }
        
        DispatchQueue.main.async {
            self.hideIndicator()
            self.connectingLabel.text = ""
            self.update(isPrintEnabled: isPrintEnabled)
            
            if !isPrintEnabled {
                AlertUtility.localizableAlert(title: "title_error", message: "err_fail_open_printer", buttonTitle: "button_ok", currentViewController: self)
            }
        }
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        if let readerError = error as? NFCReaderError {
            guard
                readerError.code != .readerSessionInvalidationErrorFirstNDEFTagRead,    // Success. (The single tag read mode)
                readerError.code != .readerSessionInvalidationErrorUserCanceled else {  // User canceled.
                return
            }
            
            DispatchQueue.main.async {
                AlertUtility.localizableAlert(title: "title_error", message: "err_fail_scan_nfc", buttonTitle: "button_ok", currentViewController: self)
                // Error detail: readerError.code, error.localizedDescription
            }
        }
    }
}

// MARK: - Scan & Parse NFC data
extension ViewController {
    
    func scanningNFCAvailable() -> (isAvailable: Bool, message: String) {
        var isAvailable = true
        var message = NSLocalizedString("nfc_device_supported", comment: "")
        
        if #available(iOS 11.0, *) {
            if !NFCNDEFReaderSession.readingAvailable {
                isAvailable = false
                message = NSLocalizedString("nfc_device_not_supported", comment: "")
            }
        } else {
            isAvailable = false
            message = NSLocalizedString("nfc_os_not_supported", comment: "")
        }
        
        return (isAvailable, message)
    }
    
    func beginScanningNFC() {
        if #available(iOS 11.0, *) {
            if NFCNDEFReaderSession.readingAvailable {
                let session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
                if session.alertMessage.isEmpty {
                    session.alertMessage = NSLocalizedString("nfc_provide_additional_context", comment: "")
                }
                session.begin()
            }
        }
    }
}

// MARK: - Epos2PtrReceiveDelegate
extension ViewController: Epos2PtrReceiveDelegate {
    
    func onPtrReceive(_ printerObj: Epos2Printer!, code: Int32, status: Epos2PrinterStatusInfo!, printJobId: String!) {
        self.hideIndicator()
        
        DispatchQueue.global(qos: .default).async{
            self.disconnectPrinter()
        }
        
        if code != EPOS2_SUCCESS.rawValue {
            AlertUtility.localizableAlert(title: "title_error", message: "err_fail_print", buttonTitle: "button_ok", currentViewController: self)
        }
    }
}

// MARK: - Printing Sequence
extension ViewController {
    
    func runPrintSequence() -> Bool {
        guard initializePrinter() else {
            return false
        }
        
        guard createkPritData() else {
            finalizePrinter()
            return false
        }
        
        guard printData() else {
            finalizePrinter()
            return false
        }
        
        return true
    }
    
    private func initializePrinter() -> Bool {
        
        guard let printerName = self.easySelectInfo?.printerName, !printerName.isEmpty else {
            return false
        }
        
        let printerSeries: CInt = ConvertUtility.convertPrinterNameToPrinterSeries(printerName: printerName)
        
        self.printer = Epos2Printer(printerSeries: printerSeries, lang: EPOS2_MODEL_ANK.rawValue)
        guard let printer = self.printer else {
            return false
        }
        
        printer.setReceiveEventDelegate(self)
        
        return true
    }
    
    private func finalizePrinter() {
        guard let printer = self.printer else {
            return
        }
        
        printer.clearCommandBuffer()
        printer.setReceiveEventDelegate(nil)
        
        self.printer = nil
    }
    
    private func connectPrinter() -> Bool {
        guard
            let printer = self.printer,
            let info = self.easySelectInfo,
            let macAddress = info.macAddress, !macAddress.isEmpty else {
            return false
        }
        
        let targetString = ConvertUtility.convertEasySelectInfoToTargetString(info: info)
        guard !targetString.isEmpty else {
            return false
        }
        
        var result = printer.connect(targetString, timeout: CLong(EPOS2_PARAM_DEFAULT))
        guard result == EPOS2_SUCCESS.rawValue else {
            return false
        }
        
        result = printer.beginTransaction()
        guard result == EPOS2_SUCCESS.rawValue else {
            printer.disconnect()
            return false
        }
        
        return true
    }
    
    func disconnectPrinter() {
        guard let printer = self.printer else {
            return
        }
        
        printer.endTransaction()
        printer.disconnect()
        
        finalizePrinter()
    }
    
    func isAlivePrinter(targetInfo: EposEasySelectInfo?) -> Bool {
        guard
            let targetInfo = targetInfo,
            let printerName = targetInfo.printerName, !printerName.isEmpty,
            let macAddress = targetInfo.macAddress, !macAddress.isEmpty else {
            return false
        }
        
        let printerSeries: CInt = ConvertUtility.convertPrinterNameToPrinterSeries(printerName: printerName)

        guard let printer = Epos2Printer(printerSeries: printerSeries, lang: EPOS2_MODEL_ANK.rawValue) else {
            return false
        }
        
        let targetString = ConvertUtility.convertEasySelectInfoToTargetString(info: targetInfo)
        guard !targetString.isEmpty else {
            return false
        }
        
        var result = printer.connect(targetString, timeout: CLong(EPOS2_PARAM_DEFAULT))
        guard result == EPOS2_SUCCESS.rawValue else {
            return false
        }
        
        result = printer.disconnect()
        guard result == EPOS2_SUCCESS.rawValue else {
            return false
        }
        
        return true
    }
    
    private func isPrintable(status: Epos2PrinterStatusInfo?) -> Bool {
        guard let status = status else {
            return false
        }
        
        if status.connection == EPOS2_FALSE {
            return false
        } else if status.online == EPOS2_FALSE {
            return false
        } else {
            // print available
        }

        return true
    }

    private func createkPritData() -> Bool {
        guard let printer = self.printer else {
            return false
        }
        
        var result: CInt = EPOS2_ERR_FAILURE.rawValue
        
        // Header
        result = printer.addText("--------------------")
        guard result == EPOS2_SUCCESS.rawValue else { return false }
        
        result = printer.addFeedLine(1)
        guard result == EPOS2_SUCCESS.rawValue else { return false }

        result = printer.addText("Sample Print")
        guard result == EPOS2_SUCCESS.rawValue else { return false }
        
        result = printer.addFeedLine(1)
        guard result == EPOS2_SUCCESS.rawValue else { return false }
        
        result = printer.addText("--------------------")
        guard result == EPOS2_SUCCESS.rawValue else { return false }
        
        result = printer.addFeedLine(2)
        guard result == EPOS2_SUCCESS.rawValue else { return false }
        
        // DeviceName
        result = printer.addText(self.easySelectInfo?.printerName)
        guard result == EPOS2_SUCCESS.rawValue else { return false }
        
        result = printer.addFeedLine(1)
        guard result == EPOS2_SUCCESS.rawValue else { return false }
        
        // Address
        var interfaceName = ""
        if let deviceType = self.easySelectInfo?.deviceType {
            interfaceName = ConvertUtility.convertEposConnectionTypeToInterfaceString(connectionType: deviceType)
        }
        let address = "\(interfaceName) Address:\(self.easySelectInfo?.macAddress ?? "")"
        result = printer.addText(address)
        guard result == EPOS2_SUCCESS.rawValue else { return false }
        
        // Footer Message
        result = printer.addFeedLine(5)
        guard result == EPOS2_SUCCESS.rawValue else { return false }
        
        result = printer.addTextAlign(EPOS2_ALIGN_CENTER.rawValue)
        guard result == EPOS2_SUCCESS.rawValue else { return false }

        result = printer.addText("Print successfully!!")
        guard result == EPOS2_SUCCESS.rawValue else { return false }
        
        result = printer.addFeedLine(2)
        guard result == EPOS2_SUCCESS.rawValue else { return false }
        
        // CUT
        result = printer.addCut(EPOS2_CUT_FEED.rawValue)
        guard result == EPOS2_SUCCESS.rawValue else { return false }
        
        return true
    }
    
    private func printData() -> Bool {
        guard let printer = self.printer else {
            return false
        }
        
        guard connectPrinter() else {
            return false
        }
        
        let status = printer.getStatus()
        guard isPrintable(status: status) else {
            printer.disconnect()
            return false
        }
        
        let result = printer.sendData(Int(EPOS2_PARAM_DEFAULT))
        guard result == EPOS2_SUCCESS.rawValue else {
            printer.disconnect()
            return false
        }
        
        return true
    }
}
