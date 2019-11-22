import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_easyrefresh/ball_pulse_footer.dart';
import 'package:flutter_easyrefresh/ball_pulse_header.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../wallet/wallet.dart';
import 'package:flutter_easyrefresh/bezier_circle_header.dart';
import 'package:flutter_easyrefresh/bezier_bounce_footer.dart';

// import 'package:convert/convert.dart';

class TxlistScreen extends StatefulWidget {
  @override
  _TxlistState createState() => _TxlistState();
}

class _TxlistState extends State<TxlistScreen>
    with SingleTickerProviderStateMixin {
  List<String> ExTo;
  List<String> ExValue;
  List<String> InTo;
  List<String> InValue;
  GlobalKey<EasyRefreshState> _ExRefreshKey = GlobalKey<EasyRefreshState>();
  GlobalKey<EasyRefreshState> _InRefreshKey = GlobalKey<EasyRefreshState>();
  GlobalKey<RefreshHeaderState> _ExheaderKey =
      new GlobalKey<RefreshHeaderState>();
  GlobalKey<RefreshFooterState> _ExfooterKey =
      new GlobalKey<RefreshFooterState>();
 GlobalKey<RefreshHeaderState> _InheaderKey =
      new GlobalKey<RefreshHeaderState>();
  GlobalKey<RefreshFooterState> _InfooterKey =
      new GlobalKey<RefreshFooterState>();
  Dio dio = Dio();
  Response response;
  TabController _tabController;
  int Expage = 1; //页码
  int Exlimit = 10;
  int Inlimit = 1;
  int Inpage = 1;
  String proposer = "message.sender";

//红屏隐藏
  void setCustomErrorPage() {
    ErrorWidget.builder = (FlutterErrorDetails flutterErrorDetails) {
      return Center(
        child: new CircularProgressIndicator(),
      );
    };
  }

//获取支出第一页的数据
  void getExTx() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String addr = prefs.getString("address");
    response = await dio
        .get("$Url/txs?message.sender=${addr}&page=1&limit=${Exlimit}");
    setState(() {
      setState(() {
        Expage = 1;
      });
      List<String> Toarr = new List();
      List<String> Valarr = new List();
      List Txs = new List();
      //遍历获取数组
      for (var item in response.data['txs']) {
        Txs.add(item["tx"]["value"]);
      }

      for (var i = 0; i < Txs.length; i++) {
        Toarr.add(Txs[i]["msg"][0]["value"]["to_address"]);
        Valarr.add(Txs[i]["msg"][0]["value"]["amount"][0]["amount"]);
      }
      ExValue = Valarr;
      ExTo = Toarr;
    });
  }

