import 'package:flutter/material.dart';
import '../wallet/sacco.dart';
import '../wallet/wallet.dart';
// import 'package:shared_preferences/shared_preferences.dart';

class setPassWord extends StatefulWidget {
  setPassWordWidget createState() => new setPassWordWidget();
}

class setPassWordWidget extends State<setPassWord> {
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _repasswordController = TextEditingController();
   GlobalKey _formKey = new GlobalKey<FormState>();

void Checkpw() async{
if ((_formKey.currentState as FormState).validate()) {
        Navigator.of(context).pushNamedAndRemoveUntil(
                      '/BottomNav', (Route<dynamic> route) => false);
 print(_repasswordController.text);
 print(_passwordController.text);
 if(_repasswordController.text == _passwordController.text){

}else{
  
  // Toast.show("密码输入不一致，请重新输入！", context,
  //                     duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
 }
}
}
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new Center(
        child: Container(
          padding: new EdgeInsets.all(50.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: 30),
                  child: LinearProgressIndicator(
                    value: 1,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation(Colors.blue),
                  ),
                ),
                Text(
                  "设置钱包密码",
                  style: new TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 70.0),
                TextFormField(
                    controller: _passwordController,
                
                    maxLines: 1,
                    decoration: InputDecoration(
                      hintText: "钱包密码",
                      border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black, width: 1)),
                    ),obscureText: true,
                    validator: (v) {
                      return v.trim().length > 0 ? null : "密码不能为空";
                    }),
                SizedBox(height: 40.0),
                TextFormField(
                  controller: _repasswordController,
               
                  maxLines: 1,
                  decoration: InputDecoration(
                    hintText: "再次输入密码",
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 1)),
                  ),
                    validator: (v) {
                      return v.trim().length > 0 ? null : "密码不能为空";
                    },
                    obscureText: true
                ),
                SizedBox(height: 40.0),
                RaisedButton(
                  color: Colors.blue[500],
                  child: Text(
                    "创建钱包",
                    style: TextStyle(fontSize: 22, color: Colors.white),
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)),
                  onPressed: Checkpw,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
