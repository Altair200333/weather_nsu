import 'package:http/http.dart' as http;
import 'dart:math';
import 'dart:convert';

class Weather
{
  String rawData;
  String temperature;
  List <int> xint;
  List <int> yint;
  List<String> verticalLabels;
  //plot data
  Weather(String raw)
  {
    rawData = raw;
    String regex = r"\d+\.\d+&deg;C\';";
    final doubleRegex = RegExp(regex, multiLine: true);
    var res = doubleRegex.firstMatch(rawData);
    String temperatureString = res.group(0);
    temperature = temperatureString.substring(0, temperatureString.indexOf('&'));
  }
  void fetchPlotData()
  {
    loadPoints();
    //--
    loadVerticalLabel();
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
    String regex = r"(?<=\[)(.*?)(?=\])";
    final dataRegex = RegExp(regex, multiLine: true);
    var res = dataRegex.allMatches(rawData);

    var x = res.elementAt(0);
    List<String> xstr = x.group(0).toString().split(",");
    xint = xstr.map(int.parse).toList();

    var y = res.elementAt(1);
    List<String> ystr = y.group(0).toString().split(",");
    yint = ystr.map(int.parse).toList();
    for(int i=0;i<yint.length;++i)
    {
      yint[i] = -yint[i];
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
        'tick': mills.toString(),
        'rand':'0.8170059955126809',//??? bruh
        'std':'three'
      };
      var uri = Uri.http('weather.nsu.ru', '/loadata.php', queryParams);
      var response = await http.get(uri, headers: {});

      return Weather(response.body);
    }
    catch(_)
    {
      return null;
    }

  }
}