import UIKit
import Flutter
import NetworkExtension
import CoreLocation
import Foundation

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        _initializeChannels()
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func _initializeChannels() {
        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        
        let wifiChannel = FlutterMethodChannel(name: "com.example.poc_inova/wifi",
                                               binaryMessenger: controller.binaryMessenger)
        
        wifiChannel.setMethodCallHandler({
           [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
           if (call.method == "connectWifi") {
               let wifiEnabled = self!.isWifiEnabled() as Bool

               if wifiEnabled {
                   let configuration = NEHotspotConfiguration(ssid: "SmartLife-9487")
                   
                   NEHotspotConfigurationManager.shared.apply(configuration) {(error) in
                       if error != nil {
                           result(true)
                       } else {
                           result(false)
                       }
                   }
               } else {
                   result(false)
               }
           } else if (call.method == "disconnectWifi") {
               NEHotspotConfigurationManager.shared.getConfiguredSSIDs {(ssidsArray) in
                   for ssid in ssidsArray {
                       NEHotspotConfigurationManager.shared.removeConfiguration(forSSID: ssid)
                   }
                   result(true)
               }
           } else {
               result(FlutterMethodNotImplemented)
           }
       })
    }
    
    private func isWifiEnabled() -> Bool {
        var addrList : UnsafeMutablePointer<ifaddrs>?
        guard
            getifaddrs(&addrList) == 0,
            let firstAddr = addrList
        else { return false }
        defer { freeifaddrs(addrList) }
        
        for cursor in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = cursor.pointee
            let interfaceName = String(cString: interface.ifa_name)
            let addrFamily = interface.ifa_addr.pointee.sa_family
            let flags = Int32(interface.ifa_flags)
            
            if interfaceName == "awdl0" {
                if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                    if flags & IFF_UP == IFF_UP {
                        return true
                    } else {
                        return false
                    }
                }
            }
            
        }
        return false
    }
}
