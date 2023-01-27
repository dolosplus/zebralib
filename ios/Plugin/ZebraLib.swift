import Foundation
import ExternalAccessory
import UIKit
import Capacitor

enum CommonPrintingFormat: String {
    case start = "! 0 200 200 150 1"
    case end = "\nFORM\nPRINT\n"
}

public class ImageSize : NSObject{
    var x: Int = 0
    var y: Int = 0
    var width: Int = -1
    var height: Int = -1

    init(x: Int, y: Int,width:Int, height: Int) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }
}


@objc public class ZebraLib: NSObject {
    
    enum ValidationError: Error {
          case notConnected
          case failedToPrint
    }
    
    var manager: EAAccessoryManager!
    var isConnected: Bool = false
    var connectionDelegate: EAAccessoryManagerConnectionStatusDelegate?
    private var printerConnection: MfiBtPrinterConnection?
    private var serialNumber: String?
    private var disconnectNotificationObserver: NSObjectProtocol?
    private var connectedNotificationObserver: NSObjectProtocol?
    private var zebraPrinter:ZebraPrinter?
    private var zebraPrinterConnection:ZebraPrinterConnection?
    private var paperSize: ImageSize?
    static let sharedInstance = ZebraLib()
    
    public override init() {
        super.init()
        print("::CAPACITOR:ZEBRALIB: ZebraLib.init()")
 
    }
    
    public func initPrinterConnection() throws{
        self.manager = EAAccessoryManager.shared()
        self.findConnectedPrinter { [weak self] bool in
            if let strongSelf = self {
                strongSelf.isConnected = bool
            }
        }
        //setup Observer Notifications
        disconnectNotificationObserver = NotificationCenter.default.addObserver(forName: Notification.Name.EAAccessoryDidDisconnect, object: nil, queue: nil, using: didDisconnect)
        connectedNotificationObserver = NotificationCenter.default.addObserver(forName: Notification.Name.EAAccessoryDidConnect, object: nil, queue: nil, using: didConnect)
        
        
        manager.registerForLocalNotifications()
        
        print("::CAPACITOR:ZEBRALIB: ZebraLib.initPrinterConnection()",self.isConnected)
        
        guard self.isConnected else{
            throw ValidationError.notConnected
        }
    }
    
    
    private func didDisconnect(notification: Notification) {
        isConnected = false
        connectionDelegate?.changePrinterStatus()
        print("::CAPACITOR:ZEBRALIB: ZebraLib.didDisconnect()")
    }

    private func didConnect(notification: Notification) {
        isConnected = true
        connectionDelegate?.changePrinterStatus()
        print("::CAPACITOR:ZEBRALIB: ZebraLib.didConnect()")
    }
    
    deinit {
        if let disconnectNotificationObserver = disconnectNotificationObserver {
            NotificationCenter.default.removeObserver(disconnectNotificationObserver)
        }
        if let connectedNotificationObserver = connectedNotificationObserver {
            NotificationCenter.default.removeObserver(connectedNotificationObserver)
        }
    }
    
    private func initZebraPrinter() {
        
        DispatchQueue.global(qos: .userInitiated).async
        {
        
            do{
                print("::CAPACITOR:ZEBRALIB: ZebraLib.initZebraPrinter()")
                self.zebraPrinter   =  try? ZebraPrinterFactory.getInstance(self.printerConnection)
                let lang =  self.zebraPrinter?.getControlLanguage()
                print("::CAPACITOR:ZEBRALIB: Printer Lang: \(String(describing: lang))")
            }catch{
                print("ERROR: connectToPrinter \(error)")
            }
            
            DispatchQueue.main.async(execute: {
               // completion(true)
                print("Done assigning printer")
            })
        }
      
    }
    
    private func connectToPrinter( completion: (Bool) -> Void) {
        
        print("::CAPACITOR:ZEBRALIB: connectToPrinter()",serialNumber)
        
        printerConnection = MfiBtPrinterConnection(serialNumber: serialNumber)
        printerConnection?.open()
        printerConnection?.setTimeToWaitAfterWriteInMilliseconds(60)
        initZebraPrinter()
        print("::CAPACITOR:ZEBRALIB: connectToPrinter() COMPLETE" )
        completion(true)
        
    }
    
