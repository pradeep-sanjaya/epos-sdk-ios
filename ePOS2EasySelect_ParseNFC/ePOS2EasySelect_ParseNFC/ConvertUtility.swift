import Foundation

class ConvertUtility {
    
    // MARK: - Contants
    
    private struct Const {
        static let EPOS2_ConnectionTypeString_TCP = "TCP"
        static let EPOS2_ConnectionTypeString_BT = "BT"
    }
    
    // MARK: - Utility for Epos2Printer parameter
    
    static func convertPrinterNameToPrinterSeries(printerName: String) -> CInt {
        var printerSeries: CInt = EPOS2_TM_T88.rawValue
        
        if printerName == "TM-T88V" || printerName == "TM-T88VI" {
            printerSeries = EPOS2_TM_T88.rawValue
        } else if printerName == "TM-m10" {
            printerSeries = EPOS2_TM_M10.rawValue
        } else if printerName == "TM-m30" {
            printerSeries = EPOS2_TM_M30.rawValue
        } else if printerName == "TM-P20" {
            printerSeries = EPOS2_TM_P20.rawValue
        } else if printerName == "TM-P60II" {
            printerSeries = EPOS2_TM_P60II.rawValue
        } else if printerName == "TM-P80" {
            printerSeries = EPOS2_TM_P80.rawValue
        } else if printerName == "TM-H6000V" {
            printerSeries = EPOS2_TM_H6000.rawValue
        } else if printerName == "TM-m30II" || printerName.hasPrefix("TM-m30II-") {
            printerSeries = EPOS2_TM_M30II.rawValue
        } else if printerName == "TM-m50" {
            printerSeries = EPOS2_TM_M50.rawValue
        } else if printerName == "TM-T88VII" {
            printerSeries = EPOS2_TM_T88VII.rawValue
        } else if printerName == "TM-L100" {
            printerSeries = EPOS2_TM_L100.rawValue
        } else if printerName == "TM-P20II" {
            printerSeries = EPOS2_TM_P20II.rawValue
        } else if printerName == "TM-P80II" {
            printerSeries = EPOS2_TM_P80II.rawValue
        } else if printerName == "TM-m30III" || printerName.hasPrefix("TM-m30III-") {
            printerSeries = EPOS2_TM_M30III.rawValue
        } else if printerName == "TM-m50II" || printerName.hasPrefix("TM-m50II-") {
            printerSeries = EPOS2_TM_M50II.rawValue
        } else if printerName == "TM-m55" {
            printerSeries = EPOS2_TM_M55.rawValue
        } else {
            // if you use other printer , add convert printerSeries
        }
        
        return printerSeries
    }
    
    
    // MARK: - convert EposEasySelectInfo to Epos2Printer parameter
    
    static func convertEasySelectInfoToTargetString(info: EposEasySelectInfo?) -> String {
        guard let deviceType = info?.deviceType, let macAddress = info?.macAddress else {
            return ""
        }
        
        let connectionTypeString = convertDeviceTypeToConnectionTypeString(deviceType: deviceType)
        
        return "\(connectionTypeString):\(macAddress)"
    }
    
    static func convertDeviceTypeToConnectionTypeString(deviceType: CInt) -> String {
        var connectionTypeString = ""
        
        switch deviceType {
        case EPOS_EASY_SELECT_DEVTYPE_TCP.rawValue:
            connectionTypeString = Const.EPOS2_ConnectionTypeString_TCP
        case EPOS_EASY_SELECT_DEVTYPE_BLUETOOTH.rawValue:
            connectionTypeString = Const.EPOS2_ConnectionTypeString_BT
        default:
            break
        }
        
        return connectionTypeString
    }
    
    
    // MARK: - Handle EposEasySelectDeviceType
    
    static func convertEposConnectionTypeToInterfaceString(connectionType: CInt) -> String {
        switch connectionType {
        case EPOS_EASY_SELECT_DEVTYPE_BLUETOOTH.rawValue:
            return "Bluetooth"
        case EPOS_EASY_SELECT_DEVTYPE_TCP.rawValue:
            return "Network"
        default:
            return ""
        }
    }
}
