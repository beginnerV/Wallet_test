import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import '../wallet/wallet.dart';
import 'package:toast/toast.dart';
import 'package:bip39/bip39.dart' as bip39;

class ImportWallet extends StatefulWidget {
  ImportWalletWidget createState() => new ImportWalletWidget();
}

class ImportWalletWidget extends State<ImportWallet> {
  TabController _tabController;
  TextEditingController _InwordController = TextEditingController();
  TextEditingController _InprvController = TextEditingController();

//助记词导入
void Inword() async{
  SharedPreferences prefs = await SharedPreferences.getInstance();  
  prefs.setStringList("mnemonic",_InwordController.text.split(" "));

  try{
await wallet();
   Navigator.of(context).pushNamedAndRemoveUntil('/BottomNav', (Route<dynamic> route) => false);
  }catch(e){
      Toast.show("助记词输入错误，请重新输入！", context,
                      duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
    // print(e);
  }
}

//私钥导入
void privateKey() async{

String mnemonic = await bip39.entropyToMnemonic("a82d87e0dd9e0c4ff669d1209133faa66a6f8d73e959a6a4c077a99fa511a941");
print(mnemonic);
  // SharedPreferences prefs = await SharedPreferences.getInstance();  
  // prefs.setStringList("mnemonic",mnemonic.split(" "));
  String a = bip39.mnemonicToEntropy("final random flame cinnamon grunt hazard easily mutual resist pond solution define knife female tongue crime atom jaguar alert library best forum lesson rigid");
  print(a);


}
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new DefaultTabController(
        length: 2,
        child: new Scaffold(
          appBar: AppBar(title: Text('导入钱包'), automaticallyImplyLeading: true,bottom:  new TabBar(
            tabs: <Widget>[
              new Tab(
                text: "助记词",
              ),
              new Tab(
                text: "私钥",
              )
            ],
            controller: _tabController,
          ),),
          
          //是否显示返回箭头
       
     body: new TabBarView(controller: _tabController, children: <Widget>[
          //助记词导入
          new Center(
            child: Column(
              children: <Widget>[
                Container(
                  padding: new EdgeInsets.all(15.0),
                  child: TextField(
                    controller: _InwordController,
                    autofocus: true,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "输入助记词单词，并使用空格分隔",
                      border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black, width: 1)),
                    ),
                  ),
                ),
                new MaterialButton(
                  minWidth: 320,
                  //  height: 30,
                  color: Colors.blue,
                  colorBrightness: Brightness.dark,
                  splashColor: Colors.grey,
                  child: Text(
                    "开始导入",
                    style: new TextStyle(fontSize: 20),
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                  onPressed: Inword,
                )
              ],
            ),
          ),
          //私钥导入
          new Center(
             child: Column(
              children: <Widget>[
                Container(
                  padding: new EdgeInsets.all(15.0),
                  child: TextField(
                    controller: _InprvController,
                    autofocus: true,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "输入明文私钥",
                      border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black, width: 1)),
                    ),
                  ),
                ),
                new MaterialButton(
                  minWidth: 320,
                  //  height: 30,
                  color: Colors.blue,
                  colorBrightness: Brightness.dark,
                  splashColor: Colors.grey,
                  child: Text(
                    "开始导入",
                    style: new TextStyle(fontSize: 20),
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                  onPressed:privateKey
                )
              ],
            ),
          )
        ])) );
  }
}