    func closeConnectionToPrinter() {
        printerConnection?.close()
    }

    
    func printBase64PDFPages(base64: String)->Bool{

        
        let pdfDoc:CGPDFDocument = base64TOPDFDoc(base64String: base64)
        if(pdfDoc.numberOfPages>0){
            for n in 1...(pdfDoc.numberOfPages) {
                print("PDF page:\(n)")
                //convert pdf page to an image
                let imagePDF = pdfPageToImage(pdfPage: pdfDoc.page(at: n)!)
                //displayPDFPage(imagePage: imagePDF)
                do{
                    try printImage(image: imagePDF)
                }catch{
                    print("::CAPACITOR:ZEBRALIB: ERROR: printBase64PDFPages()",error)
                    return false;
                }
            }
        }
        
        return true
        
    }
    
    func pdfPageToImage(pdfPage:CGPDFPage) -> UIImage{
        
        let pageRect = pdfPage.getBoxRect(.mediaBox)
        let renderer = UIGraphicsImageRenderer(size: pageRect.size)
        let img = renderer.image { ctx in
              UIColor.white.set()
              ctx.fill(pageRect)

              ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height)
              ctx.cgContext.scaleBy(x: 1.0, y: -1.0)

              ctx.cgContext.drawPDFPage(pdfPage)
          }

        return img;
    }
    
    func base64TOPDFDoc(base64String: String?) -> CGPDFDocument{
        
        let dataDecodedPDF = NSData(base64Encoded: base64String!, options: NSData.Base64DecodingOptions(rawValue: 0))!
        
        let pdfData = dataDecodedPDF as CFData
        let provider:CGDataProvider = CGDataProvider(data: pdfData)!
        let pdfDoc:CGPDFDocument = CGPDFDocument(provider)!
        
        return pdfDoc
     }
    
    func printImage(image: UIImage) throws -> Bool {
        do {
            print("::CAPACITOR:ZEBRALIB: printImage() Image Size: ",image.size)
            //print("::CAPACITOR:ZEBRALIB: printImage() size:...",(self.paperSize? as AnyObject).x)
            weak var graphicsUtil = self.zebraPrinter?.getGraphicsUtil()

            //image size 72-96px, 208  per inch PPI
            //paper size 384x288 per sq in
//            let success:Any = try graphicsUtil?.print(
//                image.cgImage,
//                atX: 0,
//                atY: 0,
//                withWidth: 768,
//                withHeight: 576,
//                andIsInsideFormat: false) as Any
            //3x1 label, offset x=104
//            let marginX = 26, offset=13
//            let success:Any = try graphicsUtil?.print(
//                image.cgImage,
//                atX: 0,
//                atY: 0+offset,
//                withWidth: 624-marginX,
//                withHeight: 208-marginX,
//                andIsInsideFormat: false) as Any
            
            //4x3 label
//            let success:Any = try graphicsUtil?.print(
//                image.cgImage,
//                atX: 0,
//                atY: 0,
//                withWidth: 832,
//                withHeight: 624,
//                andIsInsideFormat: false) as Any
            
//            let success:Any = try graphicsUtil?.print(
//                image.cgImage,
//                atX: 0,
//                atY: 0,
//                withWidth: -1,
//                withHeight: -1,
//                andIsInsideFormat: false) as Any
            
            print("::CAPACITOR:ZEBRALIB: PEPER SIZE x: ",self.paperSize?.x)
            print("::CAPACITOR:ZEBRALIB: PEPER SIZE y: ",self.paperSize?.y)
            print("::CAPACITOR:ZEBRALIB: PEPER SIZE width: ",self.paperSize?.width)
            print("::CAPACITOR:ZEBRALIB: PEPER SIZE height: ",self.paperSize?.height)
            
            let success:Any = try graphicsUtil?.print(
                    image.cgImage,
                    atX: self.paperSize!.x,
                    atY: self.paperSize!.y,
                    withWidth: self.paperSize!.width,
                    withHeight: self.paperSize!.height,
                andIsInsideFormat: false) as Any

            
            
            print("::CAPACITOR:ZEBRALIB: print status: ",success)
            if(success != nil){
                return true
            }else{
                return false
            }
     
        } catch {
            print("::CAPACITOR:ZEBRALIB: ERROR: printImage()",error)
            throw error
        }
    }
    
    
    func printTextLabel(label: String){
        if let data = printOneLineText(textContent: label).data(using: .utf8) {
            writeToPrinter(with: data)
        }
    }
    
    private func printOneLineText(textContent: String)->String{
        let firstText = printerTextField(font: 4, size: 0 , x: 30, y: 0, content: textContent)
        return "\(CommonPrintingFormat.start.rawValue) \n\(firstText)\(CommonPrintingFormat.end.rawValue)"
    }
    
    private func printerTextField(font:Int, size: Int, x:Int, y: Int, content: String) -> String {
        return "TEXT \(font) \(size) \(x) \(y) \(content)"
    }

    
    public func writeToPrinter(with data: Data) {
        print("::CAPACITOR:ZEBRALIB: writeToPrinter()")
        print(String(data: data, encoding: String.Encoding.utf8) as String? as Any)
        connectToPrinter(completion: { _ in
            var error:NSError?
            printerConnection?.write(data, error: &error)
       
            if error != nil {
                print("Error executing data writing \(String(describing: error))")
            }
            print("::CAPACITOR:ZEBRALIB: ================================= done printing ================================================")
        })
    }

    
    private func findConnectedPrinter(completion: (Bool) -> Void) {
        let connectedDevices = self.manager.connectedAccessories
        print("::CAPACITOR:ZEBRALIB: findConnectedPrinter(): ",connectedDevices.count)
        for device in connectedDevices {
            if device.protocolStrings.contains("com.zebra.rawport") {
                serialNumber = device.serialNumber
                connectToPrinter(completion: { completed in
                    completion(completed)
                })
            }
        }
    }

