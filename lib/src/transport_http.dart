import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'transport.dart';
import 'dart:io';
import 'dart:convert' as convert;
import 'package:string_validator/string_validator.dart';

class TransportHTTP implements Transport{

  static final Duration timeout = Duration(seconds: 10);
  late String hostname;
  final Map<String, String> headers = new Map();
  final client = http.Client();

  TransportHTTP(String hostname) {
    if (!isURL(hostname)) {
      throw FormatException("hostname '$hostname' should be an URL.");
    }
    this.hostname = hostname;
    headers["Content-type"] =  "application/x-www-form-urlencoded";
    //header["Content-type"] =  "application/json";
    headers["Accept"] =  "text/plain";
  }

  @override
  Future<bool> connect() async {
    return true;
  }

  @override
  Future<void> disconnect() async {
    client.close();
  }
  void _updateCookie(http.Response response) {
    String? rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      int index = rawCookie.indexOf(';');
      headers['cookie'] =
      (index == -1) ? rawCookie : rawCookie.substring(0, index);
    }
  }

  @override
  Future<Uint8List> sendReceive(String epName, Uint8List data) async {
    try {
      print("Connecting to " + this.hostname + "/" + epName);
      final response = await client.post(Uri.http(this.hostname, "/" + epName,),headers: this.headers,
      body: data).timeout(timeout);

      if (response !=null) {
        _updateCookie(response);
        if (response.statusCode == 200) {
          print('Connection successful');
          //client.close();
          final Uint8List body_bytes = response.bodyBytes;
          return body_bytes;
        }
        else {
          print("Connection failed: status ${response.statusCode} body ${response.body}");
          throw Exception("ESP Device doesn't repond");
        }
      }
    }
    catch(e, s){
      print('Connection error:  ' + e.toString());
      print(s);
      throw StateError('Connection error ' + e.toString());
    }
    return Uint8List.fromList([]);
  }
}



