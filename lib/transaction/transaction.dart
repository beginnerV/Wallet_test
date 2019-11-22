import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:sacco/sacco.dart';
import '../wallet/wallet.dart';

class TransactionScreen extends StatefulWidget {
  @override
  _TransactionState createState() => _TransactionState();
}

class _TransactionState extends State<TransactionScreen>
    with SingleTickerProviderStateMixin {
  TextEditingController _addrController = TextEditingController();
  TextEditingController _gasController = TextEditingController();
  TextEditingController _valueController = TextEditingController();
  TextEditingController _gasPriceController = TextEditingController();
  GlobalKey _formKey = new GlobalKey<FormState>();
  String _address;
  String _val;
  String _gas;
  String _gasPrice;
  Dio dio = Dio();
  Response response;
  TabController _tabController;
  String _Txaddress; //二维码地址
  String barcode = "";

  @override
  void _forSubmitted() async {
    var TxInfo;
    var TxHash;

    //                Navigator.push(context,
    //  new MaterialPageRoute(builder: (context) {
    //  return ArticleDetail();
    // }));
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if ((_formKey.currentState as FormState).validate()) {
      print(prefs.getString("address"));
      print(
          "地址：${_addrController.text}，数量：${_valueController.text}，ges：${_gasController.text}，gesPrice：${_gasPriceController.text}");
      final message = StdMsg(
        type: "cosmos-sdk/MsgSend",
        value: {
          "from_address": prefs.getString("address"),
          "to_address": "cosmos1awtc8q5h8t692sl63m9833vsmepxncw7wdeqsw",
          "amount": [
            {"denom": "zcoin", "amount": _valueController.text}
          ]
        },
      );

      final stdTx = TxBuilder.buildStdTx(stdMsgs: [message]);
      // 获取钱包对象
      // Wallet wa = await wallet();

      final signedStdTx = await TxSigner.signStdTx(wallet: wa, stdTx: stdTx);
      final result = await TxSender.broadcastStdTx(
        wallet: wa,
        stdTx: signedStdTx,
      );

      // Check the result
      if (result.success) {
        print("Tx send successfully. Hash: ${result.hash}");
        TxInfo = result.hash == "" ? "交易失败！" : "交易成功！";
        TxHash = result.hash == "" ? "" : "交易哈希：${response.data["Txaddress"]}";
      } else {
        print("Tx send error: ${result.error.errorMessage}");
      }

      print("交易：${TxInfo}");
      print("交易：${TxHash}");

      showDialog<Null>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: new Text(TxInfo.toString()),
            content: new SingleChildScrollView(
              child: new ListBody(
                children: <Widget>[
                  new Text(TxHash.toString()),
                ],
              ),
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text('确定'),
                onPressed: () {
                  _addrController.text = "";
                  _valueController.text = "";
                  _gasController.text = "";
                  _gasPriceController.text = "";
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      ).then((val) {
        print("---" + val);
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void Addr() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _Txaddress = prefs.getString("address");
    });
  }

  void initState() {
    super.initState();
    _tabController = new TabController(vsync: this, length: 2);
    Addr();
  }

  Future scan() async {
    try {
      String barcode = await BarcodeScanner.scan();
      setState(() {
        return this.barcode = barcode;
      });
      setState(() {
        return this._addrController.text = barcode;
      });
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          return this.barcode = '未授予APP相机权限';
        });
      } else {
        setState(() {
          return this.barcode = '扫码错误: $e';
        });
      }
    } on FormatException {
      setState(() => this.barcode = '进入扫码页面后未扫码就返回');
    } catch (e) {
      setState(() => this.barcode = '扫码错误: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return new DefaultTabController(
      length: 2,
      child: new Scaffold(
        appBar: new AppBar(
          title: new TabBar(
            indicatorColor: Colors.black54,
            tabs: <Widget>[
              new Tab(
                text: "转账",
              ),
              new Tab(
                text: "收款",
              )
            ],
            controller: _tabController,
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.camera_alt),
              onPressed: scan,
            ),
          ],
          automaticallyImplyLeading: false, //是否显示返回箭头
        ),
        body: new TabBarView(
          controller: _tabController,
          children: <Widget>[
            new Center(
              child: Form(
                key: _formKey, //设置globalKey，用于后面获取FormState
                child: new ListView(
                    padding: EdgeInsets.symmetric(horizontal: 22.0),
                    children: [
                      Container(
                        // width: 340,
                        padding: EdgeInsets.only(top: 30),
                        child: Text("输入对方钱包地址，或通过扫描钱包地址生成的二维码录入。",
                            style:
                                TextStyle(fontSize: 16, color: Colors.black45)),
                      ),
                      // Divider(),
                      TextFormField(
                        keyboardType: TextInputType.text,
                        controller: _addrController,
                        decoration: InputDecoration(
                            labelText: "对方钱包地址",
                            hintText: "",
                            prefixIcon: Icon(Icons.person)),
                        //校验地址
                        validator: (v) {
                          return v.trim().length > 0 ? null : "地址不能为空";
                        },
                        onSaved: (val) {
                          setState(() {
                            _address = val;
                          });
                        },
                      ),
                      TextFormField(
                        // autofocus: true, //开启自动校验
                        controller: _valueController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            labelText: "交易数量",
                            hintText: "",
                            prefixIcon: Icon(Icons.grain)),
                        //校验数量
                        validator: (v) {
                          return v.isEmpty ? "数量不能为空" : null;
                        },
                        onSaved: (val) {
                          setState(() {
                            _val = val;
                          });
                        },
                      ),
                      TextFormField(
                        // autofocus: true,
                        controller: _gasController,
                        decoration: InputDecoration(
                            labelText: "gas",
                            hintText: "可选",
                            prefixIcon: Icon(Icons.linear_scale)),
                        onSaved: (val) {
                          setState(() {
                            _gas = val;
                          });
                        },
                      ),
                      TextFormField(
                        // autofocus: true,
                        controller: _gasPriceController,
                        decoration: InputDecoration(
                            labelText: "gasPrice",
                            hintText: "可选",
                            prefixIcon: Icon(Icons.scatter_plot)),
                        onSaved: (val) {
                          _gasPrice = val;
                        },
                      ),
                      SizedBox(height: 35.0),
                      Align(
                        child: SizedBox(
                            width: 270,
                            child: new MaterialButton(
                              height: 45.0,
                              child: Text(
                                "确定",
                                style: new TextStyle(fontSize: 22.0),
                              ),
                              onPressed: _forSubmitted,
                              color: const Color.fromRGBO(189, 152, 35, 1),
                              textColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0)),
                            )),
                      ),
                    ]),
              ),
            ),
            new Center(
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,  
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(top: 20,left: 20,right: 20),
                  child: Text("钱包地址的二维码",
                    style: TextStyle(fontSize: 16, color: Colors.black45)),
                    ),
                    Divider(),
               
                QrImage(
                  data: "$_Txaddress",
                  size: 300.0,
                  onError: (ex) {
                    // print("[QR] ERROR - $ex");
                  },
                )
              ],
            ))
          ],
        ),
      ),
    );
  }
}
