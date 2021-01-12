import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:http/http.dart' as http;
import 'package:mylamp_flutter_v4_stable/network/model/response/hardware_response.dart';
import 'package:mylamp_flutter_v4_stable/network/model/response/negative_response.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_strings.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_variables.dart';
import 'package:mylamp_flutter_v4_stable/utils/tools.dart';
import 'package:path/path.dart';
import 'package:async/async.dart' as asyncs;
import 'package:http_parser/http_parser.dart';

abstract class HardwareDetailRepository {
  Future<Result> fetchHardware(String id,String token);
  Future<bool> updateBrightness(String hardwareId,String brightness);
  Future<bool> updateLamp(Map<String, String> request, String token);
  Future<bool> uploadImage(String hardwareId, File images);
  Future<bool> deleteImage(String hardwareId);

}

class HardwareDetailRepositoryImpl implements HardwareDetailRepository {
  @override
  Future<Result> fetchHardware(String id, String token) async {
    var uri = Uri.http(FlavorConfig.instance.variables[MyVariables.baseUrl],
        FlavorConfig.instance.variables[MyVariables.hardware] + "/$id");
    Map<String,String> userHeader = {"Authorization" : "Bearer $token"};
    var response = await http.get(uri, headers: userHeader);
   // Tools.stackTracer(StackTrace.current, response.body, response.statusCode);
    if (response.statusCode == 200) {
      if (response.body != null) {
        try {
          var data = json.decode(response.body);
          Result results = HardwareResponse.fromJson(data).result;
          return results;
        } catch (e) {
          throw Exception(MyStrings.parseFailed);
        }
      } else {
        throw Exception(MyStrings.noData);
      }
    } else {
      if(response.body.contains("reason")){
        throw Exception(MyStrings.serverFailed);
      }else{
        var data = json.decode(response.body);
        NegativeResponse results = NegativeResponse.fromJson(data);
        throw Exception(results.message);

      }
    }
  }

  @override
  Future<bool> updateBrightness(String hardwareId,String brightness) async {
    var uri = Uri.http(FlavorConfig.instance.variables[MyVariables.baseUrl],
        FlavorConfig.instance.variables[MyVariables.updateBrightness]);
    Map<String,String> reqBody = {
      "hardwareId" : hardwareId,
      "brightness" : brightness
    };

    var response = await http.post(uri, body: reqBody);
   // Tools.stackTracer(StackTrace.current, response.body, response.statusCode);
    if (response.statusCode == 200) {
      if(response.body.contains("Updated")){
        return true;
      }else{
        return false;
      }
    } else {
      if(response.body.contains("reason")){
        throw Exception(MyStrings.serverFailed);
      }else{
        var data = json.decode(response.body);
        NegativeResponse results = NegativeResponse.fromJson(data);
        throw Exception(results.message);

      }
    }
  }

  @override
  Future<bool> updateLamp(Map<String, String> request, String token) async{
    var uri = Uri.http(FlavorConfig.instance.variables[MyVariables.baseUrl],
        FlavorConfig.instance.variables[MyVariables.updateLamp]);
    Map<String,String> userHeader = {"Authorization" : "Bearer $token"};
    var response = await http.post(uri, headers: userHeader, body: request);
    // Tools.stackTracer(StackTrace.current, response.toString(), response.statusCode);
    if (response.statusCode == 200) {
      return true;
    } else {
      if(response.body.contains("reason")){
        throw Exception(MyStrings.serverFailed);
      }else{
        var data = json.decode(response.body);
        NegativeResponse results = NegativeResponse.fromJson(data);
        throw Exception(results.message);
      }
    }
  }

  @override
  Future<bool> deleteImage(String hardwareId) async{
    var uri = Uri.http(FlavorConfig.instance.variables[MyVariables.baseUrl],
        FlavorConfig.instance.variables[MyVariables.device] + "/upload/$hardwareId");
    var response = await http.delete(uri);
    Tools.stackTracer(StackTrace.current, response.toString(), response.statusCode);
    if (response.statusCode == 200) {
      return true;
    } else {
      if(response.body.contains("reason")){
        throw Exception(MyStrings.serverFailed);
      }else{
        var data = json.decode(response.body);
        NegativeResponse results = NegativeResponse.fromJson(data);
        throw Exception(results.message);
      }
    }
  }

  @override
  Future<bool> uploadImage(String hardwareId, File images) async {
    var uri = Uri.http(FlavorConfig.instance.variables[MyVariables.baseUrl],
        FlavorConfig.instance.variables[MyVariables.device] + "/upload");
    print("DIO URL: "+ uri.origin + uri.path);
    Dio dio = new Dio();
    Response response;
    FormData formData = new FormData.fromMap({
      "hardwareId": hardwareId,
      "images": await MultipartFile.fromFile(images.path,filename: 'images.jpg', contentType: MediaType('image', 'jpg')),
    });
    response = await dio.post(uri.origin + uri.path, data: formData);
    if(response.statusCode == 200){
      return true;
    }else{
      throw Exception(MyStrings.serverFailed);
    }
  }
}
