import 'dart:convert';

import 'package:http/http.dart' as http;

const String CLOUDANTURL =
    "[Input CLOUDANT API URL HERE]";

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
