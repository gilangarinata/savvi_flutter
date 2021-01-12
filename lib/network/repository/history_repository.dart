import 'dart:convert';

import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:http/http.dart' as http;
import 'package:mylamp_flutter_v4_stable/network/model/response/history_response.dart';
import 'package:mylamp_flutter_v4_stable/network/model/response/negative_response.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_strings.dart';
import 'package:mylamp_flutter_v4_stable/resource/my_variables.dart';
import 'package:mylamp_flutter_v4_stable/utils/tools.dart';

abstract class HistoryRepository {
  Future<List<History>> getHistory(String hardwareId);
}

class HistoryRepositoryImpl implements HistoryRepository {
  @override
  Future<List<History>> getHistory(String hardwareId) async {
    var uri = Uri.http(FlavorConfig.instance.variables[MyVariables.baseUrl],
        FlavorConfig.instance.variables[MyVariables.hardware] + "/history/$hardwareId");
    var response = await http.get(uri);
   Tools.stackTracer(StackTrace.current, response.body + hardwareId, response.statusCode);
    if (response.statusCode == 200) {
      if (response.body != null) {
        try {
          var data = json.decode(response.body);
          List<History> results = HistoryResponse.fromJson(data).history;
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

}
