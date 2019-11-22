import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:walletapp/server/index.dart';
import 'package:walletapp/wallet/wallet.dart';
// import '../server/walletdb.dart';
import '../server/index.dart';
import './import.dart';
import 'package:bip39/bip39.dart' as bip39;
import './setPassWord.dart';
import 'package:convert/convert.dart';
import '../Home/Home_page.dart';

class creact extends StatefulWidget {
  creactWidget createState() => new creactWidget();
}

class creactWidget extends State<creact> {
  List mnemonic;
  Dio dio = Dio();
  Response response;
  // BookSqlite bookSqlite = new BookSqlite();
  PrivateSqlite privateSqlite = new PrivateSqlite();
  // List<dynamic> Word = new List();

  Widget Crid() {
    List<Widget> tiles = [];
    for (var item in mnemonic) {
      tiles.add(
        new Container(
          decoration: new BoxDecoration(
            border: new Border.all(color: Colors.grey, width: 0.5),
            color: Color(0xFF9E9E9E), // 底色
            borderRadius: new BorderRadius.circular((4.0)), // 圆角度
          ),
          padding: EdgeInsets.all(5.0),
          child: Text(
            item,
            style: new TextStyle(fontSize: 20),
          ),
        ),
      );
    }
    return Wrap(
      spacing: 20, //主轴上子控件的间距
      runSpacing: 10, //交叉轴上子控件之间的间距
      children: tiles,
    );
  }

  void getWord() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String randomMnemonic = await bip39.generateMnemonic();

    setState(() {
      mnemonic = randomMnemonic.split(" ");
    });

    prefs.setStringList("mnemonic", mnemonic);
  }

  @override
  void initState() {
    super.initState();
    getWord();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new Center(
          child: Container(
        padding: const EdgeInsets.all(50.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
           Padding(
          padding: EdgeInsets.only(top: 15),  
 child:LinearProgressIndicator(
              value: .333,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation(Colors.blue),
            ),
            ),
           
            Text(
              "备份助记词",
              style: new TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            Text(
              "请认真按顺序抄写下方12个助记词我们将在下一步验证",
              style: new TextStyle(
                fontSize: 18,
              ),
            ),
            Container(
                child: Wrap(
              spacing: 20, //主轴上子控件的间距
              runSpacing: 10, //交叉轴上子控件之间的间距
              children: <Widget>[Crid()],
            )),
            MaterialButton(
              minWidth: 200,
              color: Colors.blue[500],
              colorBrightness: Brightness.dark,
              splashColor: Colors.grey,
              child: Text(
                "下一步",
                style: new TextStyle(fontSize: 20),
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)),
              onPressed: () async{

//插入一条数据
// await privateSqlite.openSqlite();
// await privateSqlite.insert(new Private(1, "一钱包", "15465", "fafs"));
// await privateSqlite.close();

//获取编号的书
// await privateSqlite.openSqlite();
// List<Private> private = await privateSqlite.queryAll();
// print(private);

//获取编号为0的书
// await bookSqlite.openSqlite();
// Book book = await bookSqlite.getBook(0);
// await bookSqlite.close();
// print(book.name.toString());

                // print("助记词$mnemonic");
                // Navigator.of(context).pushNamed('/Import');
                // Navigator.push(context,
                //     new MaterialPageRoute(builder: (context) {
                //   return importWord();
                // }));

                      Navigator.push(context,
                    new MaterialPageRoute(builder: (context) {
                  return Home();
                }));  
              },
            ),
          ],
        ),
      )),
    );
  }
}
