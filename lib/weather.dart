import 'package:http/http.dart' as http;
import 'dart:math';
import 'dart:convert';

class Weather
{
  String rawData;
  String temperature;
  List <double> xint;
  List <double> yint;
  List<String> verticalLabels;
  //plot data
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
    //--
    //loadVerticalLabel();
  }
  int temp()
  {
    return double.parse(temperature).round();
  }
  void loadVerticalLabel() {
    String regex = r"(?<=(\<b\>))(.*?)(?=\&deg\;)";
    final dataRegex = RegExp(regex, multiLine: true);
    var res = dataRegex.allMatches(rawData);

    verticalLabels = new List();
    for(int i=0;i<res.length;++i) {
      verticalLabels.add(res.elementAt(i).group(0).toString());
    }
  }

  void loadPoints() {
    String regex = r"(?<=\>)(.*?)(?=\<\/temp\>)";
    final dataRegex = RegExp(regex, multiLine: true);
    var res = dataRegex.allMatches(rawData);
    yint = new List();
    xint = new List();
    for(int i=0;i<res.length;++i)
    {
      xint.add(i.toDouble());
      yint.add(double.parse(res.elementAt(i).group(0)));
    }
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