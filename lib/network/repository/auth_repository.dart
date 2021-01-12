import 'dart:convert';

import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:http/http.dart' as http;
import 'package:mylamp_flutter_v4_stable/network/model/response/negative_response.dart';
import 'package:mylamp_flutter_v4_stable/network/model/response/signin_response.dart';
import 'package:mylamp_flutter_v4_stable/network/model/response/signup_response.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_strings.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_variables.dart';
import 'package:mylamp_flutter_v4_stable/utils/tools.dart';

abstract class AuthRepository {
  Future<SignUpResponse> processSignUp(Map<String, String> request);

  Future<SignInResponse> processSignIn(Map<String, String> request);
}

class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<SignUpResponse> processSignUp(Map<String, String> request) async {
    var uri = Uri.http(FlavorConfig.instance.variables[MyVariables.baseUrl],
        FlavorConfig.instance.variables[MyVariables.signUp]);
    var response = await http.post(uri, body: request);

    if (response.statusCode == 201) {
      if (response.body != null) {
        try {
          var data = json.decode(response.body);
          SignUpResponse results = SignUpResponse.fromJson(data);
          Tools.stackTracer(StackTrace.current, "Sukses", response.statusCode);
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
      var data = json.decode(response.body);
      NegativeResponse results = NegativeResponse.fromJson(data);
      throw Exception(results.message);
    }
  }

  @override
  Future<SignInResponse> processSignIn(Map<String, String> request) async {
    var uri = Uri.http(FlavorConfig.instance.variables[MyVariables.baseUrl],
        FlavorConfig.instance.variables[MyVariables.signIn]);

    var response = await http.post(uri, body: request);
    if (response.statusCode == 200) {
      if (response.body != null) {
        try {
          var data = json.decode(response.body);
          SignInResponse results = SignInResponse.fromJson(data);
          Tools.stackTracer(StackTrace.current, "Sukses", response.statusCode);
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
      var data = json.decode(response.body);
      NegativeResponse results = NegativeResponse.fromJson(data);
      throw Exception(results.message);
    }
  }
}
