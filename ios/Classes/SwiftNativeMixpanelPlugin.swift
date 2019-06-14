import Flutter
import UIKit

import Mixpanel

@objc public class SwiftNativeMixpanelPlugin: NSObject, FlutterPlugin {
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "native_mixpanel", binaryMessenger: registrar.messenger())
    let instance = SwiftNativeMixpanelPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func getPropsFromArguments(callArguments: Any?) throws -> Properties? {

    if let arguments = callArguments, let data = (arguments as! String).data(using: .utf8) {
      return try JSONSerialization.jsonObject(with: data, options: []) as! [String:String]
    }
    return nil;
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult)  {
    do {
      
      switch(call.method) {
      case "initialize":
        Mixpanel.initialize(token: call.arguments as! String)
        break;
      case "setUserId":
        Mixpanel.mainInstance().identify(distinctId: call.arguments as! String)
        break;
      case "setProfileProps":
        if let properties = try self.getPropsFromArguments(callArguments: call.arguments) {
          Mixpanel.mainInstance().people.set(properties: properties)
        }
        break;
      case "reset":
        Mixpanel.mainInstance().reset()
        break;
      default:
        if let properties = try self.getPropsFromArguments(callArguments: call.arguments) {
          Mixpanel.mainInstance().track(event: call.method, properties: properties)
        }
        break;
      }

      result(true)
    } catch {
      print(error.localizedDescription)
      result(false)
    }
  }
}
