import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:weather_app/models/weatherData.dart';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:weather_app/util/env.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';



bool isHour = true;
bool fetchNow=false;

// final apiKey = 'e92f4cb8f2e08e1f8077953fc21d9e1b';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late CurrentWeather currentlyWeather;
  late WeatherDetail weatherDetail;
  bool simpleReady = true;
  bool detailReady = true;


  @override
  void initState()  {
    // TODO: implement initState
    super.initState();
    fetchNow = true;
    // getStringValuesSF();
    getCity();
    // getCurrentWeather('tehran');

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor('#444c4f'),
      appBar: AppBar(
        backwardsCompatibility: false,
        systemOverlayStyle:
        SystemUiOverlayStyle(statusBarColor: HexColor('#5d6568')),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Center(
            child: Text(
              // '${currentlyWeather.cityName}',
              simpleReady ? 'Loading' : '${currentlyWeather.cityName}' ,
              style: GoogleFonts.breeSerif(),
            )),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async  {
              final result = await Navigator.pushNamed(context, '/search');
              // currentlyWeather
              print(result.toString());
              if(result != null) {
                getCurrentWeather(result.toString());
                setState(() {
                  fetchNow = true;
                  simpleReady = true;
                  detailReady = true;
                });
              }

              // print(result);
              //////////////////////

              // showModalBottomSheet(
              //   // isScrollControlled: true,
              //   context: context,
              //   builder: (context) {
              //     // Using Wrap makes the bottom sheet height the height of the content.
              //     // Otherwise, the height will be half the height of the screen.
              //     return Wrap(
              //       children: [
              //         // ListTile(
              //         //   leading: Icon(Icons.share),
              //         //   title: Text('Share'),
              //         // ),
              //         TextField(),
              //       ],
              //     );
              //   },
              // );

              ///////////////////////
            },
          ),
        ],
        leading: IconButton(
          icon: Icon(Icons.refresh),
          onPressed: () async {
            setState(() {
              // detailReady = !detailReady;
              simpleReady = true;
              detailReady = true;
            });
            await getCity();
            getDailyWeather();

          },
        ),
      ),
      body: simpleReady ? SpinKitFadingCircle(color: Colors.white,size: 50.0) : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/${currentlyWeather.weatherIcon}.svg',
              height: MediaQuery
                  .of(context)
                  .size
                  .height / 4,
            ),

            Text(
              '${currentlyWeather.temp.round()}\u00B0C',
              style: GoogleFonts.breeSerif(
                  textStyle: TextStyle(color: Colors.white, fontSize: 35)),
            ),
            Text(
              '${milisToDate(currentlyWeather.date)}',
              // '${milisToDate(currentlyWeather.date).day} of ${milisToDate(currentlyWeather.date).month}',
              style: GoogleFonts.breeSerif(
                  textStyle: TextStyle(color: Colors.white, fontSize: 13)),
            ),
            Text(
              '${currentlyWeather.weatherString}',
              style: GoogleFonts.breeSerif(
                  textStyle: TextStyle(color: Colors.white, fontSize: 25)),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    SvgPicture.asset(
                      'assets/hygrometer.svg',
                      height: 40,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      '${currentlyWeather.humidity}%',
                      style: GoogleFonts.breeSerif(
                          textStyle:
                          TextStyle(color: Colors.white, fontSize: 15)),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    MaterialButton(
                      onPressed: () {
                        setState(() {
                          isHour = true;
                        });
                        print(isHour);
                      },
                      child: Text(
                        'Hourly',
                        style: TextStyle(
                            color: btnTxtColor(isHour),
                            fontWeight: FontWeight.w900),
                      ),
                      color: btnColor(isHour),
                      elevation: 0.0,
                      textColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(color: Colors.white)),
                    ),
                  ],
                ),
                SizedBox(width: MediaQuery
                    .of(context)
                    .size
                    .width / 2.5),
                Column(
                  children: [
                    SvgPicture.asset(
                      'assets/windsock.svg',
                      height: 40,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      '${currentlyWeather.windSpeed}m/s',
                      style: GoogleFonts.breeSerif(
                          textStyle:
                          TextStyle(color: Colors.white, fontSize: 15)),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    MaterialButton(
                      onPressed: () {
                        setState(() {
                          isHour = false;
                        });
                        print(isHour);
                      },
                      child: Text(
                        'Daily',
                        style: TextStyle(
                            color: btnTxtColor(!isHour),
                            fontWeight: FontWeight.w900),
                      ),
                      color: btnColor(!isHour),
                      elevation: 0.0,
                      textColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(color: Colors.white)),
                    ),
                  ],
                )
              ],
            ),
            SizedBox(
              height: 30,
            ),

            // hourlyWeather(),
            // !simpleReady ? Text(currentlyWeather.lat.toString()):Text('No'),
            showDetailWeather(),
            // weatherDetail == null ?
            // SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Color btnColor(bool isHour) {
    return isHour == true ? Colors.white : Colors.transparent;
  }

  Color btnTxtColor(bool isHour) {
    return isHour == true ? Colors.black87 : Colors.white;
  }

  Widget showDetailWeather(){

    if(!simpleReady){

      if(fetchNow){
        getDailyWeather();
        fetchNow = false;
      }
      if(!detailReady){
        return hourlyWeather();
      } else {
        return SpinKitFadingCircle(
          color: Colors.white,
          size: 50.0,
        );
      }
    } else {
      return SpinKitFadingCircle(
        color: Colors.white,
        size: 50.0,
      );
    }
  }

  Widget hourlyWeather() {
    int index=0;

    if (isHour) {
      return SingleChildScrollView( ////Hourly
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                children: [
                  Text(
                    '${weatherDetail.hourlyWeather[1].temp.round()}\u00B0C',
                    // 'sdsd',
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SvgPicture.asset(
                    'assets/${weatherDetail.hourlyWeather[1].weatherIcon}.svg',
                    // 'assets/01d.svg',
                    height: 45,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    '${timeOfDay(weatherDetail.hourlyWeather[1].date)}',
                    // '11111',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                children: [
                  Text(
                    '${weatherDetail.hourlyWeather[3].temp.round()}\u00B0C',
                    // 'sdsd',
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SvgPicture.asset(
                    'assets/${weatherDetail.hourlyWeather[3].weatherIcon}.svg',
                    // 'assets/01d.svg',
                    height: 45,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    '${timeOfDay(weatherDetail.hourlyWeather[3].date)}',
                    // '11111',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                children: [
                  Text(
                    '${weatherDetail.hourlyWeather[5].temp.round()}\u00B0C',
                    // 'sdsd',
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SvgPicture.asset(
                    'assets/${weatherDetail.hourlyWeather[5].weatherIcon}.svg',
                    // 'assets/01d.svg',
                    height: 45,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    '${timeOfDay(weatherDetail.hourlyWeather[5].date)}',
                    // '11111',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                children: [
                  Text(
                    '${weatherDetail.hourlyWeather[7].temp.round()}\u00B0C',
                    // 'sdsd',
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SvgPicture.asset(
                    'assets/${weatherDetail.hourlyWeather[7].weatherIcon}.svg',
                    // 'assets/01d.svg',
                    height: 45,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    '${timeOfDay(weatherDetail.hourlyWeather[7].date)}',
                    // '11111',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                children: [
                  Text(
                    '${weatherDetail.hourlyWeather[9].temp.round()}\u00B0C',
                    // 'sdsd',
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SvgPicture.asset(
                    'assets/${weatherDetail.hourlyWeather[9].weatherIcon}.svg',
                    // 'assets/01d.svg',
                    height: 45,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    '${timeOfDay(weatherDetail.hourlyWeather[9].date)}',
                    // '11111',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                children: [
                  Text(
                    '${weatherDetail.hourlyWeather[11].temp.round()}\u00B0C',
                    // 'sdsd',
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SvgPicture.asset(
                    'assets/${weatherDetail.hourlyWeather[11].weatherIcon}.svg',
                    // 'assets/01d.svg',
                    height: 45,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    '${timeOfDay(weatherDetail.hourlyWeather[11].date)}',
                    // '11111',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                children: [
                  Text(
                    '${weatherDetail.hourlyWeather[13].temp.round()}\u00B0C',
                    // 'sdsd',
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SvgPicture.asset(
                    'assets/${weatherDetail.hourlyWeather[13].weatherIcon}.svg',
                    // 'assets/01d.svg',
                    height: 45,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    '${timeOfDay(weatherDetail.hourlyWeather[13].date)}',
                    // '11111',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),


          ],
        ),
      );
    } else {
      return SingleChildScrollView( ////Daily
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                children: [
                  Text(
                    '${weatherDetail.dailyWeather[1].temp.round()}\u00B0C',
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SvgPicture.asset(
                    'assets/${weatherDetail.dailyWeather[1].weatherIcon}.svg',
                    height: 45,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    dayOfWeek(weatherDetail.dailyWeather[1].date),
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                children: [
                  Text(
                    '${weatherDetail.dailyWeather[2].temp.round()}\u00B0C',
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SvgPicture.asset(
                    'assets/${weatherDetail.dailyWeather[2].weatherIcon}.svg',
                    height: 45,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    dayOfWeek(weatherDetail.dailyWeather[2].date),
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                children: [
                  Text(
                    '${weatherDetail.dailyWeather[3].temp.round()}\u00B0C',
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SvgPicture.asset(
                    'assets/${weatherDetail.dailyWeather[3].weatherIcon}.svg',
                    height: 45,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    dayOfWeek(weatherDetail.dailyWeather[3].date),
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                children: [
                  Text(
                    '${weatherDetail.dailyWeather[4].temp.round()}\u00B0C',
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SvgPicture.asset(
                    'assets/${weatherDetail.dailyWeather[4].weatherIcon}.svg',
                    height: 45,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    dayOfWeek(weatherDetail.dailyWeather[4].date),
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                children: [
                  Text(
                    '${weatherDetail.dailyWeather[5].temp.round()}\u00B0C',
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SvgPicture.asset(
                    'assets/${weatherDetail.dailyWeather[5].weatherIcon}.svg',
                    height: 45,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    dayOfWeek(weatherDetail.dailyWeather[5].date),
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                children: [
                  Text(
                    '${weatherDetail.dailyWeather[6].temp.round()}\u00B0C',
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SvgPicture.asset(
                    'assets/${weatherDetail.dailyWeather[6].weatherIcon}.svg',
                    height: 45,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    dayOfWeek(weatherDetail.dailyWeather[6].date),
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),

      );
    }
  }



  Future getCurrentWeather(String cityName) async {
    CurrentWeather currentWeather;

    var url = 'https://api.openweathermap.org/data/2.5/weather?q=$cityName&units=metric&appid=${Env().apiKey}';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      currentWeather = CurrentWeather.fromJson(jsonDecode(response.body));

      print(currentWeather.cityName);
      setState(() {
        currentlyWeather = currentWeather;
        milisToDate(currentlyWeather.date);
        simpleReady = false;
      });
      return currentWeather;
    } else {
      /// to do
      setState(() {
        simpleReady = true;
      });
      return;
    }
  }

  Future getDailyWeather() async {
    WeatherDetail detail;
    print('start');
    var url = 'https://api.openweathermap.org/data/2.5/onecall?lat=${currentlyWeather.lat}&lon=${currentlyWeather.lon}&units=metric&exclude=current,minutely,alerts&appid=${Env().apiKey}';
    print(url);
    final response = await http.get(Uri.parse(url));
    var result = jsonDecode(response.body);
    if (response.statusCode == 200) {
      detail = WeatherDetail.fromJson(result);
      print('response ok');
      if(detailReady) {
        setState(() {
          weatherDetail = detail;
          detailReady = false;
          print('ready');
        });
      }
      return ;
    } else {
      setState(() {
        detailReady = true;
        print('not ready');

      });
      return;
    }
  }



  String timeOfDay(int milis){
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch((milis+currentlyWeather.offset)*1000).toUtc();

    // print('${dateTime.year}-${dateTime.month}-${dateTime.day}-${dateTime.hour}-${dateTime.minute}');
    // print(dateTime.timeZoneOffset);
    String dt = DateFormat('kk:mm').format(dateTime);
    return dt;
  }
  String dayOfWeek(int milis){
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch((milis+currentlyWeather.offset)*1000);
    String dt = DateFormat('EEEEE').format(dateTime);
    return dt;
  }
  String milisToDate(int milis){
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch((milis+currentlyWeather.offset)*1000);
    String dt = DateFormat('dd of MMMM').format(dateTime);
    // print(dt);
    return dt;
  }

  Future<void> getCity() async {
    var box = await Hive.openBox('myBox');
    var cityName = box.get('city');
    if(cityName == null || cityName == ''){
      cityName = 'tehran';
    }
    print('city name: $cityName');
    await getCurrentWeather(cityName);

  }

}

