import 'package:flutter/material.dart';
import '../bottomNav/BottomNav.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'dart:io';


var httpClient = new HttpClient();

class MyScreen extends StatelessWidget {
  MyScreen({Key key, @required this.onChanged}) : super(key: key);
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    TextEditingController _unameController = TextEditingController();
    Dio dio = Dio();
    Response response;

    void Myget() async {
     SharedPreferences prefs = await SharedPreferences.getInstance();
      response = await dio.get("http://172.168.0.222:8880/My");
      prefs.setString('Balance', response.data["Balance"]);
      prefs.setString('Address', response.data["address"]);
    }

    return Scaffold(
      body: new Center(
        child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                autofocus: true,
                controller: _unameController,
                onChanged: (v) {
                  print("name:$v");
                },
                decoration: InputDecoration(
                    labelText: "用户名",
                    hintText: "用户名或邮箱",
                    prefixIcon: Icon(Icons.person)),
              ),
              TextField(
                decoration: InputDecoration(
                    labelText: "密码",
                    hintText: "您的登录密码",
                    prefixIcon: Icon(Icons.lock)),
                obscureText: true,
              ),
              new Container(
                  margin: EdgeInsets.all(30),
                  child: new MaterialButton(
                    child: Text(
                      "登录",
                      style: new TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    onPressed: () {
                      Myget();
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return BottomNavigationWidget();
                      }));
                    },
                    color: Colors.blue,
                    textColor: Colors.white,
                    minWidth: 270.0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0)),
                  ))
            ]),
      ),
    );
  }
}

