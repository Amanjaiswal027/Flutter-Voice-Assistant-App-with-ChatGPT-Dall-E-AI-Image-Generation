import 'package:currency_converter/home_page.dart';
import 'package:currency_converter/pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: "secret.env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Allen',
      theme: ThemeData.light().copyWith(
          scaffoldBackgroundColor: Pallete.whiteColor,
          appBarTheme: AppBarTheme(backgroundColor: Pallete.whiteColor)),
      home: const HomePage(),
    );
  }
}
