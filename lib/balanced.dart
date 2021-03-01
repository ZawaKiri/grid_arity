import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'dart:ui';
import 'dart:math';
import 'dart:async';
import 'package:rflutter_alert/rflutter_alert.dart';

class BalancedPage extends StatefulWidget {
  final int n;
  final double d;
  final random = new Random();
  final int power;

  BalancedPage(
      {Key key, @required this.n, @required this.d, @required this.power});

  @override
  _BalancedPageState createState() => _BalancedPageState(
      n: n,
      d: d,
      list: new List.filled(n * n, 0),
      liste: List.filled(n, pow(power, n)),
      liliste: [
        ...List.generate((power + 1) ~/ 2, (index) => index),
        ...List.generate(
            (power + 1) ~/ 2 - 1, (index) => index - ((power + 1) ~/ 2 - 1)),
      ],
      l: List.filled(n, 0),
      power: power);
}

class _BalancedPageState extends State<BalancedPage> {
  final int n;
  final double d;
  final int power;
  List<int> list;
  List<int> liste;
  List<int> liliste;
  List<int> l;
  var ta = 0;
  var sw = new Stopwatch();
  var storage = LocalStorage('records');
  var zoom = false;
  var wheel = false;

  _BalancedPageState(
      {@required this.n,
      @required this.d,
      @required this.list,
      @required this.liste,
      @required this.liliste,
      @required this.l,
      @required this.power});

  var timer = Timer(Duration(seconds: 0), null);

  void check(n, i) {
    print('list = $list');
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
        content: Column(
          children: [
            Text(
              '$liste',
              style: TextStyle(fontSize: d / 32),
            ),
            FutureBuilder(
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
          ],
        ),
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
          Icon(Icons.search, color: Colors.black, size: d / 24),
          Switch(
              value: zoom,
              onChanged: (value) {
                setState(() {
                  zoom = value;
                });
              }),
          /*Icon(Icons.touch_app, color: Colors.black, size: d / 24),
          Switch(
              value: !wheel,
              onChanged: (value) {
                setState(() {
                  wheel = !value;
                });
              }),*/
          Center(
              child: Text('Bal. $power  ',
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
            child: TextButton(
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
              scaleEnabled: zoom,
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
                                      child: wheel
                                          ? ListWheelScrollView.useDelegate(
                                              diameterRatio: 2,
                                              physics:
                                                  FixedExtentScrollPhysics(),
                                              //useMagnifier: true,
                                              magnification: 1,
                                              itemExtent: min(
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height -
                                                              d / 18,
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width -
                                                              80 / n -
                                                              MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  n) /
                                                      n -
                                                  40 / n,
                                              childDelegate:
                                                  ListWheelChildLoopingListDelegate(
                                                      children: List.generate(
                                                          power,
                                                          (i) => AutoSizeText(
                                                              liliste[i]
                                                                  .toString(),
                                                              minFontSize: 0.0,
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      d)))),
                                              onSelectedItemChanged: (inde) {
                                                setState(() {
                                                  print('inde = $inde');
                                                  print('len = ${liliste.length}');
                                                  list[n * index + ind] = liliste[inde];
                                                  check(n, index);
                                                });
                                              },
                                            )
                                          : Stack(
                                              fit: StackFit.expand,
                                              children: <Widget>[
                                                  Center(
                                                    child: AutoSizeText(
                                                        liliste[list[n * index +
                                                                ind] % power]
                                                            .toString(),
                                                        minFontSize: 0.0,
                                                        style: TextStyle(
                                                            fontSize: d)),
                                                  ),
                                                  TextButton(
                                                    style: TextButton.styleFrom(
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          0)),
                                                    ),
                                                    child: Text(''),
                                                    onPressed: () {
                                                      setState(() {
                                                        list[n * index +
                                                            ind] = liliste[(1 +
                                                                list[n * index +
                                                                    ind]) %
                                                            power];
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
            child: TextButton(
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
                      n, (index) => Random().nextInt(pow(power, n)) - (pow(power, n) - 1) ~/ 2);
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
