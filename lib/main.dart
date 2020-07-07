import 'package:flutter/material.dart';
import 'package:myownflashcard/db/database.dart';
import 'package:myownflashcard/screens/home_screen.dart';

MyDatabase database;

void main() {
  database = MyDatabase();
  runApp(MyApp());//Myappにしてるとwidget_test.dartでエラーでた
}//main(){}の終わりに;をつけない4

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "私だけの単語帳",
      theme: ThemeData(brightness: Brightness.dark, fontFamily: "Corporate"),
      home: HomeScreen(),
    );
  }
}