//    @objc public func echo(_ value: String) -> String {
//        print("::CAPACITOR:ZEBRALIB: echo() - ")
//        //initPrinterConnection();
//        return value
//    }

    @objc public func printPDF(_ base64: String,size: ImageSize) -> Bool {
        self.paperSize = size
        //let json = try JSONSerialization.jsonObject(with: size as! Data)
        //var dictonary:NSDictionary?

        print("::CAPACITOR:ZEBRALIB: printPDF() size:...",self.paperSize?.x)
        //dictonary = try JSONSerialization.jsonObject(with: size, options: []) as? [String:AnyObject]
        
        //print("::CAPACITOR:ZEBRALIB: printPDF() size:...",self.paperSize?.value(forKey: "width") as Any)
        //print("::CAPACITOR:ZEBRALIB: printPDF() json:...",json)
        print("::CAPACITOR:ZEBRALIB: printPDF() data:...",base64.prefix(10))//only log partial data
        return printBase64PDFPages(base64: base64)
    }


    @objc public func printText(_ text: String) -> String {
        print("::CAPACITOR:ZEBRALIB: printText() - calling Zebralib in echo Swift",text)
        printTextLabel(label: text)
        print("::CAPACITOR:ZEBRALIB: printText() - Done calling MfiBtPrinterConnection")
        return "some result=" + text;
    }

    @objc public func connectPrinter(_ value: String) -> Bool {
        do{
            print("::CAPACITOR:ZEBRALIB: Done connectPrinter()")
            try initPrinterConnection();
            return true
        } catch {
            let message = "Failed to connect -  error: \(error)"
            print(message)
            return false
        }
     }

}

protocol EAAccessoryManagerConnectionStatusDelegate {
    func changePrinterStatus() -> Void
}

//extension ZebraLib: EAAccessoryManagerConnectionStatusDelegate {
//    func changeLabelStatus() {
//
//        print("changeLabelStatus()----> \(String(describing: isConnected))")
//    }
//}
