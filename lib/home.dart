import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:control_app/screens/analysis.dart';
import 'package:control_app/screens/normal.dart';
import 'package:control_app/utils.dart';
import 'package:control_app/widgets/line_titles.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:control_app/Screens/developers.dart';
import 'package:fast_csv/fast_csv.dart' as _fast_csv;

import 'models/point.dart';

class Home extends StatefulWidget {
  final BluetoothDevice server;

  const Home({Key key, @required this.server}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  BluetoothConnection connection;
  String prevString = '';
  String _messageBuffer = '';
  bool ispaused = true;
  bool isConnecting = true;
  bool get isConnected => connection != null && connection.isConnected;
  bool isDisconnecting = false;
  String level = '0.0';
  List<String> dataList = [];

  Timer timer;

  @override
  void initState() {
    super.initState();

    addPoints();

    /// ########################################## Start Bluetooth ########################################## ///
    BluetoothConnection.toAddress(widget.server.address).then((_connection) {
      print('Connected to the device');
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });

      connection.input.listen(_onDataReceived).onData((data) {
        // Allocate buffer for parsed data
        int backspacesCounter = 0;
        data.forEach((byte) {
          if (byte == 8 || byte == 127) {
            backspacesCounter++;
          }
        });
        Uint8List buffer = Uint8List(data.length - backspacesCounter);
        int bufferIndex = buffer.length;

        // Apply backspace control character
        backspacesCounter = 0;
        for (int i = data.length - 1; i >= 0; i--) {
          if (data[i] == 8 || data[i] == 127) {
            backspacesCounter++;
          } else {
            if (backspacesCounter > 0) {
              backspacesCounter--;
            } else {
              buffer[--bufferIndex] = data[i];
            }
          }
        }
        // Create message if there is new line character
        String dataString = String.fromCharCodes(buffer);
        dataList.add(dataString);

        print('data ${dataList.join().split(",").last}');
        try {
          String x = dataList.join().split(",").last;
          double.parse(x);

          level = x;
          print('XXXXX' + level);

          spots3.add(FlSpot(
              (spots3.length + 1).toDouble(), int.parse(level).toDouble()));
        } catch (e) {
          // level = '00.0';
        }
        if (isDisconnecting) {
          print('Disconnecting locally!');
        } else {
          print('Disconnected remotely!');
        }
        if (this.mounted) {
          setState(() {});
        }
      });
      setState(() {});
    }).catchError((error) {
      print('Cannot connect, exception occured');
      print(error);
    });

