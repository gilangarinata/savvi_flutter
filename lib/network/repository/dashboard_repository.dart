import 'dart:convert';

import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:http/http.dart' as http;
import 'package:mylamp_flutter_v4_stable/network/model/response/add_device.dart';
import 'package:mylamp_flutter_v4_stable/network/model/response/device_response.dart';
import 'package:mylamp_flutter_v4_stable/network/model/response/negative_response.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_strings.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_variables.dart';
import 'package:mylamp_flutter_v4_stable/utils/tools.dart';

abstract class DashboardRepository {
  Future<List<Result>> fetchDevice(String userId,String token);
  Future<AddDeviceResponse> addDevice(Map<String, String> request, String token);
  Future<bool> updateLamp(Map<String, String> request, String token);
  Future<bool> deleteDevice(String deviceId, String token);
}

class DashboardRepositoryImpl implements DashboardRepository {
  @override
  Future<List<Result>> fetchDevice(String userId, String token) async {
    var uri = Uri.http(FlavorConfig.instance.variables[MyVariables.baseUrl],
        FlavorConfig.instance.variables[MyVariables.device] + "/$userId");
    Map<String,String> userHeader = {"Authorization" : "Bearer $token"};
    var response = await http.get(uri, headers: userHeader);

    if (response.statusCode == 200) {
      if (response.body != null) {
        try {
          var data = json.decode(response.body);
          List<Result> results = DeviceResponse.fromJson(data).result;
          Tools.stackTracer(StackTrace.current, results.toString(), response.statusCode);
          return results;
        } catch (e) {
          Tools.stackTracer(StackTrace.current, response.body, 500);
          throw Exception(MyStrings.parseFailed);
        }
      } else {
        Tools.stackTracer(StackTrace.current, "Error", 501);
        throw Exception(MyStrings.noData);
      }
    } else {
      Tools.stackTracer(StackTrace.current, response.body, response.statusCode);
      if(response.body.contains("reason")){
        throw Exception(MyStrings.serverFailed);
      }else{
        Tools.stackTracer(StackTrace.current, response.body, response.statusCode);
        var data = json.decode(response.body);
        NegativeResponse results = NegativeResponse.fromJson(data);
        throw Exception(results.message);

      }
    }
  }

  @override
  Future<AddDeviceResponse> addDevice(Map<String, String> request, String token) async{
    var uri = Uri.http(FlavorConfig.instance.variables[MyVariables.baseUrl],
        FlavorConfig.instance.variables[MyVariables.device]);
    Map<String,String> userHeader = {"Authorization" : "Bearer $token"};
    var response = await http.post(uri, headers: userHeader, body: request);
    if (response.statusCode == 201) {
      if (response.body != null) {
        try {
          var data = json.decode(response.body);
          AddDeviceResponse results = AddDeviceResponse.fromJson(data);
          Tools.stackTracer(StackTrace.current, results.toString(), response.statusCode);
          return results;
        } catch (e) {
          Tools.stackTracer(StackTrace.current, e.toString(), 500);
          throw Exception(MyStrings.parseFailed);
        }
      } else {
        Tools.stackTracer(StackTrace.current, "Error", 501);
        throw Exception(MyStrings.noData);
      }
    } else {
      Tools.stackTracer(StackTrace.current, response.body, response.statusCode);
      if(response.body.contains("reason")){
        throw Exception(MyStrings.serverFailed);
      }else if(response.body.contains("unique")){
        throw Exception(MyStrings.hardwareUsed);
      } else{
        Tools.stackTracer(StackTrace.current, response.body, response.statusCode);
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
  Future<bool> deleteDevice(String deviceId, String token) async{
    var uri = Uri.http(FlavorConfig.instance.variables[MyVariables.baseUrl],
        FlavorConfig.instance.variables[MyVariables.device] + "/$deviceId");

    Map<String,String> userHeader = {"Authorization" : "Bearer $token"};

    var response = await http.delete(uri, headers: userHeader);

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

}
