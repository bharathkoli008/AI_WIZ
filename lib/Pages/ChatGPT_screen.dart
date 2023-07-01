import 'dart:convert';
import 'dart:typed_data';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:chat_gpt/Pages/Chat_Options.dart';
import 'package:chat_gpt/api_key.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_indicator/loading_indicator.dart';
import 'package:page_transition/page_transition.dart';
import 'package:speech_to_text/speech_to_text.dart';

class Chat {
  final String text;
  final bool isME;
  final bool isimage;

  Chat({required this.text,required this.isME,required this.isimage});
}


class Chat_GPT_Screen extends StatefulWidget {
  const Chat_GPT_Screen({Key? key}) : super(key: key);

  @override
  State<Chat_GPT_Screen> createState() => _Chat_GPT_ScreenState();
}

class _Chat_GPT_ScreenState extends State<Chat_GPT_Screen> {


  final List<Chat> chats = [];
  SpeechToText speechToText = SpeechToText();
  final flutterTTs = FlutterTts();


  final TextEditingController _text = TextEditingController();

  onSendChat() async {
    setState(() {
      isrecording = false;
      isGenerating = true;
    });




    Chat chat = Chat(text: _text.text, isME: true,isimage: false);

    _text.clear();

    setState(() {
      chats.insert(0, chat);
    });




    if(!isimage){
      String response  = await sendtoGPT(chat.text);
      Chat reply = Chat(text: response, isME: false,isimage: false);
      setState(() {
        chats.insert(0, reply);
        if(!istalking){
          speak();
        }
      });
    } else{
      String response  = await sendtodalle(chat.text);
      Chat reply = Chat(text: response, isME: false,isimage: true);
      setState(() {
        chats.insert(0, reply);

      });
    }

    setState(() {
      isGenerating = false;
    });

  }


  Future<String> sendtoDistil(String input) async {
    final apiUrl = Uri.parse("https://api-inference.huggingface.co/models/j-hartmann/emotion-english-distilroberta-base");
    final headers = {"Authorization": "Bearer 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", "Content-Type": "application/json"};

    final payload = {"inputs": input};
    final response = await http.post(apiUrl, headers: headers, body: json.encode(payload));
    final List<dynamic> parsedResponse = jsonDecode(response.body);

    String reply = parsedResponse[0].toString();

    print("========distill roberta==========$parsedResponse");

    return reply;
  }

  Future<String> sendtoFinbert_Tone(String input) async {
    final apiUrl = Uri.parse("https://api-inference.huggingface.co/models/yiyanghkust/finbert-tone");
    final headers = {"Authorization": "Bearer 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", "Content-Type": "application/json"};

    final payload = {"inputs": input};
    final response = await http.post(apiUrl, headers: headers, body: json.encode(payload));
    final List<dynamic> parsedResponse = jsonDecode(response.body);

    String reply = parsedResponse[0].toString();

    print("========finetone==========$parsedResponse");

    return reply;
  }

  Future<String> sendtoGPT(String message) async{
    Uri url = Uri.parse("https://api.openai.com/v1/chat/completions");

    List<Map<String, dynamic>> jsonList = chats.map((chat) {
      return {
        "role": chat.isimage ? "system" :  chat.isME ? "user" : "assistant",
        "content": chat.isimage ? 'For above message dalle API was used to generate an image' : chat.text,
        // Add any other properties you want to include in the JSON object
      };
    }).toList().reversed.toList();

    print("=================$jsonList");


    Map<String,dynamic> body = {
      "model": "gpt-3.5-turbo",
      "messages": jsonList,
     // "messages": [{"role": "user", "content": message}],
      "max_tokens":300,
    };



    final response = await http.post(url,
        body: jsonEncode(body),
        headers: {
          "Content-Type":"application/json",
          "Authorization":"Bearer ${APIKEY.API}"
        }
    );


   // print('==============res=${response.body}');

    final Map<String,dynamic> parsedResponse = jsonDecode(response.body);

    String reply = parsedResponse['choices'][0]['message']['content'];

    return reply;
  }