    /// ########################################## End Bluetooth ########################################## ///
  }

  /// ########################################## Start Dispose  ########################################## ///
  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection.dispose();
      connection = null;
    }

    super.dispose();
  }

  /// ########################################## End Dispose  ########################################## ///

  /// ########################################## Start on Data Received  ########################################## ///
  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    int index = buffer.indexOf(13);
    if (~index != 0) {
      setState(() {
        _messageBuffer = dataString.substring(index);
      });
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }
    setState(() {});
  }

  /// ########################################## End on Data Received  ########################################## ///

  final List<Color> gradientColors = [
    const Color(0xff23b6e6),
    // const Color(0xff02d39a),
  ];

  final List<Color> gradientColors2 = [
    Color.fromARGB(255, 1, 211, 54),
    // Color.fromARGB(255, 230, 35, 155),
  ];
  final List<Color> gradientColors3 = [
    Color.fromARGB(255, 255, 0, 0),
    // Color.fromARGB(255, 216, 255, 41),
  ];
  final List<Color> gradientColorsSample = [
    Colors.blue,
  ];
  final List<Color> gradientColorsSampleN = [
    Colors.green,
  ];
  final List<Color> gradientColorsXR = [
    Colors.red,
    // Color.fromARGB(255, 216, 255, 41),
  ];
  int lastTime = 0;
  addPoints() {
    timer = Timer.periodic(Duration(milliseconds: 1000), (Timer t) {
      int index1 = lastTime % signal1.length;
      int index2 = lastTime % signal2.length;

      setState(() {
        if (!ispaused) {
          spots1.add(
              FlSpot(lastTime.toDouble(), signal1[index1].y.toDouble() / 10));
          spots2.add(
              FlSpot(lastTime.toDouble(), signal2[index2].y.toDouble() / 10));
          // spots3.add(
          //     FlSpot(lastTime.toDouble(), signal2[index].y.toDouble() + 500));

          lastTime++;
          if (lastTime == (n + 1) * m + n) {
            calcRAndXParams();
          } else if (lastTime % n == 0 && lastTime > n * m) {
            List x = spots1.sublist(samplesMean.length, spots1.length);
            print("Last Time: $lastTime");
            print("spots1 - ${spots1.length}: " + spots1.toString());
            print("samplesMean - ${samplesMean.length}: " +
                samplesMean.toString());
            print("sub: " + x.toString());
            getNewSamples(x);
          }
        }
      });
    });
  }

  List<double> r = [], xBar = [];

  getNewSamples(List<FlSpot> newSample) {
    print(newSample.toString());

    /// calc r and x bar
    for (var i = 0; i < m; i++) {
      print("loop$i: ${(n * i)} ${(n * i) + n} ${newSample.length}");

      /// calc r
      r.add(newSample
              .sublist((n * i), (n * i) + n)
              .reduce((curr, next) => curr.y > next.y ? curr : next)
              .y -
          newSample.reduce((curr, next) => curr.y < next.y ? curr : next).y);

      samplesRange.add(FlSpot(samplesRange.length + 1.toDouble(), r[i]));

      /// calc x bar
      double sumX = 0;
      newSample.sublist((n * i), (n * i) + n).forEach((element) {
        sumX += element.y;
      });
      xBar.add(sumX / n);
      samplesMean.add(FlSpot(samplesMean.length + 1.toDouble(), xBar[i]));
    }
  }

  calcRAndXParams() {
    r.clear();
    xBar.clear();

    double xDBar = 0, rBar = 0;
    List<FlSpot> samples = [];

    // if (selectedSignal == 1) {
    //   samples.addAll(spots1.sublist(1, (n * m) + 1));
    // } else if (selectedSignal == 2) {
    //   samples.addAll(spots2.sublist(1, (n * m) + 1));
    // } else if (selectedSignal == 3) {
    //   samples.addAll(spots3.sublist(1, (n * m) + 1));
    // }

    samples.addAll(spots1);

    /// calc r and x bar
    for (var i = 0; i < m; i++) {
      /// calc r
      r.add(samples
              .sublist((n * i), (n * i) + n)
              .reduce((curr, next) => curr.y > next.y ? curr : next)
              .y -
          samples.reduce((curr, next) => curr.y < next.y ? curr : next).y);
      rBar += r[i];
      samplesRange.add(FlSpot(samplesRange.length + 1.toDouble(), r[i]));

      /// calc x bar
      double sumX = 0;
      samples.sublist((n * i), (n * i) + n).forEach((element) {
        sumX += element.y;
      });
      xBar.add(sumX / n);
      samplesMean.add(FlSpot(samplesMean.length + 1.toDouble(), xBar[i]));
      xDBar += xBar[i];
    }

    /// calc r bar
    rBar /= m;

    /// calc x double bar
    xDBar /= m;

    /// calc x chart params
    uclX = xDBar + a2 * rBar;
    clX = xDBar;
    lclX = xDBar - a2 * rBar;

    /// calc r chart params
    uclR = d4 * rBar;
    clR = rBar;
    lclR = d3 * rBar;
  }

  /// signals spots
  List<FlSpot> spots1 = [FlSpot(0, 0)];
  List<FlSpot> spots2 = [FlSpot(0, 0)];
  List<FlSpot> spots3 = [FlSpot(0, 0)];
  List<FlSpot> samplesMean = [FlSpot(0, 0)];
  List<FlSpot> samplesRange = [FlSpot(0, 0)];

  /// r and x charts params
  double uclR = 0;
  double clR = 0;
  double lclR = 0;
  double uclX = 0;
  double clX = 0;
  double lclX = 0;
  int n = 3, m = 3;
  double a2 = 1.02, d3 = 0, d4 = 2.57;

  // ui varaibles
  bool underLine = false;
  bool showEMG = true;
  bool showECG = true;
  bool showPulse = true;
  bool isRChart = false;
  int selectedSignal = 1;
  int _selectedIndex = 0;
  static List<Widget> _widgetOptions = <Widget>[
    Container(),
    NormalScreen(),
    AnalysisScreen(),
    DevelopersScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        elevation: 20,
        title: const Text('Multi Signal Viewer'),
        leading: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 0, 0),
          child: Image.asset(
            'assets/akwa.png',
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: !ispaused
                  ? Icon(Icons.pause_rounded)
                  : Icon(Icons.play_arrow_rounded),
              color: ispaused ? Colors.green : Colors.orange,
              onPressed: () {
                setState(() {
                  ispaused = !ispaused;
                  timer.cancel();
                  addPoints();
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: Icon(Icons.stop_rounded),
              color: Colors.red,
              onPressed: () {
                setState(() {
                  spots1 = [FlSpot(0, 0)];
                  spots2 = [FlSpot(0, 0)];
                  spots3 = [FlSpot(0, 0)];
                  samplesMean = [FlSpot(0, 0)];
                  samplesRange = [FlSpot(0, 0)];
                  timer.cancel();
                  lastTime = 1;
                  ispaused = true;
                });
              },
            ),
          ),
        ],
      ),
      body: _selectedIndex == 0
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Checkbox(
                        value: showEMG,
                        fillColor: MaterialStateProperty.all(gradientColors[0]),
                        onChanged: (val) {
                          setState(() {
                            showEMG = !showEMG;
                          });
                        }),
                    Text("EMG"),
                    Checkbox(
                        value: showECG,
                        fillColor:
                            MaterialStateProperty.all(gradientColors2[0]),
                        onChanged: (val) {
                          setState(() {
                            showECG = !showECG;
                          });
                        }),
                    Text("ECG"),
                    Checkbox(
                        value: showPulse,
                        fillColor:
                            MaterialStateProperty.all(gradientColors3[0]),
                        onChanged: (val) {
                          setState(() {
                            showPulse = !showPulse;
                          });
                        }),
                    Text("Pulse"),
                  ],
                ),
                Expanded(
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 30, 20, 10),
                        child: Container(
                          width:
                              MediaQuery.of(context).size.width * lastTime / 12,
                          height: MediaQuery.of(context).size.height,
                          child: LineChart(
                            LineChartData(
                              minX: 0,
                              maxX: lastTime.toDouble(),
                              minY: -120,
                              maxY: 300,
                              titlesData: LineTitles.getTitleData(),
                              clipData: FlClipData.all(),
                              axisTitleData: FlAxisTitleData(
                                //   show: true,
                                //   bottomTitle: AxisTitle(
                                //     showTitle: true,
                                //     titleText: 'Time (sec)',
                                //     textStyle: TextStyle(
                                //       color: Colors.black,
                                //       fontWeight: FontWeight.bold,
                                //       fontSize: 15,
                                //     ),
                                //   ),
                                leftTitle: AxisTitle(
                                  showTitle: true,
                                  titleText: 'Voltage (v)',
                                  textStyle: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              gridData: FlGridData(
                                show: true,
                                horizontalInterval: 100,
                                getDrawingHorizontalLine: (value) {
                                  return FlLine(
                                    color: Colors.grey[400],
                                    strokeWidth: 1,
                                  );
                                },
                                drawVerticalLine: true,
                                verticalInterval: 0.5,
                                getDrawingVerticalLine: (value) {
                                  return FlLine(
                                    color: Colors.grey[400],
                                    strokeWidth: 1,
                                  );
                                },
                              ),
                              borderData: FlBorderData(
                                show: true,
                                border: Border.all(
                                    color: const Color(0xff37434d), width: 1),
                              ),
                              lineBarsData: [
                                LineChartBarData(
                                  show: showEMG,
                                  spots: spots1,
                                  isCurved: true,
                                  colors: gradientColors,
                                  barWidth: 3,
                                  belowBarData: BarAreaData(
                                    show: underLine,
                                    colors: gradientColors
                                        .map((color) => color.withOpacity(0.3))
                                        .toList(),
                                  ),
                                ),
                                LineChartBarData(
                                  show: showECG,
                                  spots: spots2,
                                  isCurved: true,
                                  colors: gradientColors2,
                                  barWidth: 3,
                                  belowBarData: BarAreaData(
                                    show: underLine,
                                    colors: gradientColors2
                                        .map((color) => color.withOpacity(0.3))
                                        .toList(),
                                  ),
                                ),
                                LineChartBarData(
                                  show: showPulse,
                                  spots: spots3,
                                  isCurved: true,
                                  colors: gradientColors3,
                                  barWidth: 3,
                                  belowBarData: BarAreaData(
                                    show: underLine,
                                    colors: gradientColors3
                                        .map((color) => color.withOpacity(0.3))
                                        .toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Time x10^-1 (sec)'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Switch(
                                value: underLine,
                                onChanged: (val) {
                                  setState(() {
                                    underLine = !underLine;
                                  });
                                }),
                            Text("Below Graph")
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : _selectedIndex == 1
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Radio(
                          //   groupValue: selectedSignal,
                          //   value: 1,
                          //   fillColor:
                          //       MaterialStateProperty.all(gradientColors[0]),
                          //   onChanged: (val) {
                          //     setState(() {
                          //       selectedSignal = val;
                          //     });
                          //   },
                          // ),
                          // Text("EMG"),
                          // Radio(
                          //   groupValue: selectedSignal,
                          //   value: 2,
                          //   fillColor:
                          //       MaterialStateProperty.all(gradientColors2[0]),
                          //   onChanged: (val) {
                          //     setState(() {
                          //       selectedSignal = val;
                          //     });
                          //   },
                          // ),
                          // Text("ECG"),
                          // Radio(
                          //   groupValue: selectedSignal,
                          //   value: 3,
                          //   fillColor:
                          //       MaterialStateProperty.all(gradientColors3[0]),
                          //   onChanged: (val) {
                          //     setState(() {
                          //       selectedSignal = val;
                          //     });
                          //   },
                          // ),
                          // Text("Pulse"),
                          Text(
                              "LCL= ${(isRChart ? lclR : lclX).toStringAsFixed(3)}"),
                          Text(
                              "CL= ${(isRChart ? clR : clX).toStringAsFixed(3)}"),
                          Text(
                              "UCL= ${(isRChart ? uclR : uclX).toStringAsFixed(3)}"),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(10, 30, 20, 10),
                            child: Container(
                              width: MediaQuery.of(context).size.width *
                                  lastTime /
                                  12,
                              height: MediaQuery.of(context).size.height,
                              child: LineChart(
                                LineChartData(
                                  minX: 0,
                                  maxX: lastTime.toDouble(),
                                  minY: isRChart ? lclR - 500 : lclX - 500,
                                  maxY: isRChart ? uclR + 500 : uclX + 500,
                                  titlesData: LineTitles.getTitleData(),
                                  clipData: FlClipData.all(),
                                  axisTitleData: FlAxisTitleData(
                                    //   show: true,
                                    //   bottomTitle: AxisTitle(
                                    //     showTitle: true,
                                    //     titleText: 'Time (sec)',
                                    //     textStyle: TextStyle(
                                    //       color: Colors.black,
                                    //       fontWeight: FontWeight.bold,
                                    //       fontSize: 15,
                                    //     ),
                                    //   ),
                                    leftTitle: AxisTitle(
                                      showTitle: true,
                                      titleText: 'Voltage (v)',
                                      textStyle: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  gridData: FlGridData(
                                    show: true,
                                    horizontalInterval: 100,
                                    getDrawingHorizontalLine: (value) {
                                      return FlLine(
                                        color: Colors.grey[400],
                                        strokeWidth: 1,
                                      );
                                    },
                                    drawVerticalLine: true,
                                    verticalInterval: 0.5,
                                    getDrawingVerticalLine: (value) {
                                      return FlLine(
                                        color: Colors.grey[400],
                                        strokeWidth: 1,
                                      );
                                    },
                                  ),
                                  borderData: FlBorderData(
                                    show: true,
                                    border: Border.all(
                                        color: const Color(0xff37434d),
                                        width: 1),
                                  ),
                                  lineBarsData: [
                                    // UCL
                                    LineChartBarData(
                                      spots: isRChart
                                          ? samplesRange
                                              .map((e) => FlSpot(e.x, uclR))
                                              .toList()
                                          : samplesMean
                                              .map((e) => FlSpot(e.x, uclX))
                                              .toList(),
                                      isCurved: true,
                                      colors: gradientColorsXR,
                                      barWidth: 3,
                                      aboveBarData: BarAreaData(
                                        colors: gradientColorsXR
                                            .map((color) =>
                                                color.withOpacity(0.3))
                                            .toList(),
                                      ),
                                    ),

                                    // CL
                                    LineChartBarData(
                                      spots: isRChart
                                          ? samplesRange
                                              .map((e) => FlSpot(e.x, clR))
                                              .toList()
                                          : samplesMean
                                              .map((e) => FlSpot(e.x, clX))
                                              .toList(),
                                      isCurved: true,
                                      colors: gradientColorsSampleN,
                                      barWidth: 3,
                                    ),
                                    // LCL
                                    LineChartBarData(
                                      spots: isRChart
                                          ? samplesRange
                                              .map((e) => FlSpot(e.x, lclR))
                                              .toList()
                                          : samplesMean
                                              .map((e) => FlSpot(e.x, lclX))
                                              .toList(),
                                      isCurved: true,
                                      colors: gradientColorsXR,
                                      barWidth: 3,
                                      belowBarData: BarAreaData(
                                        colors: gradientColorsXR
                                            .map((color) =>
                                                color.withOpacity(0.3))
                                            .toList(),
                                      ),
                                    ),

                                    LineChartBarData(
                                      spots:
                                          isRChart ? samplesRange : samplesMean,
                                      // isCurved: true,
                                      colors: gradientColorsSample,
                                      barWidth: 3,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('Time x10^-1 (sec)'),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text("X-Chart"),
                                Switch(
                                    value: isRChart,
                                    onChanged: (val) {
                                      setState(() {
                                        isRChart = !isRChart;
                                      });
                                    }),
                                Text("R-Chart")
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(.1),
            )
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
              backgroundColor: Colors.grey[900],
              rippleColor: Colors.grey[300],
              hoverColor: Colors.grey[500],
              gap: 8,
              activeColor: Colors.white,
              iconSize: 24,
              curve: Curves.easeInCubic,
              tabBackgroundGradient: LinearGradient(
                  colors: [Colors.deepPurple[900], Colors.blueAccent],
                  begin: const FractionalOffset(0.0, 0.0),
                  end: const FractionalOffset(0.7, 0.0),
                  stops: [0.0, 1.0],
                  tileMode: TileMode.clamp),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              duration: Duration(milliseconds: 500),
              color: Colors.white,
              tabs: [
                GButton(
                  icon: Icons.auto_graph_outlined,
                  text: 'Graph',
                ),
                GButton(
                  icon: Icons.bar_chart_outlined,
                  text: 'Charts',
                ),
                GButton(
                  icon: Icons.widgets_outlined,
                  text: 'Diagram',
                ),
                GButton(
                  icon: Icons.developer_mode_rounded,
                  text: 'Developers',
                ),
              ],
              selectedIndex: _selectedIndex,
              onTabChange: (index) {
                setState(() {
                  _selectedIndex = index;
                });
                // myProv.setPoints = [Point(0, 0)];
              },
            ),
          ),
        ),
      ),
    );
  }
}