//获取支出下拉的数据
  void getExTx_dropdown() async {
    setState(() {
      Expage += 1;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String addr = prefs.getString("address");

    int page_total = int.parse(response.data["page_total"]);

    if (Expage <= page_total) {
      response = await dio.get(
          "$Url/txs?message.sender=${addr}&page=${Expage.toString()}&limit=10");
      setState(() {
        List<String> addTo = new List();
        List<String> addVal = new List();
        List addTxs = new List();

        for (var item in response.data['txs']) {
          addTxs.add(item["tx"]["value"]);
        }

        for (var i = 0; i < addTxs.length; i++) {
          addTo.add(addTxs[i]["msg"][0]["value"]["to_address"]);
          addVal.add(addTxs[i]["msg"][0]["value"]["amount"][0]["amount"]);
        }
        ExValue.addAll(addVal);
        ExTo.addAll(addTo);
      });
    }
  }

//获取收入第一页数据
  void getInTx() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String addr = prefs.getString("address");
    response = await dio
        .get("$Url/txs?transfer.recipient=${addr}&page=1&limit=${Inlimit}");
    setState(() {
      setState(() {
        Inpage = 1;
      });
      List<String> Toarr = new List();
      List<String> Valarr = new List();
      List Txs = new List();
      //遍历获取数组
      for (var item in response.data['txs']) {
        Txs.add(item["tx"]["value"]);
      }

      for (var i = 0; i < Txs.length; i++) {
        Toarr.add(Txs[i]["msg"][0]["value"]["to_address"]);
        Valarr.add(Txs[i]["msg"][0]["value"]["amount"][0]["amount"]);
      }
      InValue = Valarr;
      InTo = Toarr;
    });
  }

  //获取收入下拉的数据
  void getInTx_dropdown() async {
    setState(() {
      Inpage += 1;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String addr = prefs.getString("address");

    int page_total = int.parse(response.data["page_total"]);

    if (Inpage <= page_total) {
      response = await dio.get(
          "$Url/txs?transfer.recipient=${addr}&page=${Inpage.toString()}&limit=10");
      setState(() {
        List<String> addTo = new List();
        List<String> addVal = new List();
        List addTxs = new List();

        for (var item in response.data['txs']) {
          addTxs.add(item["tx"]["value"]);
        }

        for (var i = 0; i < addTxs.length; i++) {
          addTo.add(addTxs[i]["msg"][0]["value"]["to_address"]);
          addVal.add(addTxs[i]["msg"][0]["value"]["amount"][0]["amount"]);
        }
        InValue.addAll(addVal);
        InTo.addAll(addTo);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(vsync: this, length: 2);
    getExTx();
    getInTx();
    setCustomErrorPage();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new DefaultTabController(
        length: 2,
        child: new Scaffold(
            appBar: new AppBar(
              title: new TabBar(
                indicatorColor: Colors.black54,
                tabs: <Widget>[
                  new Tab(
                    text: "支出",
                  ),
                  new Tab(
                    text: "收入",
                  )
                ],
                controller: _tabController,
              ),
              automaticallyImplyLeading: false, //是否显示返回箭头
            ),
            body: new TabBarView(
              controller: _tabController,
              children: <Widget>[
                //支出
                new Center(
                    child: new EasyRefresh(
                  key: _ExRefreshKey,
                  refreshHeader: BallPulseHeader(
                    key: _ExheaderKey,
                    backgroundColor: const Color.fromRGBO(241, 243, 244, 1),
                    color: Color.fromRGBO(100, 103, 101, 1),
                  ),
                  refreshFooter: BallPulseFooter(
                    key: _ExfooterKey,
                    backgroundColor: const Color.fromRGBO(241, 243, 244, 1),
                    color: Color.fromRGBO(100, 103, 101, 1),
                  ),
                  child: new ListView.builder(
                      //ListView的Item
                      itemCount: ExTo.length,
                      itemBuilder: (BuildContext context, int index) {
                        return new Container(
                            height: 70.0,
                            child: Card(
                              child: new Center(
                                  child: new Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Icon(
                                    Icons.arrow_upward,
                                    size: 50.0,
                                    // color: Colors.green,
                                  ),
                                  Container(
                                      width: 200,
                                      child: Text(ExTo[index],
                                          style: new TextStyle(fontSize: 18),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis)),
                                  new Text(
                                    "- " + ExValue[index] + " ETH",
                                    style: new TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.green),
                                  )
                                ],
                              )),
                            ));
                      }),
                  onRefresh: () async {
                    setState(() {
                      Exlimit = ExValue.length;
                    });
                    getExTx();
                  },
                  loadMore: () async {
                    getExTx_dropdown();
                  },
                )),

                //收入
                new Center(
                    child: new EasyRefresh(
                  key: _InRefreshKey,
                  refreshHeader: BallPulseHeader(
                    key: _InheaderKey,
                    backgroundColor: const Color.fromRGBO(241, 243, 244, 1),
                    color: Color.fromRGBO(100, 103, 101, 1),
                  ),
                  refreshFooter: BallPulseFooter(
                    key: _InfooterKey,
                    backgroundColor: const Color.fromRGBO(241, 243, 244, 1),
                    color: Color.fromRGBO(100, 103, 101, 1),
                  ),
                  child: new ListView.builder(
                      //ListView的Item
                      itemCount: InTo.length,
                      itemBuilder: (BuildContext context, int index) {
                        return new Container(
                            height: 70.0,
                            child: Card(
                              child: new Center(
                                  child: new Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Icon(
                                    Icons.arrow_downward,
                                    size: 50.0,
                                    // color: Colors.green,
                                  ),
                                  Container(
                                      width: 200,
                                      child: Text(InTo[index],
                                          style: new TextStyle(fontSize: 18),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis)),
                                  new Text(
                                    "+" + InValue[index] + " ETH",
                                    style: new TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.green),
                                  )
                                ],
                              )),
                            ));
                      }),
                  onRefresh: () async {
                    setState(() {
                      Inlimit = InValue.length;
                    });
                    getInTx();
                  },
                  loadMore: () async {
                    getInTx_dropdown();
                  },
                ))
              ],
            )));
  }
}
