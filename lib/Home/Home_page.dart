import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:bip39/bip39.dart' as bip39;
import '../server/db.dart';

import '../wallet/sacco.dart';

class Home extends StatefulWidget {
  HomeWidget createState() => new HomeWidget();
}

class HomeWidget extends State<Home> {
  // PrivateSqlite privateSqlite = new PrivateSqlite();
  // var bookName = "";
  String addr;
  List<User> _datas = new List();
  var db = DatabaseHelper();
  List addWord = new List();
  String info = "";

  @override
  void initState() {
    super.initState();
    _getDataFromDb();
  }

  _getDataFromDb() async {
    List datas = await db.getTotalList();
    if (datas.length > 0) {
      //数据库有数据
      datas.forEach((user) {
        User item = User.fromMap(user);
        _datas.add(item);
      });
    }

    setState(() {});
  }

  void creact() async {
    //随机创建一个钱包
    List mnemonic;
    final networkInfo = NetworkInfo(
        name: "", bech32Hrp: "cosmos", lcdUrl: "http://172.168.12.78:1317");
    String randomMnemonic = await bip39.generateMnemonic();
    mnemonic = randomMnemonic.split(" ");
    Wallet wallet = Wallet.derive(mnemonic, networkInfo,"yy");

    //创建钱包时把钱包信息添加到数据库
    // print(hex.encode(wallet.privateKey));
    String prv = hex.encode(wallet.privateKey);
    setState(() {
      addr = wallet.bech32Address.toString();
    });
    String name = "一钱包";

    // print("$addr,$name,$prv");
    User user = new User();
    user.address = addr.toString();
    user.name = name.toString();
    user.privatekey = prv.toString();
    await db.saveItem(user);
    see();
  }

  Future<Null> see() async {
    // _datas.clear();
    // addWord.clear();
    List datas = await db.getTotalList();
    if (datas.length > 0) {
      datas.forEach((user) {
        User dataListBean = User.fromMap(user);
        _datas.add(dataListBean);
      });
      // print(datas);
      setState(() {
        info = datas[0].toString();
      });
      setState(() {
        addWord.clear();
      });
      datas.forEach((val) {
        setState(() {
          addWord.add(val.toString());
        });
      });
    }
  }

//删除钱包
  void del() async {}

//删除所有钱包
  void all() async {
    // List datas = await db.getTotalList();
    await db.clear();
    setState(() {
      addWord.clear();
    });
  }

//生成钱包列表
  Widget Wlist() {
    List<Widget> list = [];

    for (var item in addWord) {
      list.add(Container(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              Text(
                item,
                style: new TextStyle(fontSize: 18),
              ),
              MaterialButton(
                child: Text("切换钱包"),
                color: Colors.blue,
                onPressed: () {
                  setState(() {
                    info = item;
                  });
                  // print(item);
                },
              ),
            ],
          )));
    }
    return Wrap(
      children: list,
      spacing: 15, //主轴上子控件的间距
      runSpacing: 2, //交叉轴上子控件之间的间距
    );
  }

//交易
  void Tx() {
    //  print(this.info.toString());
    var n = this.info.split(":");
    var private = n[3].split("}")[0];
//  print(private);
    List<int> list = private.codeUnits;
    Uint8List bytes = Uint8List.fromList(list);
    final message = StdMsg(
      type: "cosmos-sdk/MsgSend",
      value: {
        "from_address": "cosmos1huydeevpz37sd9snkgul6070mstupukw00xkw9",
        "to_address": "cosmos12lla7fg3hjd2zj6uvf4pqj7atx273klc487c5k",
        "amount": [
          {"denom": "uatom", "amount": "100"}
        ]
      },
    );

    final stdTx = TxBuilder.buildStdTx(stdMsgs: [message]);
//  var sign = SignTx(privateKey:bytes).signTxData(stdTx.toString());
//  print("123"+stdTx.toString());

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("钱包信息$info"),
            Container(
              width: 350,
              height: 400,
              decoration: new BoxDecoration(
                border: new Border.all(color: Colors.grey, width: 0.5),
                color: Color(0xf9f9f9), // 底色
                borderRadius: new BorderRadius.circular((4.0)), // 圆角度
              ),
              child: ListView(
                children: [Wlist()],
              ),
            ),
            MaterialButton(
              child: Text("创建钱包"),
              color: Colors.blue,
              onPressed: creact,
            ),
            MaterialButton(
              child: Text("查询所有钱包信息"),
              color: Colors.blue,
              onPressed: see,
            ),
            MaterialButton(
              child: Text("删除所有钱包信息"),
              color: Colors.blue,
              onPressed: all,
            ),
            MaterialButton(
              child: Text("删除所有钱包信息"),
              color: Colors.blue,
              onPressed: all,
            ),
            MaterialButton(
              child: Text("用当下钱包进行交易"),
              color: Colors.blue,
              onPressed: () async {
                //1.签名交易
                // Wallet wallet = Wallet.sig
                //弹窗
                showDialog<Null>(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return new AlertDialog(
                      title: new Text('收入'),
                      content: new SingleChildScrollView(
                        child: new ListBody(
                          children: <Widget>[
                            new Text(
                                '从地址cosmos1huydeevpz37sd9snkgul6070mstupukw00xkw9转给了当前钱包账户'),
                            new Text('内容 2'),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        new FlatButton(
                          child: new Text('确定'),
                          onPressed: Tx,
                          // () {
                          //     Navigator.of(context).pop();
                          // },
                        ),
                      ],
                    );
                  },
                ).then((val) {
                  print(val);
                });
              },
            )
          ],
        ),
      ),
    );
  }
}
