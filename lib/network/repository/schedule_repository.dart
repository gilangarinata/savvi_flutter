import 'dart:convert';

import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:http/http.dart' as http;
import 'package:mylamp_flutter_v4_stable/network/model/response/negative_response.dart';
import 'package:mylamp_flutter_v4_stable/network/model/response/schedule_response.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_strings.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_variables.dart';
import 'package:mylamp_flutter_v4_stable/utils/tools.dart';

abstract class ScheduleRepository {
  Future<List<Result>> getSchedule(String userId,String hardwareId);
  Future<bool> addSchedule(Map<String,String> req);
  Future<bool> editSchedule(Map<String,String> req, String id);
  Future<bool> deleteSchedule(String id);
}

class ScheduleRepositoryImpl implements ScheduleRepository {
  @override
  Future<List<Result>> getSchedule(String userId,String hardwareId) async {
    var uri = Uri.http(FlavorConfig.instance.variables[MyVariables.baseUrl],
        FlavorConfig.instance.variables[MyVariables.schedule] + "/get_by_device/$hardwareId");
    var response = await http.get(uri);
   Tools.stackTracer(StackTrace.current, uri.toString(), response.statusCode);
    if (response.statusCode == 200) {
      if (response.body != null) {
        try {
          var data = json.decode(response.body);
          List<Result> results = ScheduleResponse.fromJson(data).result;
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
  Future<bool> addSchedule(Map<String,String> req) async {
    var uri = Uri.http(FlavorConfig.instance.variables[MyVariables.baseUrl],
        FlavorConfig.instance.variables[MyVariables.schedule] );
    Tools.stackTracer(StackTrace.current, req.toString(), 1);
    var response = await http.post(uri, body: req);
    Tools.stackTracer(StackTrace.current, response.body, response.statusCode);
    if (response.statusCode == 200) {
      if (response.body.contains("Created")) {
       return true;
      }else {
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
  Future<bool> editSchedule(Map<String,String> req, String id) async {
    var uri = Uri.http(FlavorConfig.instance.variables[MyVariables.baseUrl],
        FlavorConfig.instance.variables[MyVariables.schedule] + "/edit/$id");
    // Tools.stackTracer(StackTrace.current, "EDIT SCHEDULE $req", 0);
    // Tools.stackTracer(StackTrace.current, "EDIT SCHEDULE $uri", 0);
    var response = await http.post(uri, body: req);
    if (response.statusCode == 200) {
      if (response.body.contains("Updated")) {
        return true;
      }else {
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
  Future<bool> deleteSchedule(String id) async {
    var uri = Uri.http(FlavorConfig.instance.variables[MyVariables.baseUrl],
        FlavorConfig.instance.variables[MyVariables.schedule] + "/deletes/$id");
    var response = await http.get(uri);
    if (response.statusCode == 200) {
      if (response.body.contains("deleted")) {
        return true;
      }else {
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

}
