import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'dart:ui';
import 'dart:math';
import 'dart:async';
import 'package:rflutter_alert/rflutter_alert.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arity Grid',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: MenuPage(),
      ),
    );
  }
}

class MenuPage extends StatefulWidget {
  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  var storage = LocalStorage('records');
  var power = 2;
  var liste = List.generate(32 * log(2) ~/ log(2) - 1, (index) => index + 2);
  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    var d = sqrt(MediaQuery.of(context).size.height *
            MediaQuery.of(context).size.height +
        MediaQuery.of(context).size.width * MediaQuery.of(context).size.width);
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.settings, size: d / 24, color: Colors.black),
            onPressed: () => _scaffoldKey.currentState.openDrawer(),
          ),
          leadingWidth: d / 20,
          title: Center(
            child: Text(
              'Arity Grid',
              style: TextStyle(fontSize: d / 20, color: Colors.black),
              textAlign: TextAlign.center,
            ),
          ),
          toolbarHeight: d / 18,
          backgroundColor: Colors.lightGreen,
        ),
        drawer: Container(
          color: Colors.red,
          width: d / 4,
          child: Column(
            children: <Widget>[
              ListTile(
                title: Text(
                  'Bases',
                  style: TextStyle(fontSize: d / 24),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: 35,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Container(
                          color: Colors.blue,
                          child: Center(
                            child: RadioListTile(
                              activeColor: Colors.red,
                              title: Text('base ${index + 2}',
                                  style: TextStyle(fontSize: d / 36)),
                              value: index + 2,
                              groupValue: power,
                              onChanged: (value) {
                                setState(() {
                                  power = value;
                                  liste = List.generate(
                                      32 * log(2) ~/ log(value) - 1,
                                      (ind) => ind + 2);
                                });
                              },
                            ),
                          ),
                        ),
                      );
                    }),
              ),
              FutureBuilder(
                  future: storage.ready,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      var records = storage.getItem('records');
                      if (records == null) {
                        records = Map();
                        for (int f = 2; f < 37; f++) {
                          for (int g = 2; g < 32 * log(2) ~/ log(f) + 1; g++) {
                            records.addAll(
                                {'$f,$g': (double.infinity).toString()});
                            storage.setItem('records', json.encode(records));
                          }
                        }
                      } else
                        records = json.decode(records);
                      if (snapshot.hasError == false) {
                        return Container(
                          height: d / 18,
                          width: d,
                          child: IconButton(
                              icon: Icon(Icons.emoji_events, size: d / 24),
                              onPressed: () {
                                setState(() {
                                  Alert(
                                      title: 'Records',
                                      context: context,
                                      content: Container(
                                        height:
                                            MediaQuery.of(context).size.height /
                                                2,
                                        width:
                                            MediaQuery.of(context).size.width /
                                                2,
                                        child: ListView.builder(
                                            itemCount: 35,
                                            itemBuilder: (context, index) {
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.all(2.0),
                                                child: TextButton(
                                                    style: TextButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.red),
                                                    child: Text(
                                                        'Base ${index + 2}',
                                                        style: TextStyle(
                                                            fontSize: d / 24,
                                                            color:
                                                                Colors.black)),
                                                    onPressed: () {
                                                      setState(() {
                                                        Alert(
                                                            title:
                                                                'Base ${index + 2}',
                                                            context: context,
                                                            content: Container(
                                                                height: MediaQuery.of(context)
                                                                        .size
                                                                        .height /
                                                                    2,
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    2,
                                                                child: ListView
                                                                    .builder(
                                                                  itemCount: 32 *
                                                                          log(
                                                                              2) ~/
                                                                          log(index +
                                                                              2) -
                                                                      1,
                                                                  itemBuilder:
                                                                      (context,
                                                                          ind) {
                                                                    return Padding(
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                              2.0),
                                                                      child: ListTile(
                                                                          title: Text(
                                                                              '${ind + 2} : ${records['${index + 2},${ind + 2}']} sec',
                                                                              style: TextStyle(fontSize: d / 24, color: Colors.black),
                                                                              textAlign: TextAlign.center),
                                                                          tileColor: Colors.blue),
                                                                    );
                                                                  },
                                                                )),
                                                            style: AlertStyle(
                                                                isOverlayTapDismiss:
                                                                    true,
                                                                animationType:
                                                                    AnimationType
                                                                        .grow,
                                                                animationDuration:
                                                                    Duration(
                                                                        seconds:
                                                                            1),
                                                                titleStyle: TextStyle(
                                                                    fontSize:
                                                                        d / 24),
                                                                backgroundColor:
                                                                    Colors.red,
                                                                overlayColor:
                                                                    Colors.black38),
                                                            buttons: [
                                                              DialogButton(
                                                                height: d / 24,
                                                                width: d / 4,
                                                                child: Text(
                                                                  'Back',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          d / 36),
                                                                ),
                                                                color: Colors
                                                                    .green,
                                                                onPressed: () {
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                              ),
                                                              DialogButton(
                                                                height: d / 24,
                                                                width: d / 4,
                                                                child: Text(
                                                                  'Home',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          d / 36),
                                                                ),
                                                                color: Colors
                                                                    .green,
                                                                onPressed: () {
                                                                  Navigator.pop(
                                                                      context);
                                                                  Navigator.pop(
                                                                      context);
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                              )
                                                            ]).show();
                                                      });
                                                    }),
                                              );
                                            }),
                                      ),
                                      style: AlertStyle(
                                          isOverlayTapDismiss: true,
                                          animationType: AnimationType.grow,
                                          animationDuration:
                                              Duration(seconds: 1),
                                          titleStyle:
                                              TextStyle(fontSize: d / 24),
                                          backgroundColor: Colors.blue,
                                          overlayColor: Colors.black38),
                                      buttons: [
                                        DialogButton(
                                          height: d / 24,
                                          width: d / 4,
                                          child: Text(
                                            'Back',
                                            style: TextStyle(fontSize: d / 36),
                                          ),
                                          color: Colors.green,
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                        ),
                                        DialogButton(
                                          height: d / 24,
                                          width: d / 4,
                                          child: Text(
                                            'Home',
                                            style: TextStyle(fontSize: d / 36),
                                          ),
                                          color: Colors.green,
                                          onPressed: () {
                                            Navigator.pop(context);
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ]).show();
                                });
                              }),
                        );
                      } else
                        print(
                            'error : ${snapshot.error} + ${snapshot.hasError}');
                      return Text('Error');
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else {
                      return IconButton(
                          icon: Icon(Icons.clear), onPressed: null);
                    }
                  }),
            ],
          ),
        ),
        backgroundColor: Colors.green,
        body: GridView.builder(
          padding: EdgeInsets.all(20),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount:
                MediaQuery.of(context).orientation == Orientation.landscape
                    ? 3
                    : 2,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
          ),
          itemCount: liste.length,
          itemBuilder: (BuildContext context, int index) {
            return new FlatButton(
              color: Colors.blue,
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ArityPage(n: liste[index], d: d, power: power)));
              },
              child: Text(
                liste[index].toString(),
                style: TextStyle(fontSize: d / 20),
                textAlign: TextAlign.center,
              ),
            );
          },
        ));
  }
}

