

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:chatgpt_akr/main.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final TextEditingController promptController;
  String responseTxt = '';
  // late ResponseModel _responseModel;
  // late ResponseModel _responseModel;
  late  ResponseModel  _responseModel;
  @override
  void initState() {
    promptController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff343541),
      appBar: AppBar(
        title: Text(
          "sfh",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          PromptBldr(responseTxt: responseTxt),
          TextFormFieldBldr(
              promptController: promptController, btnFun: completionFun)
        ],
      ),
    );
  }

  completionFun() async {
    setState(() => responseTxt = ' Loading...');
    final http.Response response = await http.post(
      Uri.parse('https://api.openai.com/v1/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${dotenv.env['token']}'
      },
      body: jsonEncode({
        "model": "text-davinci-003",
        "prompt": promptController.text,
        "max_tokens": 250,
        "top_p": 1,
      }),
    );
    setState(() {
      _responseModel = ResponseModel.fromJson(response.body);
      responseTxt = _responseModel.choices[0]['text'];
      debugPrint(responseTxt);
    });
  }
}

class ResponseModel {
 
  final List<Map<String, dynamic>> choices;

  ResponseModel({required this.choices});

  factory ResponseModel.fromJson(String jsonString) {
    final parsedJson = jsonDecode(jsonString);
    return ResponseModel(choices: List<Map<String, dynamic>>.from(parsedJson['choices']));
  
}

}

class PromptBldr extends StatelessWidget {
  const PromptBldr({
    super.key,
    required this.responseTxt,
  });
  final String responseTxt;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 1.35,
      color: const Color(0xff434654),
      child: Padding(
        padding:const  EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Text(
            responseTxt,
            textAlign: TextAlign.start,
            style: const TextStyle(fontSize: 25, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class TextFormFieldBldr extends StatelessWidget {
  const TextFormFieldBldr(
      {super.key, required this.promptController, required this.btnFun});

  final TextEditingController promptController;
  final Function btnFun;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, bottom: 50),
        child: Row(
          children: [
            Flexible(
              child: TextFormField(
                cursorColor: Colors.white,
                controller: promptController,
                autofocus: true,
                style: TextStyle(color: Colors.white, fontSize: 20),
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xff444653),
                    ),
                    borderRadius: BorderRadius.circular(5.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xff444653),
                    ),
                  ),
                  filled: true,
                  fillColor: Color(0xff444653),
                  hintText: "Ask me anything",
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
            Container(
              color: Color(0xff19bc99),
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: IconButton(
                  onPressed: () => btnFun(),
                  icon: Icon(
                    Icons.send,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
