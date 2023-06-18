import 'dart:convert';

import 'package:http/http.dart' as http;

const String CLOUDANTURL =
    "apikey-v2-mfkw1afzpihs2nomgqhygxhpe9g52q7q9bivhypz72e:119b14f59b6f3d8444a6a5f1e1252702@b7f9a4e1-cf29-4f15-a99c-423e2227a84e-bluemix.cloudantnosqldb.appdomain.cloud";

Future<Map> requestPOSTOnURL(String page, String body) async {
  var url = Uri.https(CLOUDANTURL, "/$page");

  var response = await http.post(url,
      headers: {'Content-type': 'application/json'}, body: body);
  var jsonResponse = jsonDecode(response.body) as Map;
  return jsonResponse;
}

Future<Map> requestDeleteOnURL(
    String page, Map<String, dynamic> queryParameters) async {
  var url = Uri.https(CLOUDANTURL, "/$page", queryParameters);

  var response =
      await http.delete(url, headers: {'Content-type': 'application/json'});
  var jsonResponse = jsonDecode(response.body) as Map;
  return jsonResponse;
}
