import 'package:flutter/material.dart';
import '../transaction/transaction.dart';
import '../txlist/txlist.dart';
import '../my/signIn/index.dart';


class BottomNavigationWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => BottomNavigationWidgetState();
  BottomNavigationWidget({
    Key key,
    @required this.text,
  }) : super(key: key);
  final String text;
}

class BottomNavigationWidgetState extends State<BottomNavigationWidget> {
  var _bottomNavigationColor = Colors.blue;
  var txColor = Colors.black87;
  var txlistColor = Colors.black87;
  var myColor = Colors.black87;

  int _currentIndex = 0;
  List<Widget> list = List();


  @override
  void initState() {
    list..add(TxlistScreen())..add(TransactionScreen())..add(SignIn());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: list[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: Icon(
                Icons.create,
                size: 30.0,
                color: txlistColor,
              ),
              title: Text(
                '交易记录',
                style: TextStyle(color: txlistColor),
              )),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.repeat,
                size: 30.0,
                color: txColor,
              ),
              title: Text(
                '转账',
                style: TextStyle(color: txColor),
              )),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.person,
                size: 30.0,
                color: myColor,
              ),
              title: Text(
                "我",
                style: TextStyle(color: myColor),
              )),
        ],
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
            print(index);

  if(index ==0 ){
txlistColor = Colors.orange;
txColor = Colors.black87;
myColor = Colors.black87;
  }else if(index ==1){
txColor = Colors.orange;
txlistColor = Colors.black87;
myColor = Colors.black87;
  }else if(index ==2){
myColor = Colors.orange;
txColor = Colors.black87;
txlistColor = Colors.black87;
  }
            // _bottomNavigationColor = Colors.green;
            
          });
        },
        // type: BottomNavigationBarType.shifting, //图标放大
      ),
    );
  }
}
