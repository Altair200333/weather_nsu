import 'package:http/http.dart' as http;
import 'dart:math';
import 'dart:convert';

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

  void loadPoints() {
    String regex = r"(?<=\>)(.*?)(?=\<\/temp\>)";
    final dataRegex = RegExp(regex, multiLine: true);
    var res = dataRegex.allMatches(rawData);

    String regexOnX = """(?<=temp timestamp\=\")(.*?)(?=\"\>)""";
    final xRegex = RegExp(regexOnX, multiLine: true);
    var resX = xRegex.allMatches(rawData);

    xint = new List();
    yint = new List();

    for(int i=0;i<res.length;++i)
    {
      xint.add(int.parse(resX.elementAt(i).group(0)));
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