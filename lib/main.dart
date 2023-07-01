import 'package:chat_gpt/Pages/ChatGPT_screen.dart';
import 'package:flutter/material.dart';

void main() async {
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key:key);

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ChatGPT',
      theme: ThemeData(useMaterial3: true),
      home: Center(
        child: Chat_GPT_Screen(),
      ),
    );
  }
}
