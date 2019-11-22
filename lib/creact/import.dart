import 'package:flutter/material.dart';
import 'package:walletapp/creact/setPassWord.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import '../wallet/sacco.dart';


class importWord extends StatefulWidget {
  importWidget createState() => new importWidget();
}

class importWidget extends State<importWord> {
  List Wordlist;
  List addWord = new List();

  Widget Crid() {
    List<Widget> tiles = [];

    for (var item in Wordlist) {
      tiles.add(
        Container(
          decoration: new BoxDecoration(
            border: new Border.all(color: Colors.grey, width: 0.5),
            color: addWord.contains(item)
                ? Color(0xFF3296FA)
                : Color(0xFF9E9E9E), // 底色
            borderRadius: new BorderRadius.circular((4.0)), // 圆角度
          ),
          padding: EdgeInsets.all(5.0),
          child: GestureDetector(
            onTap: () {
              //是否存在指定元素，有则删除，无则添加
              if (addWord.contains(item)) {
                setState(() {
                  addWord.remove(item);
                });
              } else {
                setState(() {
                  addWord.add(item);
                });
              }
            },
            child: Text(
              item,
              style: new TextStyle(fontSize: 20, color: Colors.white),
              // key: item,
            ),
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

//获取助记词
  void getWord() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      Wordlist = prefs.getStringList("mnemonic");
    });
    Wordlist.shuffle(); //将列表中的顺序打乱
    print("----$Wordlist");
  }

//生成助记词列表
  Widget Wlist() {
    List<Widget> list = [];

    for (var item in addWord) {
      list.add(Container(
        padding: EdgeInsets.all(10.0),
        child: Text(
          item,
          style: new TextStyle(fontSize: 18),
        ),
      ));
    }
    return Wrap(
      children: list,
      spacing: 15, //主轴上子控件的间距
      runSpacing: 2, //交叉轴上子控件之间的间距
    );
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
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            LinearProgressIndicator(
              value: .666,
                backgroundColor: Colors.grey[200],
  valueColor: AlwaysStoppedAnimation(Colors.blue),
            ),
            Text(
              "备份助记词",
              style: new TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            Text(
              "请您将抄下的12个单词按正确的顺序输入至下方",
              style: new TextStyle(
                fontSize: 18,
              ),
            ),
            Container(
              width: 300,
              height: 220,
              decoration: new BoxDecoration(
                border: new Border.all(color: Colors.grey, width: 0.5),
                color: Color(0xf9f9f9), // 底色
                borderRadius: new BorderRadius.circular((4.0)), // 圆角度
              ),
              child: Wrap(
                children: [Wlist()],
              ),
            ),
            Container(
                child: Wrap(
              children: <Widget>[Crid()],
              spacing: 20, //主轴上子控件的间距
              runSpacing: 10, //交叉轴上子控件之间的间距
              // children: <Widget>[Crid()],
            )),
            MaterialButton(
              minWidth: 200,
              color: Colors.blue[500],
              colorBrightness: Brightness.dark,
              splashColor: Colors.grey,
              child: Text(
                "确定",
                style: new TextStyle(fontSize: 20),
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)),
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                var mnemonic = prefs.getStringList("mnemonic");
                print("//////$addWord");
                print("******$mnemonic");
                if (addWord.toString() == mnemonic.toString()) {
                  print("输入正确！");

                  //默认设置显示余额
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  prefs.setBool("balance", true);


                  print("+126546" + prefs.getString("address"));
                  // Navigator.of(context).pushNamedAndRemoveUntil(
                  //     '/BottomNav', (Route<dynamic> route) => false);
                       Navigator.push(context,
                    new MaterialPageRoute(builder: (context) {
                  return setPassWord();
                }));
                } else {
                  setState(() {
                    addWord.length = 0;
                  });
                  Toast.show("助记词输入错误，请重新输入！", context,
                      duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
                }
              },
            ),
          ],
        ),
      )),
    );
  }
}
