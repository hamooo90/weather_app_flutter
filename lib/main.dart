// import 'dart:js';

import 'package:flutter/material.dart';

import 'package:weather_app/pages/home.dart';
import 'package:weather_app/pages/search.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {

  await Hive.initFlutter();


  runApp(MaterialApp(

    debugShowCheckedModeBanner: false,
    routes: {
      '/' : (context) => Home(),
      '/search' : (context) => Search() ,


    },
  ));
}

