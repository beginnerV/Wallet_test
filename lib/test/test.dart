import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:http/http.dart';
import 'package:pointycastle/pointycastle.dart';
import '../server/walletdb.dart';
import 'dart:convert';
import '../wallet/utils/bech32_encoder.dart';
import '../wallet/sacco.dart';
import 'dart:convert' as convert;

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
  Uint8List address;
  Uint8List publicKey;
  Uint8List privateKey;

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
    } else {
      //没有数据创建钱包
    }

    setState(() {});
  }

  void creact() async {
    //随机创建一个钱包
    List mnemonic;
    final networkInfo = NetworkInfo(
        name: "", bech32Hrp: "cosmos", lcdUrl: "http://192.168.60.251:1317");
    String randomMnemonic = await bip39.generateMnemonic();
    mnemonic = randomMnemonic.split(" ");
    Wallet wallet = Wallet.derive(mnemonic, networkInfo, "hhh");

    String prv = hex.encode(wallet.privateKey);
    setState(() {
      addr = wallet.bech32Address.toString();
    });
    see();
  }

  Future<Null> see() async {
    // _datas.clear();
    // addWord.clear();
    List datas = await db.getTotalList();
    print(datas);
    if (datas.length > 0) {
      datas.forEach((user) {
        User dataListBean = User.fromMap(user);
        _datas.add(dataListBean);
      });
      // print(datas);
      setState(() {
        info = datas[0]["address"].toString();
      });
      setState(() {
        addWord.clear();
      });
      print(datas);

      datas.forEach((val) {
        print("***" + val["name"].toString());
        final networkInfo = NetworkInfo(
            name: "",
            bech32Hrp: "cosmos",
            lcdUrl: "192.168.60.251:1317");

        print(val["address"]);
        var addr = json.decode(val["address"]);
        var priv = json.decode(val["privatekeyBytes"]);
        var pub = json.decode(val["publickeyBytes"]);
        List<int> streetsList = new List<int>.from(addr);
        List<int> private = new List<int>.from(priv);
        List<int> public = new List<int>.from(pub);
        var privatek = new Uint8List.fromList(private);
        var publick = new Uint8List.fromList(public);
        var addressk = new Uint8List.fromList(streetsList);
        print("---" + Bech32Encoder.encode(networkInfo.bech32Hrp, addressk));

        setState(() {
          info = Bech32Encoder.encode(networkInfo.bech32Hrp, addressk);
          address = addressk;
          privateKey = privatek;
          publicKey = publick;
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
  void Tx() {}
  void addrtx() async {
      final message = StdMsg(
      type: "cosmos-sdk/MsgSend",
      value: {
        "from_address": "cosmos1huydeevpz37sd9snkgul6070mstupukw00xkw9",
        "to_address": "cosmos18rwfv9yj7u4zmahv4y299ft086j704cxal9mtf",
        "amount": [
          {"denom": "atoken", "amount": "100"}
        ],
    
      }
    );
// await db.getItem();
    final stdTx = TxBuilder.buildStdTx(stdMsgs: [message]);

    print("---交易---");

            final networkInfo = NetworkInfo(
            name: "",
            bech32Hrp: "cosmos",
            lcdUrl: "http://192.168.60.251:1317");

// final networkInfo = NetworkInfo(name: "", bech32Hrp: "cosmos", lcdUrl: "");

final mnemonicString = "final random flame cinnamon grunt hazard easily mutual resist pond solution define knife female tongue crime atom jaguar alert library best forum lesson rigid";
final mnemonic = mnemonicString.split(" ");
// final wallet =  Wallet.derive(mnemonic, networkInfo,"aa");
Wallet wallet = new Wallet(
      address: address,
      publicKey: publicKey,
      privateKey: privateKey,
      networkInfo: networkInfo,
 );
 print("信息：$address,$publicKey,$privateKey");
final signedStdTx = await TxSigner.signStdTx(wallet: wallet, stdTx: stdTx);
print("签名：$signedStdTx");
try {
  final response = await TxSender.broadcastStdTx(wallet: wallet, stdTx: signedStdTx);
  print("Tx send successfully. Hash: ${response.hash}");
} catch (error) {
  print("Error while sending the tx: $error");
}
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
              child: Text("交易"),
              color: Colors.blue,
              onPressed: addrtx,
            ),
            //         MaterialButton(
            //           child: Text("用当下钱包进行交易"),
            //           color: Colors.blue,
            //            onPressed: () async{
            //              //1.签名交易
            //           // Wallet wallet = Wallet.sig
            //              //弹窗
            //     showDialog<Null>(
            //         context: context,
            //         barrierDismissible: false,
            //         builder: (BuildContext context) {
            //             return new AlertDialog(
            //                 title: new Text('收入'),
            //                 content: new SingleChildScrollView(
            //                     child: new ListBody(
            //                         children: <Widget>[
            //                             new Text('从地址cosmos1huydeevpz37sd9snkgul6070mstupukw00xkw9转给了当前钱包账户'),
            //                             new Text('内容 2'),
            //                         ],
            //                     ),
            //                 ),
            //                 actions: <Widget>[
            //                     new FlatButton(
            //                         child: new Text('确定'),
            //                         onPressed: Tx,
            //                         // () {
            //                         //     Navigator.of(context).pop();
            //                         // },
            //                     ),
            //                 ],
            //             );
            //         },
            //     ).then((val) {
            //         print(val);
            //     });
            // },
            //         )
          ],
        ),
      ),
    );
  }
}
