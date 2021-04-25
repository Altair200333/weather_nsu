import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget_callback_dispatcher.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import 'package:weather_nsu/weather.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  initializeDateFormatting();

  WidgetsFlutterBinding.ensureInitialized();
  Workmanager.initialize(callbackDispatcher, isInDebugMode: kDebugMode);

  runApp(MyApp());
}

void callbackDispatcher() {
  Workmanager.executeTask((taskName, inputData) {
    final now = DateTime.now();
    return Future.wait<bool>([
      HomeWidget.saveWidgetData(
        'title',
        'Updated from Background',
      ),
      HomeWidget.saveWidgetData(
        'message',
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
      ),
      HomeWidget.updateWidget(
        name: 'HomeWidgetExampleProvider',
        iOSName: 'HomeWidgetExample',
      ),
    ]).then((value) {
      return !value.contains(false);
    });
  });
}

Future<void> _updateWidget() async {
  try {
    return HomeWidget.updateWidget(
        name: 'HomeWidgetExampleProvider', iOSName: 'HomeWidgetExample');
  } on PlatformException catch (exception) {
    debugPrint('Error Updating Widget. $exception');
  }
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MaterialApp(
      title: 'Weather.nsu',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Weather'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

Future<void> _sendData(String title, String message) async {
  try {
    return Future.wait([
      HomeWidget.saveWidgetData<String>('title', title),
      HomeWidget.saveWidgetData<String>('message', message),
    ]);
  } on PlatformException catch (exception) {
    debugPrint('Error Sending Data. $exception');
  }
}

class _MyHomePageState extends State<MyHomePage> {
  Weather weather;

  void refresh() {
    _sendData("update", "msg");
    _updateWidget();

    loadWeather();
  }

  void loadWeather() async {
    var weather = await WeatherLoader.getWeather();
    weather.fetchPlotData();
    setState(() {
      this.weather = weather;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    HomeWidget.setAppGroupId('YOUR_GROUP_ID');
    HomeWidget.registerBackgroundCallback(backgroundCallback);

    if (Platform.isAndroid) {
      _startBackgroundUpdate();
    }

    loadWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),
              getShadowContainer([
                Text(
                  "Температура за 3 дня",
                  style: TextStyle(fontSize: 20, color: Colors.black, shadows: [
                    Shadow(
                        blurRadius: 10,
                        color: Colors.black38.withAlpha(40),
                        offset: Offset(1, 2))
                  ]),
                ),
                SizedBox(height: 20),
                AspectRatio(
                  aspectRatio: 2.10,
                  child: Container(
                    child: weather != null
                        ? LineChart(
                            mainData(weather),
                          )
                        : Container(),
                  ),
                ),
              ], context),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              getShadowContainer([
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    children: [
                      Text(
                        'Температура у НГУ',
                        style: TextStyle(fontSize: 20, color: Colors.black, shadows: [
                          Shadow(
                              blurRadius: 10,
                              color: Colors.black38.withAlpha(40),
                              offset: Offset(1, 2))
                        ]),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text(DateFormat('kk:mm:ss \nEEE d MMM').format(DateTime.now()),style: TextStyle(fontSize: 20, color: Colors.blue[900], shadows: [
                        Shadow(
                            blurRadius: 6,
                            color: Colors.black54.withAlpha(40),
                            offset: Offset(0, 1))
                      ])),
                      SizedBox(width: 30),
                      Text(
                        weather != null ? weather.temperature + "°" : ":(",
                        style: TextStyle(
                            color: Colors.blue[900],
                            fontSize: 40,
                            fontWeight: FontWeight.normal,
                            ),
                      ),
                    ],
                  ),
                ),
              ], context),
              SizedBox(height: 20),
            ],
          ),
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              getPrimaryColor(weather),
              Colors.white60,
              Colors.white60,
              //getPrimaryColor(weather),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: refresh,
        tooltip: 'Refresh',
        child: Icon(Icons.refresh),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

Widget getShadowContainer(List<Widget> children, BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(3.0),
    child: Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: children,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(15)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 15,
            offset: Offset(2, 0), // changes position of shadow
          ),
        ],
      ),
    ),
  );
}

Color getPrimaryColor(Weather weather) {
  if (weather == null) return Colors.white60;
  if (weather.temp() < 0) return Colors.blue;
  if (weather.temp() < 10)
    return Colors.lightBlueAccent;
  else if (weather.temp() < 20) return Colors.redAccent;
  return Colors.red;
}

void backgroundCallback(Uri data) async {
  print(data);

  if (data.host == 'titleclicked') {
    await HomeWidget.saveWidgetData<String>('title', "message");
    await HomeWidget.updateWidget(
        name: 'HomeWidgetExampleProvider', iOSName: 'HomeWidgetExample');
  }
}

void _startBackgroundUpdate() {
  Workmanager.registerPeriodicTask('1', 'widgetBackgroundUpdate',
      frequency: Duration(minutes: 15));
}

void _stopBackgroundUpdate() {
  Workmanager.cancelByUniqueName('1');
}

LineChartData mainData(Weather weather) {
  List<Color> gradientColors = [
    Colors.red,
    Colors.blue,
  ];
  List<FlSpot> spots = new List();
  for (int i = 0; i < weather.yint.length; ++i) {
    spots.add(FlSpot(weather.xint[i].toDouble(), weather.yint[i].toDouble()));
  }
  var min =
      weather.yint.reduce((curr, next) => curr < next ? curr : next).toDouble();
  var max =
      weather.yint.reduce((curr, next) => curr > next ? curr : next).toDouble();
  Color border = Colors.transparent;
  return LineChartData(
    lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(getTooltipItems: (touchedSpots) {
          return touchedSpots.map((LineBarSpot touchedSpot) {
            final textStyle = TextStyle(
              color: touchedSpot.bar.colors[0],
              fontWeight: FontWeight.bold,
              fontSize: 14,
            );
            var label = weather.verticalLabels.elementAt(
                ((touchedSpot.y - min) /
                        (max - min) *
                        (weather.verticalLabels.length))
                    .clamp(0, weather.verticalLabels.length - 1)
                    .round());
            return LineTooltipItem(label, textStyle);
          }).toList();
        })),
    titlesData: FlTitlesData(
        show: false,
        leftTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          getTitles: (value) {
            var label = weather.verticalLabels.elementAt(
                ((value.toDouble() - min) /
                        (max - min) *
                        (weather.verticalLabels.length))
                    .clamp(0, weather.verticalLabels.length - 1)
                    .round());

            return "";
          },
          getTextStyles: (value) =>
              const TextStyle(color: Colors.black, fontSize: 10),
        ),
        bottomTitles: SideTitles(showTitles: false)),
    gridData: FlGridData(
      show: true,
      drawVerticalLine: true,
      getDrawingHorizontalLine: (value) {
        return FlLine(
          color: border,
          strokeWidth: 1.5,
        );
      },
      getDrawingVerticalLine: (value) {
        return FlLine(
          color: border,
          strokeWidth: 1.5,
        );
      },
    ),
    borderData:
        FlBorderData(show: true, border: Border.all(color: border, width: 1)),
    minY: min,
    maxY: max,
    lineBarsData: [
      LineChartBarData(
        spots: spots,
        isCurved: true,
        colors: gradientColors,
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: false,
        ),
        //belowBarData: BarAreaData(
        //  show: true,
        //  colors: gradientColors.map((color) => color.withOpacity(0.3)).toList(),
        //),
      ),
    ],
  );
}
