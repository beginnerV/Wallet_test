import 'package:flutter/material.dart';
import 'creact.dart';
import 'package:dio/dio.dart';
import 'package:sacco/sacco.dart';
import '../ImportWallet/ImportWallet.dart';


class StartCreact extends StatelessWidget {
  Dio dio = Dio();
  Response response;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new MaterialButton(
              minWidth: 200,
              color: Colors.blue[700],
              colorBrightness: Brightness.dark,
              splashColor: Colors.grey,
              child: Text("创建钱包", style: new TextStyle(fontSize: 20)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)),
              onPressed: () {
                Navigator.push(context,
                    new MaterialPageRoute(builder: (context) {
                  return creact();
                }));
              },
            ),
            new MaterialButton(
              minWidth: 200,
              //  height: 30,
              color: Colors.green,
              colorBrightness: Brightness.dark,
              splashColor: Colors.grey,
              child: Text(
                "导入钱包",
                style: new TextStyle(fontSize: 20),
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)),
              onPressed: () {
                Navigator.push(context,
                    new MaterialPageRoute(builder: (context) {
                  return ImportWallet();
                }));
              },
            )
          ],
        ),
      ),
    );
  }
}