  Future<String> sendtoSummary(String input) async {
    final apiUrl = Uri.parse("https://api-inference.huggingface.co/models/sshleifer/distilbart-cnn-12-6");
    final headers = {"Authorization": "Bearer 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", "Content-Type": "application/json"};

    final payload = {"inputs": input};
    final response = await http.post(apiUrl, headers: headers, body: json.encode(payload));
    final List<dynamic> parsedResponse = jsonDecode(response.body);

    String reply = parsedResponse[0]['summary_text'].toString();

    print("========finetone==========$parsedResponse");

    return reply;
  }

  Future<String> sendtodalle(String message) async{
    Uri url = Uri.parse("https://api.openai.com/v1/images/generations");
    Map<String,dynamic> body = {
      "prompt": message,
      "n": 1,
      "size": "512x512"
    };



    final response = await http.post(url,
        body: jsonEncode(body),
        headers: {
          "Content-Type":"application/json",
          "Authorization":"Bearer ${APIKEY.API}"
        }
    );

    final Map<String,dynamic> parsedResponse = jsonDecode(response.body);

    print(parsedResponse);
    String reply = parsedResponse['data'][0]['url'];


    return reply;
  }


  Future<String> sendtoCompVis(String input) async {
    final apiUrl = Uri.parse("https://api-inference.huggingface.co/models/CompVis/stable-diffusion-v1-4");
    final headers = {
      "Authorization": "Bearer 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",
      "Content-Type": "application/json",
    };

    final payload = {"inputs": input};
    final response = await http.post(apiUrl, headers: headers, body: json.encode(payload));
    final imageBytes = response.bodyBytes;

    if (response.statusCode == 200) {
      return imageBytes.toString();
    } else {
      throw Exception("Failed to query API. ${response.body}");
    }
  }

  //API_URL = "https://api-inference.huggingface.co/models/nitrosocke/Nitro-Diffusion"


  Future<String> sendtoOpenJourney(String input) async {
    final apiUrl = Uri.parse("https://api-inference.huggingface.co/models/prompthero/openjourney-v4");
    final headers = {
      "Authorization": "Bearer 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",
      "Content-Type": "application/json",
    };

    final payload = {"inputs": input};
    final response = await http.post(apiUrl, headers: headers, body: json.encode(payload));
    final imageBytes = response.bodyBytes;

    if (response.statusCode == 200) {
      return imageBytes.toString();
    } else {
      throw Exception("Failed to query API. ${response.body}");
    }
  }







  bool isimage = false;
  bool istalking = true;
  bool speechEnabled = false;
  bool isrecording = false;
  bool isSpeaking = false;
  bool isGenerating = false;
  String lastWords = '';


  @override
  void initState() {
    _initSpeech();
    _initTTS();
    super.initState();
  }

  @override
  void dispose() {
    flutterTTs.stop();
    super.dispose();
  }

  void _initTTS() async {

    flutterTTs.setStartHandler(() {
      setState(() {
        isSpeaking = true;
      });
    });
    flutterTTs.setCompletionHandler(() {
      isSpeaking = false;

    });
    flutterTTs.setErrorHandler((message) {
      setState(() {
        isSpeaking = false;
      });
    });

  }

  void _initSpeech() async {
    speechEnabled = await speechToText.initialize();
    setState(() {
      speechEnabled = speechEnabled;
    });
  }

  /// Each time to start a speech recognition session
  void _startListening() async {
    setState(() {
      isrecording = true;
    });
    await speechToText.listen(onResult: onSpeechResult);

  }


  void _stopListening() async {
    if(_text.text.isEmpty){
      Fluttertoast.showToast(
          msg: "Please try again",
          fontSize: 18,
          toastLength: Toast.LENGTH_LONG,
          textColor: Colors.white70,
          backgroundColor: Colors.grey
      );
    }
    setState(() {
      isrecording = false;
    });
    await speechToText.stop();

  }


