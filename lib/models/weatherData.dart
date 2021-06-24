import 'dart:convert';

import 'package:flutter/foundation.dart';

class CurrentWeather {
   String cityName;
   var lat;
   var lon;
   String weatherIcon;
   String weatherString;
   var temp;
   var humidity;
   var windSpeed;
   int date;
   int offset;

  CurrentWeather(
      {required this.cityName,
      required this.lat,
      required this.lon,
      required this.weatherIcon,
      required this.weatherString,
      required this.temp,
      required this.humidity,
      required this.windSpeed,
      required this.date,
      required this.offset});

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
        cityName: json['name'],
        lat: json['coord']['lat'],
        lon: json['coord']['lon'],
        weatherIcon: json['weather'][0]['icon'],
        weatherString: json['weather'][0]['main'],
        temp: json['main']['temp'],
        humidity: json['main']['humidity'],
        windSpeed: json['wind']['speed'],
        date: json['dt'],
        offset: json['timezone']);
  }
}

class WeatherDetail{
  List<WeatherD> dailyWeather;
  List<WeatherH> hourlyWeather;

  WeatherDetail({required this.dailyWeather,required this.hourlyWeather});
  factory WeatherDetail.fromJson(Map<String, dynamic> json) {
    var list = json['daily'] as List;
    List<WeatherD> dailyWeatherList = list.map((weather) => WeatherD.fromJson(weather)).toList();
    var list2 = json['hourly'] as List;
    List<WeatherH> hourlyWeatherList = list2.map((weather) => WeatherH.fromJson(weather)).toList();

    return WeatherDetail(
      dailyWeather: dailyWeatherList,
      hourlyWeather: hourlyWeatherList
    );
  }
}

class WeatherD {
  int date;
  var temp;
  String weatherIcon;

  WeatherD({required this.date, required this.temp, required this.weatherIcon});

  factory WeatherD.fromJson(Map<String, dynamic> json) {
    return WeatherD(
        date: json['dt'],
        temp: json['temp']['day'],
        weatherIcon: json['weather'][0]['icon']);
  }
}

class WeatherH {
  int date;
  var temp;
  String weatherIcon;

  WeatherH({required this.date, required this.temp, required this.weatherIcon});

  factory WeatherH.fromJson(Map<String, dynamic> json) {
    return WeatherH(
        date: json['dt'],
        temp: json['temp'],
        weatherIcon: json['weather'][0]['icon']);
  }
}
