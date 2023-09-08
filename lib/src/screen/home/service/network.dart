import 'dart:convert';

import 'package:ask_me_anything/api_const.dart';
import 'package:http/http.dart'as http;

class NetworkService{

  Future<http.Response> sendRequestToOpenAI( String userInput, String mode, int maxTokens)async{

    final String openAIApiUrl = mode == "chat"? "v1/completions":"v1/images/generations";

    final body = mode == "chat"? {
        "model": "text-davinci-003",
        "prompt":userInput,
        "max_tokens":2000,
        "temperature":0.9,
        "n":1
    }: {
        "prompt":userInput
    };

    final response = await http.post(Uri.parse(openApiUrl + openAIApiUrl),headers: {
      "Content-Type":"application/json",
      "Authorization":"Bearer $apiKey"
    },
    body: jsonEncode(body)
    );

    return response;
  }
}