class ArityPage extends StatefulWidget {
  final int n;
  final double d;
  final random = new Random();
  final int power;

  ArityPage(
      {Key key, @required this.n, @required this.d, @required this.power});

  @override
  _ArityPageState createState() => _ArityPageState(
      n: n,
      d: d,
      list: new List.filled(n * n, 0),
      liste: List.filled(n, pow(power, n)),
      l: List.filled(n, 0),
      power: power);
}

class _ArityPageState extends State<ArityPage> {
  final int n;
  final double d;
  final int power;
  List<int> list;
  List<int> liste;
  List<int> l;
  var ta = 0;
  var sw = new Stopwatch();
  var storage = LocalStorage('records');

  _ArityPageState(
      {@required this.n,
      @required this.d,
      @required this.list,
      @required this.liste,
      @required this.l,
      @required this.power});

  var timer = Timer(Duration(seconds: 0), null);

  void check(n, i) {
    int a = 0;
    for (int f = 0; f < n; f++) {
      a += list[i * n + f] * pow(power, n - f - 1);
    }
    a == liste[i] ? l[i] = 1 : l[i] = 0;
    if (checkTrue() && sw.elapsedMilliseconds != 0) {
      timer.cancel();
      sw.stop();
      Alert(
        title: 'Time : ${sw.elapsedMilliseconds / 1000}s',
        context: context,
        content: FutureBuilder(
            future: storage.ready,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator(
                  backgroundColor: Colors.black,
                );
              } else if (snapshot.connectionState == ConnectionState.done) {
                Map records = json.decode(storage.getItem('records'));
                Map rec = {...records};
                if (double.parse(records['$power,$n']) >
                    sw.elapsedMilliseconds / 1000) {
                  records['$power,$n'] =
                      (sw.elapsedMilliseconds / 1000).toString();
                  storage.setItem('records', json.encode(records));
                }
                return Text('${rec['$power,$n']} sec');
              } else
                return Text(
                  'Error loading High Scores',
                  style: TextStyle(fontSize: d / 32, color: Colors.black),
                );
            }),
        style: AlertStyle(
            animationType: AnimationType.grow,
            animationDuration: Duration(seconds: 0),
            isCloseButton: false,
            isOverlayTapDismiss: false,
            backgroundColor: Colors.blue,
            overlayColor: Colors.black38,
            titleStyle: TextStyle(fontSize: d / 24)),
        buttons: [
          DialogButton(
              height: d / 24,
              width: d / 4,
              child: Text(
                'Retry',
                style: TextStyle(fontSize: d / 36),
              ),
              color: Colors.red,
              onPressed: () {
                setState(() {
                  sw.reset();
                  ta = 0;
                  liste = List.generate(
                      n, (index) => Random().nextInt(pow(power, n)));
                  list = List.filled(n * n, 0);

                  Navigator.pop(context);
                  startTimer();
                });
              }),
          DialogButton(
            height: d / 24,
            width: d / 4,
            child: Text(
              'Home',
              style: TextStyle(fontSize: d / 36),
            ),
            color: Colors.red,
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
          )
        ],
      ).show();
    }
  }

  bool checkTrue() {
    for (int f = 0; f < n; f++) {
      if (l[f] == 0) return false;
    }
    return true;
  }

  void startTimer() {
    sw.start();
    for (int f = 0; f < n; f++) check(n, f);
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        ta = sw.elapsed.inSeconds;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.undo, size: d / 36, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        leadingWidth: d / 32,
        title: Center(
            child: Text(sw.isRunning ? '$ta' : 'Press retry to begin',
                style: TextStyle(fontSize: d / 24, color: Colors.black),
                textAlign: TextAlign.center)),
        backgroundColor: Colors.lightGreen,
        toolbarHeight: d / 18,
        actions: [
          Center(
              child: Text('Base $power  ',
                  style: TextStyle(fontSize: d / 24, color: Colors.black),
                  textAlign: TextAlign.center)),
        ],
      ),
      backgroundColor: Colors.green,
      body: Flex(
        direction: MediaQuery.of(context).orientation == Orientation.landscape
            ? Axis.horizontal
            : Axis.vertical,
        children: <Widget>[
          Expanded(
            child: FlatButton(
              child: Column(
                children: [
                  Expanded(
                    child: Icon(
                      Icons.home_filled,
                      color: Colors.black,
                      size: d / 16,
                    ),
                  ),
                ],
              ),
              onPressed: () {
                setState(() {
                  Navigator.pop(context);
                });
              },
            ),
          ),
          ClipRect(
            child: InteractiveViewer(
              minScale: .5,
              maxScale: 10,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: new List<Widget>.generate(n, (ind) {
                        return Row(
                          children: [
                            new Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: new List<Widget>.generate(n, (index) {
                                return new Padding(
                                  padding: EdgeInsets.all(20 / n),
                                  child: SizedBox(
                                    width: min(
                                                MediaQuery.of(context)
                                                        .size
                                                        .height -
                                                    d / 18,
                                                MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    80 / n -
                                                    MediaQuery.of(context)
                                                            .size
                                                            .width /
                                                        n) /
                                            n -
                                        40 / n,
                                    height: min(
                                                MediaQuery.of(context)
                                                        .size
                                                        .height -
                                                    d / 18,
                                                MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    80 / n -
                                                    MediaQuery.of(context)
                                                            .size
                                                            .width /
                                                        n) /
                                            n -
                                        40 / n,
                                    child: Container(
                                      color: Colors.blue,
                                      child: Stack(
                                          fit: StackFit.expand,
                                          children: <Widget>[
                                            Center(
                                              child: AutoSizeText(
                                                  '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ'[
                                                          list[n * index + ind]]
                                                      .toString(),
                                                  minFontSize: 0.0,
                                                  style:
                                                      TextStyle(fontSize: d)),
                                            ),
                                            TextButton(
                                              style: TextButton.styleFrom(
                                                backgroundColor:
                                                    Colors.transparent,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            0)),
                                              ),
                                              child: Text(''),
                                              onPressed: () {
                                                setState(() {
                                                  list[n * index + ind] = (1 +
                                                          list[n * index +
                                                              ind]) %
                                                      power;
                                                  check(n, index);
                                                });
                                              },
                                            ),
                                          ]),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ],
                        );
                      }),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: new List<Widget>.generate(n, (index) {
                        return new Padding(
                          padding: EdgeInsets.fromLTRB(
                              40 / n, 20 / n, 40 / n, 20 / n),
                          child: SizedBox(
                            width: min(
                                        MediaQuery.of(context).size.height -
                                            d / 18,
                                        MediaQuery.of(context).size.width -
                                            80 / n -
                                            MediaQuery.of(context).size.width /
                                                n) /
                                    n -
                                40 / n,
                            height: min(
                                        MediaQuery.of(context).size.height -
                                            d / 18,
                                        MediaQuery.of(context).size.width -
                                            80 / n -
                                            MediaQuery.of(context).size.width /
                                                n) /
                                    n -
                                40 / n,
                            child: Container(
                              color: l[index] == 0
                                  ? Colors.red
                                  : Colors.lightGreen,
                              child: Center(
                                child: AutoSizeText(liste[index].toString(),
                                    minFontSize: 0.0,
                                    stepGranularity: 0.1,
                                    style: TextStyle(
                                        fontSize: d, color: Colors.black)),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: FlatButton(
              child: Column(
                children: [
                  Expanded(
                    child: Icon(
                      Icons.replay,
                      color: Colors.black,
                      size: d / 16,
                    ),
                  ),
                ],
              ),
              onPressed: () {
                setState(() {
                  sw.reset();
                  ta = 0;
                  timer.cancel();
                  liste = List.generate(
                      n, (index) => Random().nextInt(pow(power, n)));
                  list = List.filled(n * n, 0);
                  startTimer();
                });
              },
            ),
          )
        ],
      ),
    );
  }
}