  void onSpeechResult(var result) {

    setState(() {
      lastWords = result.recognizedWords;
      _text.text = lastWords;
    });
    _startListening();
  }


  void speak() async{

    if(!chats[0].isME){

      if(chats[0].text.isNotEmpty){
        setState(() {
          istalking = false;
        });
        await flutterTTs.speak(chats[0].text);

      }
    }
  }

  void stop() async{

    if(_text.toString().isEmpty){
      const snackBar = SnackBar(
        content: Text('Could not process audio.Please try again'),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    await flutterTTs.stop();
  }


  void openChatOptions(){
    Navigator.push(
      context,
      PageTransition(
          type: PageTransitionType.fade,
          alignment: Alignment.lerp(Alignment.centerLeft, Alignment.centerLeft, 0.5),
          child: const Chat_Options()
      ),);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: Container(
        //  color: Color.fromRGBO(120, 255,225, 100.0),
        //color: Colors.red.shade600,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [

                Colors.deepOrangeAccent,
                Colors.orange,
              ],
            ),
          ),
          height:  MediaQuery.of(context).size.height *  0.07,

          child:  Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              AvatarGlow(
                endRadius: isrecording ? 22 : 22,
                animate: true,
                glowColor: isrecording ? Colors.redAccent : Colors.black,
                child: GestureDetector(
                  onTap:() async{
                    if(!isrecording){
                      _startListening();
                    }
                    else{
                      _stopListening();
                    }
                  },
                  child: CircleAvatar(
                    backgroundColor: isrecording ? Colors.transparent : Colors.grey.shade800,
                    radius: 20,
                    child:
                    Icon( isrecording ? Icons.stop : Icons.mic,
                      color: isrecording ? Colors.redAccent : Colors.white,
                    ),
                  ),
                ),
              ),

              AvatarGlow(
                endRadius: istalking ? 22 : 22,
                animate: !istalking,
                glowColor: istalking ? Colors.redAccent : Colors.black,
                child: GestureDetector(
                  onTap:() async{
                    setState(() {
                      istalking = !istalking;
                      flutterTTs.stop();
                    });
                  },
                  child: CircleAvatar(
                    backgroundColor:Colors.grey.shade800,
                    radius:20,
                    child:
                    Icon( istalking ? Icons.volume_mute : Icons.surround_sound,
                      color: istalking ? Colors.redAccent : Colors.white,
                    ),
                  ),
                ),
              ),


            ],
          )
      ),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(110),
        child: AppBar(

          title: ClipRRect(
            borderRadius: const BorderRadius.only(
                topRight: Radius.circular(5),
                topLeft: Radius.circular(5),
                bottomRight: Radius.circular(5),
                bottomLeft: Radius.circular(5)
            ),
            child: Text(
                'AI-Wiz',
                style: GoogleFonts.aboreto(
                    fontWeight: FontWeight.w700,
                    color: Colors.orangeAccent
                )
            ),
          ),
          automaticallyImplyLeading: true,
          //backgroundColor: Color.fromRGBO(120, 255,225, 100.0),
          backgroundColor: Colors.black,
          actions: [

            Padding(
              padding: const EdgeInsets.only(
                  left: 8,
                  right: 8,
                  bottom: 15
              ),
              child: Container(
                decoration: BoxDecoration(
                    color:  Colors.transparent,
                    borderRadius: BorderRadius.circular(5)
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 8,right: 0,
                  ),
                  child: Row(
                    children: const [
                      CircleAvatar(
                        backgroundColor: Colors.orangeAccent,
                        child: Icon(Icons.person,

                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),


          ],

          flexibleSpace: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [




              Row(
                mainAxisAlignment: MainAxisAlignment.end,

                children: [

                  Padding(
                    padding: const EdgeInsets.only(top: 0,right: 75),
                    child: GestureDetector(
                      onTap: openChatOptions,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Colors.orangeAccent,
                              Colors.deepOrangeAccent
                            ]
                          ),
                          borderRadius: BorderRadius.circular(6)
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text(
                                'Chat Options',
                                style: GoogleFonts.nunito(
                                    color: Colors.black,
                                  fontWeight: FontWeight.w600
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),



                  // Padding(
                  //   padding: const EdgeInsets.only(
                  //       left: 8,
                  //       right: 8,
                  //       bottom: 15
                  //   ),
                  //   child: Container(
                  //     decoration: BoxDecoration(
                  //         color: Colors.white,
                  //         borderRadius: BorderRadius.circular(5)
                  //     ),
                  //     child: Padding(
                  //       padding: const EdgeInsets.only(right: 8,left: 8,
                  //       ),
                  //       child: Text('View Chat Options',
                  //
                  //         style: GoogleFonts.montserrat(
                  //           fontSize: 15,
                  //           color: Colors.black,
                  //           fontWeight: FontWeight.w300,
                  //
                  //         ),),
                  //     ),
                  //   ),
                  // ),





                  Padding(
                    padding: const EdgeInsets.only(left: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            CircleAvatar(
                              radius: 17,
                              backgroundColor: Colors.green,
                              child: Image.asset('lib/assets/chatgpt.png'),
                            ),
                            Text('ChatGPT',style: GoogleFonts.nunito(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.w700
                            ),),
                          ],
                        ),


                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Switch(
                              value: isimage,
                              activeColor: Colors.orangeAccent,
                              onChanged: (value){
                                setState(() {
                                  isimage = value;
                                });
                              }),
                        ),

                        Column(
                          children: [
                            CircleAvatar(
                              radius: 17,
                              backgroundColor: Colors.black,
                              child: Image.asset('lib/assets/chatgpt.png'),
                            ),
                            Text('Dalle',style: GoogleFonts.nunito(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.w700
                            ),
                            ),
                          ],
                        ),

                      ],
                    ),
                  ),




                  const SizedBox(
                    width: 10.0,
                  )


                ],
              )
            ],
          ),

        ),
      ),


      body: Stack(
        children: [

          // Container(
          //   decoration: BoxDecoration(
          //     image: DecorationImage(
          //       image: AssetImage("lib/assets/bg.png"), // <-- BACKGROUND IMAGE
          //       fit: BoxFit.cover,
          //     ),
          //   ),
          // ),
          Column(
            children: [
              Expanded(
                  child: ListView.builder(
                    reverse: true,
                    itemCount: chats.length,
                    itemBuilder: (BuildContext context, int index){
                      return _buildChat(chats[index]);
                    },
                  ) ),



              Container(
                decoration: const BoxDecoration(
                  //color: Color.fromRGBO(120, 255,225, 100.0),

                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(15),
                    topLeft: Radius.circular(15),
                  ),
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepOrangeAccent,
                      Colors.orange,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(

                      child:  Padding(
                        padding: const EdgeInsets.only(top: 8,left: 8,bottom: 8),
                        child: Container(

                          decoration: BoxDecoration(
                            //color: Color.fromRGBO(100, 205, 180, 10.0),
                            //color: Colors.red.shade400,
                            gradient: LinearGradient(
                              colors: [
                                Colors.orange.shade200,
                                //Colors.deepOrangeAccent.shade200,
                                Colors.orange.shade200,
                              ],
                            ),
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(12),
                              topLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                              bottomLeft: Radius.circular(12),),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4,bottom: 4,left: 10),
                            child: TextField(
                              controller: _text,
                              style: GoogleFonts.nunito(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold
                              ),
                              decoration: InputDecoration(
                                  hintText: 'Send a message...',
                                  border: InputBorder.none,
                                  hintStyle: GoogleFonts.nunito(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold
                                  )
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    Container(
                      decoration: const BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(0),
                            topRight: Radius.circular(4),
                            bottomRight: Radius.circular(4),
                          )
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 4,right: 8
                        ),
                        child: !isGenerating ?  GestureDetector(
                          onTap: onSendChat,
                          child: Image.asset('lib/assets/send.png',
                            height:35,
                            width: 35,),
                        ) : Padding(
                          padding: const EdgeInsets.only(left: 5,right: 5),
                          child: SizedBox(
                            height: 30,
                            width: 35,
                            child: LoadingIndicator(
                              indicatorType: Indicator.lineScale,
                              colors: [
                                Colors.grey.shade800
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ],
      ),

    );
  }


  Widget _buildChat(Chat chat){
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 7),

      child: Padding(
        padding: const EdgeInsets.only(bottom: 5,left: 10,right: 10),
        child: SizedBox(
          width: chat.text.length * MediaQuery.of(context).size.width * 0.1,

          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: chat.isME ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  child: !chat.isimage ?  Column(
                    children: [

                      chat.isME ?  Column(
                        children: [
                          chat.isME ? Text(
                            'You',
                            style: GoogleFonts.nunito(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,

                            ),

                          ) : Padding(
                            padding: const EdgeInsets.only(right: 200),
                            child: CircleAvatar(
                              radius: 17,
                              backgroundColor: Colors.green,
                              child: Image.asset('lib/assets/chatgpt.png'),
                            ),
                          ),

                          Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.7,
                            ),
                            decoration: BoxDecoration(
                              //color:  Color.fromRGBO(100, 180, 255, 100.0),
                              color: Colors.orangeAccent.shade200,
                              borderRadius: BorderRadius.circular(5),

                            ),
                            child: Padding(
                              padding:  const EdgeInsets.all(8.0),
                              child:

                              Text(
                                chat.text,
                                style: GoogleFonts.nunito(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14
                                ),
                              ),
                            ),
                          )
                        ],
                      ) : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 200),
                            child: CircleAvatar(
                              radius: 17,
                              backgroundColor: Colors.green,
                              child: Image.asset('lib/assets/chatgpt.png'),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.only(left: 30,top: 2),
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.7,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orangeAccent.shade200,
                                borderRadius: BorderRadius.circular(5),

                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child:
                                (chat.text == chats[0].text)  ? AnimatedTextKit(
                                  animatedTexts: [
                                    TypewriterAnimatedText(
                                      chat.text,
                                      textStyle: GoogleFonts.nunito(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15
                                      ),
                                      speed: const Duration(milliseconds: 50),
                                    ),
                                  ],

                                  totalRepeatCount: 1,
                                  pause: const Duration(milliseconds: 50),
                                  displayFullTextOnTap: true,
                                  stopPauseOnTap: true,
                                ) :
                                Text(
                                  chat.text,
                                  style: GoogleFonts.nunito(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600
                                  ),
                                ),
                              ),
                            ),
                          )

                        ],
                      ),
                    ],
                  ) : Container(

                    child: Column(

                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 300),
                          child: CircleAvatar(
                            radius: 17,

                            backgroundColor: Colors.black,
                            child: Image.asset('lib/assets/chatgpt.png'),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Container(
                            height: 280,
                            width: 280,
                            decoration: BoxDecoration(
                              //color:   Color.fromRGBO(180, 100, 255, 100.0),
                                color: Colors.orangeAccent.shade200,
                                borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(5),
                                    topRight: Radius.circular(5),
                                    bottomLeft: Radius.circular(5),
                                    bottomRight: Radius.circular(5)
                                )
                            ),

                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [

                               Container(
                                 child:  Image.network(chat.text,
                                 height: 270,
                                 width: 270,),
                               )

                                // Image.network(chat.text,
                                //   height: 270,
                                //   width: 270,),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}


///This is Image Byte
//    Image.memory(Uint8List.fromList(chat.text.replaceAll('[', '').replaceAll(']', '').split(', ').map(int.parse).toList())



