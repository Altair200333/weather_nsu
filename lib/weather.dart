import 'package:xml/xml.dart';

import 'package:http/http.dart' as http;
import 'dart:math';
import 'dart:convert';
import 'package:flutter/foundation.dart';

class Weather
{
  String rawData;
  String temperature;
  List <int> xint;
  List <double> yint;
  Weather(String raw)
  {
    rawData = raw;
    String regex = r"(?<=\>)(.*?)(?=\<\/current\>)";
    final doubleRegex = RegExp(regex, multiLine: true);
    var res = doubleRegex.firstMatch(rawData);
    String temperatureString = res.group(0);
    temperature = temperatureString;
  }
  void fetchPlotData()
  {
    loadPoints();
  }
  int temp()
  {
    return double.parse(temperature).round();
  }

  void loadPoints() async{
    final document = XmlDocument.parse(rawData);
    final titles = document.findAllElements('temp');

    xint = new List();
    yint = new List();
    
    titles.map((node) => node)
        .forEach(
            (var w){
              xint.add(double.parse(w.getAttribute("timestamp")).toInt());
              yint.add(double.parse(w.text));
            });
  }
}
class WeatherLoader
{
  static Future<Weather> getWeather() async
  {
    try{
      var now = DateTime.now();
      int mills = (now.millisecondsSinceEpoch/1000).round();
      String address = 'weather.nsu.ru';
      var queryParams  = {
        'std':'three'
      };
      var uri = Uri.http('weather.nsu.ru', '/weather.xml');
      var response = await http.get(uri, headers: {});

      return Weather(response.body);
    }
    catch(_)
    {
      return null;
    }

  }
}