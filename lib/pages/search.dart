import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:weather_app/pages/home.dart';
import 'package:weather_app/models/weatherData.dart';
import 'package:weather_app/util/env.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  late CurrentWeather currentlyWeather;

  bool showLoading = false;
  bool showError = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor('#444c4f'),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Center(child: Text('Search')),
        elevation: 0.0,
        actions: [
          SizedBox(
            width: 50,
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
                padding: const EdgeInsets.only(left: 30, right: 30, top: 150),
                child: TextField(
                  style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xffbdc6cf)),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white10,
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.white, width: 2.0),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(const Radius.circular(15.0)),
                    ),
                    hintText: 'Enter a city name',
                    hintStyle: TextStyle(
                      color: Color(0xFFbdc6cf),
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  /////////////
                  autofocus: true,
                  onSubmitted: (val) async {
                    setState(() {
                      showLoading = !showLoading;
                      showError = false;
                    });
                    final cw = await getCurrentWeather(val);
                    print(val);
                    if (cw != null) {
                      var box = await Hive.openBox('myBox');
                      box.put('city', val);
                      Navigator.pop(context, currentlyWeather.cityName);
                    }
                    // var box = await Hive.openBox('myBox');
                    // box.put('city', val);
                    // if(cw.cityName != '') {
                    //   Navigator.pop(context, currentlyWeather.cityName);
                    // }
                  },
                )),
            SizedBox(
              height: 20,
            ),
            showError
                ? Text(
                    'City not found!',
                    style: TextStyle(color: Colors.red, fontSize: 25),
                  )
                : SizedBox(),
            SizedBox(
              height: 60,
            ),
            showLoading
                ? SpinKitFadingCircle(color: Colors.white, size: 50.0)
                : SizedBox(),
          ],
        ),
      ),
    );
  }

  Future getCurrentWeather(String city) async {
    CurrentWeather currentWeather;

    var url =
        'https://api.openweathermap.org/data/2.5/weather?q=$city&units=metric&appid=${Env().apiKey}';

    // final response;
    // try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      currentWeather = CurrentWeather.fromJson(jsonDecode(response.body));

      print(currentWeather.cityName);
      setState(() {
        currentlyWeather = currentWeather;
        showLoading = false;
        // simpleReady = false;
      });
      return currentWeather;
    } else {
      /// to do
      print('Error');
      setState(() {
        showLoading = false;
        showError = true;
        // simpleReady = true;
      });
      return;
    }
    // }catch(_){
    //   setState(() {
    //     showLoading = false;
    //   });
    //   return;
    // }
  }
}
