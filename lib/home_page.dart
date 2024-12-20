import 'package:currency_converter/feature_box.dart';
import 'package:currency_converter/pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'open_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final OpenAIService openAIService = OpenAIService();
  late stt.SpeechToText speechToText;
  final FlutterTts flutterTts = FlutterTts();
  String lastWords = "";
  String? generatedContent;
  String? generatedImageUrl;

  @override
  void initState() {
    super.initState();
    initSpeechToText();
    initTextToSpeech();
  }

  void initSpeechToText() {
    speechToText = stt.SpeechToText();
  }

  void initTextToSpeech() {
    flutterTts.setLanguage('en-US');
    flutterTts.setPitch(1.0);
  }

  Future<void> startListening() async {
    bool available = await speechToText.initialize();
    if (available) {
      speechToText.listen(onResult: (result) {
        setState(() {
          lastWords = result.recognizedWords;
        });
      });
    } else {
      print("Speech recognition not available");
    }
  }

  Future<void> stopListening() async {
    await speechToText.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Allen'),

        leading: const Icon(Icons.menu), // Keeps the menu icon on the left
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Virtual Assistant Avatar
          Stack(
            children: [
              Center(
                child: Container(
                  height: 120,
                  width: 120,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: const BoxDecoration(
                    color: Pallete.assistantCircleColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Center(
                child: Container(
                  height: 135,
                  width: 135,
                  margin: const EdgeInsets.only(top: 4),
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    child: Image.asset('assets/virtualAssistant.png'),
                  ),
                ),
              ),
            ],
          ),

          // Greeting Message
          Visibility(
            visible: generatedImageUrl == null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
              margin:
                  const EdgeInsets.symmetric(horizontal: 40).copyWith(top: 30),
              decoration: BoxDecoration(
                border: Border.all(color: Pallete.borderColor),
                borderRadius:
                    BorderRadius.circular(20).copyWith(topLeft: Radius.zero),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  generatedContent == null
                      ? 'Good Morning, How can I help you?'
                      : generatedContent!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'cera pro',
                    color: Pallete.mainFontColor,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),

          // Display Generated Image
          if (generatedImageUrl != null)
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadiusDirectional.circular(20),
                    child: Image.network(
                      generatedImageUrl!,
                      height: 200,
                      width: 200,
                    ),
                  ),
                ),
              ),
            ),

          // Features Section Header
          Visibility(
            visible: generatedContent == null && generatedImageUrl == null,
            child: Container(
              padding: const EdgeInsets.all(10),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Here are a few features:',
                  style: TextStyle(
                    fontFamily: 'cera pro',
                    color: Pallete.mainFontColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // Features List
          Visibility(
            visible: generatedContent == null && generatedImageUrl == null,
            child: const Center(
              child: Column(
                children: [
                  FeatureBox(
                    color: Color.fromARGB(255, 12, 201, 239),
                    headerText: 'ChatGPT',
                    descriptionText:
                        'A smarter way to stay organized and informed with CHATGPT.',
                  ),
                  FeatureBox(
                    color: Color.fromARGB(255, 27, 12, 239),
                    headerText: 'Dall-E',
                    descriptionText:
                        'Get inspired and stay creative with your personal assistant powered by Dall-E.',
                  ),
                  FeatureBox(
                    color: Color.fromARGB(255, 199, 196, 238),
                    headerText: 'Smart Voice Assistant',
                    descriptionText:
                        'Get the best of both worlds with a voice assistant powered by AI.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Pallete.firstSuggestionBoxColor,
        onPressed: () async {
          if (speechToText.isAvailable) {
            if (!speechToText.isListening) {
              await startListening();
            } else {
              await stopListening();
              String speech = await openAIService.isArtPromptAPI(lastWords);

              setState(() {
                if (speech.contains("http")) {
                  generatedImageUrl = speech;
                  generatedContent = null;
                } else {
                  generatedImageUrl = null;
                  generatedContent = speech;
                }
              });
            }
          } else {
            print("Speech-to-text is not available.");
          }
        },
        child: Icon(
          speechToText.isListening ? Icons.stop : Icons.mic,
        ),
      ),
    );
  }
}
