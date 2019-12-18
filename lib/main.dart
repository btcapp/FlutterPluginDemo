import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter与原生平台数据交互Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _systemVersion = '未知系统版本号：';
  Uint8List bytes;
  Uint8List bytes1;

  static const platform =
      const MethodChannel('samples.flutter.io/systemChannel');

  @override
  void initState() {
    print("-----initState");

    rootBundle.load('asset/images/testb.png').then((data) {
      if (mounted) {
        setState(() {
          bytes = data.buffer.asUint8List();
        });
      }
    });

    var sunImage = new NetworkImage(
        'http://www.6mi8.com/wp-content/plugins/webriti-companion//inc/quality/images/portfolio/home-port2.jpg');

    sunImage.obtainKey(ImageConfiguration()).then((val) {
      var load =
          sunImage.load(val, PaintingBinding.instance.instantiateImageCodec);
      print("-----ImageConfiguration");
      ImageStreamListener listener = ImageStreamListener(
          (image, call) {
            image.image
                //注意这里参数为ImageByteFormat.png，其他报错
                .toByteData(format: ImageByteFormat.png)
                .then((value) {
              Uint8List temp = value.buffer.asUint8List();
              if (temp != null) {
                setState(() {
                  bytes1 = temp;
                });
                print("-----bytes1 not null");
              }
            });
          },
          onChunk: (event) {},
          onError: (item, stackTrace) {
            print("-----onError =" +
                item.toString() +
                '-s=' +
                stackTrace.toString());
          });

      load.addListener(listener);
    });

    super.initState();
  }

  @override
  void didUpdateWidget(MyHomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    print("-----didUpdateWidget");
  }

  Future<Codec> decodeCoback(Uint8List uint8list,
      {int cacheWidth, int cacheHeight}) {
    print("-----decodeCoback =" + (bytes1 = null));
  }

  @override
  void deactivate() {
    super.deactivate();
    print("-----deactive");
  }

  @override
  void dispose() {
    super.dispose();
    print("-----dispose");
  }

  @override
  void reassemble() {
    super.reassemble();
    print("-----reassemble");
  }

  Future<Null> _getSystemVersion() async {
    String systemVersion;
    try {
      final String result =
          await platform.invokeMethod('getVersion', <String, dynamic>{
        //单纯测试原生接收参数
        'param': 'param value11111',
      });
      systemVersion = '系统版本： $result';
    } on PlatformException catch (e) {
      systemVersion = "Failed to get system version: '${e.message}'.";
    }
    // 在setState中来更新用户界面状态systemVersion
    setState(() {
      _systemVersion = systemVersion;
    });
  }

  Future<Null> _putFOtoOShow() async {
    Uint8List result;
    try {
      result = await platform.invokeMethod(
          'imageChannel', <String, dynamic>{'value': bytes, 'type': 1});
    } on PlatformException catch (e) {}
    if (result != null) {
      setState(() {
        bytes = result;
      });
    } else {
      print("-----_putFOtoOShow result null");
    }
  }

  Future<Null> _putFNtoOShow() async {
    Uint8List result;
    try {
      result = await platform.invokeMethod(
          'imageChannel', <String, dynamic>{'value': bytes1, 'type': 2});
    } on PlatformException catch (e) {}
    if (result != null) {
      setState(() {
        bytes1 = result;
      });
    } else {
      print("-----_putFOtoOShow result null");
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print("-----didChangeDependencies");
  }

  @override
  Widget build(BuildContext context) {
    print("-----build");
    final decoration = BoxDecoration(
      image: bytes == null
          ? null
          : DecorationImage(
              image: MemoryImage(bytes, scale: 1.0),
            ),
    );
    final decoration1 = BoxDecoration(
      image: bytes1 == null
          ? null
          : DecorationImage(
              image: MemoryImage(bytes1, scale: 1.0),
            ),
    );
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(_systemVersion),
              RaisedButton(
                child: Text("点击获取"),
                onPressed: _getSystemVersion,
              )
            ],
          ),
          Row(
            children: <Widget>[
              Container(
                width: 250.0,
                height: 250.0,
                decoration: decoration,
              ),
              RaisedButton(
                child: Text("Flutter \n本地图片\n传递原生端\n显示"),
                onPressed: _putFOtoOShow,
              )
            ],
          ),
          Row(
            children: <Widget>[
              Container(
                width: 250.0,
                height: 250.0,
                decoration: decoration1,
              ),
              RaisedButton(
                child: Text("Flutter \n网络图片\n传递原生端\n显示"),
                onPressed: _putFNtoOShow,
              )
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
