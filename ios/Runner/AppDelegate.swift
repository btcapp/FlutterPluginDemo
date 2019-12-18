import UIKit
import Flutter



@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    var type = 1;
    //将FlutterResult对象暂存，点击事件时候回调图片数据给Flutter端
    var fResult:Any? = 1;
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self);
        
        let controller:FlutterViewController = window.rootViewController as! FlutterViewController;
        //name 和 flutter端一致
        let fChannel = FlutterMethodChannel(name: "samples.flutter.io/systemChannel", binaryMessenger: controller as! FlutterBinaryMessenger)
        fChannel.setMethodCallHandler { (call, result) in
            print("flutter 给到我 method:\(call.method) arguments:\(String(describing: call.arguments))")
            
            //字典接收，对应于flutter端的map类型
            let dictionary =  call.arguments as! [String:Any?];
            
            self.fResult = result;
            
            if "getVersion" == call.method{//获取版本号
                //单纯测试字符串参数接收
                let par:String = dictionary["param"] as! String;
                print("getVersion-param=\(par))");
                
                //回调版本数据
                result(self.getVersion());
            }
            else if "imageChannel" == call.method{//传递图片二进制数据
                //图片字节数据
                let fdata:FlutterStandardTypedData = dictionary["value"] as! FlutterStandardTypedData;
                self.type = dictionary["type"] as! Int;
                print("imageChannel-type=\(self.type))");
                let newImage = UIImage(data:fdata.data);
                self.imageView.image = newImage;
                self.button.addTarget(self, action: #selector(self.didSelectButtonClick), for: .touchUpInside);
                
                self.togglePanel(hide: false);
            }
            else{
                result(FlutterMethodNotImplemented);
            }
        }
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    //获取版本号，可以修改为真正版本号获取方式
    func getVersion() ->String{
        return "IOS v6.0.1";
    }
    
    //切换原生控件显示和删除
    func togglePanel(hide:Bool) ->Void{
        if(!hide) {
            self.window.addSubview(self.imageView);
            self.window.addSubview(self.button);
        } else {
            self.imageView.removeFromSuperview();
            self.button.removeFromSuperview();
        }
        
    }
    
    lazy var button : UIButton = {
        let object = UIButton();
        object.backgroundColor = UIColor.gray;
        object.setTitle("原生图片传递给Flutter端显示", for: .normal);
        object.center = CGPoint.init(x: UIScreen.main.bounds.size.width/2, y: UIScreen.main.bounds.size.height/2);
        object.frame = CGRect(x:10, y:184, width:300, height:50);
        return object;
    }()
    
    lazy var imageView : UIImageView = {
        let object = UIImageView(image:UIImage(named:"test"));
        object.frame = CGRect(x:10, y:30, width:300, height:150);
        return object;
    }()
    
    @objc func didSelectButtonClick() {
        print("didSelectButtonClick");
        self.togglePanel(hide:true);
        if(self.type == 1) {
            //加载本地图片数据
            guard let imagel = UIImage(named: "test") else {return};
            guard let rep1 = UIImageJPEGRepresentation(imagel,1.0) else {return };
            let result = self.fResult as! FlutterResult;
            //回调flutter端
            result(rep1);
        } else{
            guard let image2 = UIImage(named: "tess") else {return };
            guard let rep2 = UIImageJPEGRepresentation(image2,1.0) else {return };
            let result = self.fResult as! FlutterResult;
            result(rep2);
        }
    }
    
}
