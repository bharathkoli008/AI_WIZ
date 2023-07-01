import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';


class Chat_Options extends StatefulWidget {
  const Chat_Options({Key? key}) : super(key: key);

  @override
  State<Chat_Options> createState() => _Chat_OptionsState();
}

class _Chat_OptionsState extends State<Chat_Options> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: PreferredSize(
        preferredSize: Size.fromHeight(110),
        child: AppBar(

          title: ClipRRect(
            borderRadius: BorderRadius.only(
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
          automaticallyImplyLeading: false,
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
                    children: [
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
                    padding: const EdgeInsets.only(top: 0,right: 80),
                    child: GestureDetector(
                      onTap: (){},
                      child: Container(
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
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
                                    fontWeight: FontWeight.w600,
                                  fontSize: 18
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  Row(
                    children: [
                      Text('Balance :',
                        style: GoogleFonts.nunito(
                            color: Colors.orangeAccent,
                            fontSize: 18,
                            fontWeight: FontWeight.w600
                        ),),



                      Padding(
                        padding: const EdgeInsets.only(left: 5,right: 8),
                        child: Container(
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  colors: [
                                    Colors.orangeAccent,
                                    Colors.deepOrangeAccent
                                  ]
                              ),
                              borderRadius: BorderRadius.circular(6)
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Row(
                              children: [
                                Text(
                                  '525',
                                  style: GoogleFonts.nunito(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800
                                  ),
                                ),

                                Image.asset('lib/assets/coi2.png',
                                height: 25,
                                width: 25,),
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),


                ],
              )
            ],
          ),

        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Balance :',
            style: GoogleFonts.nunito(
              color: Colors.orangeAccent,
              fontSize: 18,
              fontWeight: FontWeight.w600
            ),),
            Text('Token Size',
              style: GoogleFonts.nunito(
                  color: Colors.orangeAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.w600
              ),),
            Text('Select Model',
              style: GoogleFonts.nunito(
                  color: Colors.orangeAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.w600
              ),),

            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  colors: [
                    Colors.orangeAccent,
                    Colors.deepOrangeAccent
                  ]
                )
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  ' Share the App to get Free tokens ✨',
                  style: GoogleFonts.nunito(
                      color: Colors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.w600
                  ),
                )
              ),
            )
          ],
        ),
      ),
    );
  }
}
