import 'package:flutter/material.dart';
import '../utils/utils.dart' as utils;
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherApp extends StatefulWidget {
  _WeatherAppState createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  String _cityEntered;

  Future _goToNextScreen(BuildContext context) async {
    Map _result = await Navigator.of(context).push(
      MaterialPageRoute<Map>(builder: (BuildContext context) {
        return ChangeCity();
      }),
    );
    if (_result != null && _result.containsKey('enter')) {
      _cityEntered = _result['enter'];
    } else {
      _result['enter'] = 'Nothing';
    }
    // print(_result);
  }

  void getWeather() async {
    Map _data = await getData(
      utils.apiId,
      utils.defaultCity,
    );
    print(_data.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Weather',
          style: cityStyle(),
        ),
        backgroundColor: Colors.grey.shade100,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.menu,
              color: Colors.grey.shade800,
              size: 30.0,
            ),
            // onPressed: () => getWeather(),
            onPressed: () => _goToNextScreen(context),
          ),
        ],
      ),
      body: Container(
        child: Center(
          child: Stack(
            children: <Widget>[
              Opacity(
                child: Image.asset(
                  'images/img3.jpg',
                  width: 500.0,
                  height: 1200.0,
                  fit: BoxFit.fill,
                ),
                opacity: 0.68,
              ),
              Container(
                  margin: EdgeInsets.fromLTRB(20.0, 20.0, 0.0, 0.0),
                  alignment: Alignment.topLeft,
                  child: Text(
                      "${_cityEntered == null ? utils.defaultCity : _cityEntered}"
                          .toUpperCase(),
                      style: cityStyle())),
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 150.0),
                child: Image.asset(
                  'images/thunder.png',
                  width: 150.0,
                  height: 150.0,
                  fit: BoxFit.fill,
                  color: Colors.grey.shade800,
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.fromLTRB(30.0, 300.0, 0.0, 0.0),
                child: updateTempWidget(_cityEntered),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Getting data through openweatherapp.org using api
  //source https://openweathermap.org/
  Future<Map> getData(String apiId, String city) async {
    String apiUrl =
        "http://api.openweathermap.org/data/2.5/weather?q=$city&appid=${utils.apiId}&units=metric";
    // metric = celcius; imperial = fahrenheit
    http.Response response = await http.get(apiUrl);
    return json.decode(response.body);
  }

  Widget updateTempWidget(String city) {
    return FutureBuilder(
      future: getData(utils.apiId, city == null ? utils.defaultCity : city),
      builder: (BuildContext context, AsyncSnapshot<Map> snapshot) {
        if (snapshot.hasData) {
          Map content = snapshot.data;
          return Container(
            child: Column(
              children: <Widget>[
                ListTile(
                  title: Text(
                    content['main']['temp'].toString() + "°C",
                    style: tempStyle(),
                  ),
                  subtitle: Text(
                    "Humaidity : ${content['main']['humidity'].toString()} \n"
                        "Max : ${content['main']['temp_max'].toString()} °C\n"
                        "Min : ${content['main']['temp_min'].toString()} °C\n",
                    style: weatherFont(),
                  ),
                ),
              ],
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }
}

class ChangeCity extends StatelessWidget {
  final _inputController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Weather',
          style: TextStyle(
            fontSize: 25.0,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 2.0,
          ),
        ),
        backgroundColor: Colors.black54,
      ),
      body: Container(
        child: Center(
          child: ListView(
            children: <Widget>[
              ListTile(
                title: TextField(
                  controller: _inputController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    hintText: 'Enter City',
                    labelText: 'City',
                  ),
                ),
              ),
              ListTile(
                title: FlatButton(
                  color: Colors.black54,
                  onPressed: () {
                    Navigator.pop(context, {
                      'enter': _inputController.text,
                    });
                  },
                  child: Text(
                    'Get Weather!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

TextStyle cityStyle() {
  return TextStyle(
    fontSize: 22.0,
    fontWeight: FontWeight.w800,
    color: Colors.grey.shade800,
    letterSpacing: 2.0,
  );
}

TextStyle tempStyle() {
  return TextStyle(
    fontSize: 60.0,
    fontWeight: FontWeight.w900,
    color: Colors.grey.shade800,
    letterSpacing: 2.0,
  );
}

TextStyle weatherFont() {
  return TextStyle(
    fontSize: 18.0,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.w900,
    color: Colors.grey.shade800,
    letterSpacing: 1.5,
  );
}
