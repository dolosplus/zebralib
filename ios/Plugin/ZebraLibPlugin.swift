import Foundation
import Capacitor


/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(ZebraLibPlugin)
public class ZebraLibPlugin: CAPPlugin {
    
    //private var observers: [NSObjectProtocol] = []
    private var zebra = ZebraLib.sharedInstance

//    @objc func echo(_ call: CAPPluginCall) {
//        let value = call.getString("value") ?? ""
//        call.resolve([
//            "value": zebra.echo(value)
//        ])
//    }

    override public func load() {
        print("Loading Zebra plugin")
        //start extension delegate
        zebra.connectionDelegate = self
    }
    
    deinit {
        print("Deinitialize Zebra plugin")
    }

    @objc func connectPrinter(_ call: CAPPluginCall) {
        let config = call.getString("config") ?? ""
        
        let status = zebra.connectPrinter(config)
        if(status){
            call.resolve(["result": status])
        }else{
            call.reject("Failed to connect to printer")
        }
        
//        guard canConnect
//          call.resolve([
//            "result":  zebra.connectPrinter(value)
//        ])
       
    }


    @objc func printText(_ call: CAPPluginCall) {
        let text = call.getString("text") ?? ""
        call.resolve([
            "result": zebra.printText(text)
        ])
    }


    @objc func printPDF(_ call: CAPPluginCall) {
        let base64 = call.getString("base64") ?? ""
        let size: JSObject = call.getObject("size") ?? [:]
        print("ZebraLibPlugin:printPDF() size:",size.keys)
        var status: Bool = false
//        var error:NSError?
//        if JSONSerialization.JSONObjectWithData(size,  options: error) as! NSDictionary == nil{
//
//        }
        
        if size.isEmpty{
            print("size is empty")
            let imgSize: ImageSize = ImageSize(x: 0,y: 0,width: -1,height: -1)
            status = zebra.printPDF(base64,size: imgSize)
        }else{
            print(size.keys)
            print(size.values)
            let x = size["x"] as? Int ?? 0
            let y = size["y"] as? Int ?? 0
            let width = size["width"] as? Int ?? 0
            let height = size["height"] as? Int ?? 0
            //print("test=",test)
            let imgSize: ImageSize = ImageSize(x: x ,y: y,width: width,height: height)
            status = zebra.printPDF(base64,size: imgSize)
        }
        
        
//        if JSONSerialization.isValidJSONObject(size){
//        //if let json = try JSONSerialization.JSONObjectWithData(size,options: JSONSerialization.ReadingOptions(rawValue: 0)) as? [JSObject: Any] {
//            let imgSize: ImageSize = ImageSize(x: 0,y: 0,width: -1,height: -1)
//            status = zebra.printPDF(base64,size: imgSize)
//        }else{
//            let str = "{\"x\": 0,\"y\": 0,\"width\": -1,\"height\": -1}"
//            //{x:number,y:number,width:number, height:number}
//
//            let data = Data(str.utf8)
//
//            do {
//                // make sure this JSON is in the format we expect
//                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
//                    print(json)
//                    status = zebra.printPDF(base64,size: json as NSObject as! ImageSize)
//                }
//            } catch let error as NSError {
//                print("Failed to load: \(error.localizedDescription)")
//            }
//
//        }
//        if error != nil {
//            print("Error executing data writing \(String(describing: error))")
//        }

        
        //let status = zebra.printPDF(base64,size)
        if(status){
            print("ZebraLibPlugin:printPDF() result",status)
            call.resolve(["result": status])
        }else{
            call.reject("Failed to connect to printer")
        }
        
        
    }


}

extension ZebraLibPlugin: EAAccessoryManagerConnectionStatusDelegate {
    func changePrinterStatus() {
        print("changePrinterStatus()----> \(String(describing: zebra.isConnected))")
        notifyListeners("printerStatusChange", data: ["isActive": zebra.isConnected])
    }
}
