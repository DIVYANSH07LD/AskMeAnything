import 'dart:convert';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:ask_me_anything/commonWidgets/customText.dart';
import 'package:ask_me_anything/src/screen/home/service/network.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:text_to_speech/text_to_speech.dart';

class AIScreenView extends StatefulWidget {
  const AIScreenView({Key? key}) : super(key: key);

  @override
  State<AIScreenView> createState() => _AIScreenViewState();
}

class _AIScreenViewState extends State<AIScreenView> {
  final SpeechToText speechToText = SpeechToText();
  final TextToSpeech textToSpeech = TextToSpeech();
  final TextEditingController userQuestionController = TextEditingController();
  final NetworkService _networkService = NetworkService();

  String speech = "";
  String modeOpenAI = "chat";
  String imageAI = "";
  String answerAI = "";

  bool isListen = false;
  bool startSearching = false;
  bool speakRocket = true;

  void initialize() async {
    await speechToText.initialize();
    setState(() {});
  }

  startListening() async {
    FocusScope.of(context).unfocus();
    await speechToText.listen(onResult: speechResult);
    setState(() {
      isListen = true;
    });
  }

  void stopListening() async {
    await speechToText.stop();
    setState(() {
      isListen = false;
    });
  }

  Future<void> sendRequest(String userInput) async {
    print(userInput);
    stopListening();

    setState(() {
      isListen = false;
    });

   try{
     setState(() {
       startSearching = true;
     });
     await NetworkService()
         .sendRequestToOpenAI(userInput, modeOpenAI, 2000)
         .then((value) {
       if (value.statusCode == 401) {
         throw "Something went wrong, API KEY is expired";
       }
       userQuestionController.clear();

       final response = jsonDecode(value.body);

       if (modeOpenAI == "chat") {
         setState(() {
           answerAI =
               utf8.decode(response['choices'][0]['text'].toString().codeUnits);
           print("REPLY==>$answerAI");
         });

         if(speakRocket == true)
           {
             textToSpeech.speak(answerAI);
           }
       } else {
         setState(() {
           imageAI = response['data'][0]["url"];
           print("REPLY==>$imageAI");
         });
       }
     }).catchError((e) {
       throw e;
     });
   }
       catch(e){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()))
        );
       }
       finally
           {
             setState(() {
               startSearching = false;
             });
           }
  }

  void speechResult(SpeechRecognitionResult speechRecognitionResult) {
    speech = speechRecognitionResult.recognizedWords;
    debugPrint("WORD: $speech");
    speechToText.isListening ? null : sendRequest(speech);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const CustomText(
          label: "AMA",
          fontSize: 20,
        ),
        actions: [
          InkWell(
              onTap: () {
                setState(() {
                  modeOpenAI = "chat";
                });
              },
              child: Icon(
                Icons.text_fields,
                color: modeOpenAI == "chat" ? Colors.yellow : Colors.white,
              )),
          const SizedBox(
            width: 20,
          ),
          InkWell(
              onTap: () {
                setState(() {
                  modeOpenAI = "image";
                });
              },
              child: Icon(
                Icons.image,
                color: modeOpenAI == "image" ? Colors.yellow : Colors.white,
              )),
          const SizedBox(
            width: 10,
          ),
        ],
      ),
      body: ListView(
        children: [
          const SizedBox(
            height: 20,
          ),
          Center(
            child: AnimatedTextKit(isRepeatingAnimation: true, animatedTexts: [
              TypewriterAnimatedText('Ask Me Anything!',
                  textStyle: GoogleFonts.aboreto(
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold,
                  ),
                  speed: const Duration(milliseconds: 100),
                  curve: Curves.bounceInOut),
            ]),
          ),
          Stack(children: [
            isListen
                ? LottieBuilder.asset("assets/animation/live_wave.json")
                : const SizedBox(),
            InkWell(
                onTap: () {
                  speechToText.isNotListening
                      ? startListening()
                      : stopListening();
                },
                child: LottieBuilder.asset(
                  "assets/animation/robo.json",
                )),
          ]),
          Row(
            children: [
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: TextField(
                  controller: userQuestionController,
                  decoration: InputDecoration(
                      hintText: "ask me anything buddy",
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          width: 2,
                          color: Colors.indigo,
                        ),
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50.0),
                        borderSide: const BorderSide(
                          width: 2,
                          color: Colors.indigo,
                        ),
                      )),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              ElevatedButton(
                  onPressed: () {
                    if (userQuestionController.text.isNotEmpty) {
                      sendRequest(userQuestionController.text.toString());
                    }
                    FocusScope.of(context).unfocus();
                  },
                  child: const CustomText(
                    label: "Search",
                    fontSize: 12,
                  )),
              const SizedBox(
                width: 10,
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          //display result
          modeOpenAI == "chat"
              ? Container(
                  margin: const EdgeInsets.all(10.0),
                  padding: const EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(10),
                      ),
                      border: Border.all(color: Colors.indigo)),
                  child:startSearching == true?
                  LottieBuilder.asset("assets/animation/robo-loading.json"):
                  SelectableText(
                    answerAI,
                    style: GoogleFonts.aBeeZee(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.black),
                  ),
                )
              : modeOpenAI == "image" && imageAI.isNotEmpty
                  ? Container(
            margin: const EdgeInsets.all(10.0),
            padding: const EdgeInsets.all(5.0),
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(
                  Radius.circular(10),
                ),
                border: Border.all(color: Colors.indigo)),
            child:startSearching == true?
            LottieBuilder.asset("assets/animation/robo-loading.json"):
            Image.network(imageAI)
          )
                  : const SizedBox()
        ],
      ),
    );
  }
}
