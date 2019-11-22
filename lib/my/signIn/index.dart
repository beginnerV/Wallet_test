import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../../wallet/wallet.dart';
import '../../creact/StartCreact.dart';

class SignIn extends StatefulWidget {
  @override
  SignInWidgetState createState() => new SignInWidgetState();
}

class SignInWidgetState extends State<SignIn> {
  String address = "cosmos";
  String balance = "0";
  Dio dio = Dio();
  Response response;
  String bal;

  void Myget() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      address = prefs.getString("address");
    });


    response = await dio.get("$Url/bank/balances/$address");

    await dio
        .get("$Url/bank/balances/$address")
        .then((val) => print(val.toString()));
    setState(() {
      bal = response.data["result"].toString() == "[]"
          ? "0"
          : response.data["result"][0]["amount"].toString();

      balance = prefs.getBool("balance") ? bal : "****";
    });
  }

  void Show_balance() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setBool("balance", !prefs.getBool("balance"));

    setState(() {
      balance = prefs.getBool("balance") ? bal : "****";
      print(prefs.getBool("balance"));
    });
  }

  @override
  void initState() {
    super.initState();
    Myget();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('我'), automaticallyImplyLeading: false),
      body: Center(
        child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(155, 204, 153, 1),
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 50.0),
                      child: Container(
                        width: 340,
                        height: 200,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "钱包地址：$address",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            GestureDetector(
                                child: Text(
                                  "钱包余额：${balance} ETH",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 20),
                                ),
                                onTap: Show_balance),
                            SizedBox(
                              height: 25,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                MaterialButton(
                                  child: Text(
                                    "退出登录",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  // color: contst Color（#6669999,
                                  onPressed: () async {
                                    SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    prefs.setString("address", "");
                                    prefs.setBool("blance", true);
                                    Navigator.push(context,
                                        new MaterialPageRoute(
                                            builder: (context) {
                                      return StartCreact();
                                    }));
                                  },
                                )
                              ],
                            )
                          ],
                        ),
                      )))
            ]),
      ),
    );
  }
}
