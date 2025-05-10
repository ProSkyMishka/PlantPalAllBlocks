import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:plant_pal_app/features/auth/auth_controller.dart';
import 'package:plant_pal_app/shared/services/auth_service.dart';
import 'package:uuid/uuid.dart';
import '../models/plant_model.dart';
import 'local_storage.dart';

class PlantService {
  static const String baseUrl = 'http://158.160.131.34:8080/plants'; // URL сервера

  final auth = AuthService();
  final _storage = LocalStorage();

  String jwtToken = "";

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $jwtToken',
  };

  Future<Plant> fetchByMlid(String mlid) async {
    final response = await http.get(Uri.parse('$baseUrl/ml/$mlid'));
    if (response.statusCode == 200) {
      return Plant.fromJson(json.decode(response.body));
    } else {
      throw Exception('Растение по MLID не найдено');
    }
  }

  Future<Plant?> fetchById(String id) async {
    final curr = await auth.getCurrent();
    if (curr == null) return null;
    jwtToken = curr.token;
    final response = await http.get(Uri.parse('$baseUrl/$id'), headers: _headers);
    if (response.statusCode == 200) {
      return Plant.fromJson(json.decode(response.body));
    } else {
      throw Exception('Растение по MLID не найдено');
    }
  }

  Future<Plant?> createPlantWithUseredTrue(Plant originalPlant) async {
    final curr = await auth.getCurrent();
    if (curr == null) return null;
    jwtToken = curr.token;
    final newPlant = originalPlant.copyWith(usered: true);

    final response = await http.post(
      Uri.parse('$baseUrl/create'),
      headers: _headers,
      body: json.encode(newPlant.toJson()),
    );

    if (response.statusCode == 200) {
      final plant = Plant.fromJson(json.decode(response.body));
      await auth.addFlowerToUser(plant.id);
      return plant;
    } else {
      throw Exception('Ошибка при создании растения');
    }
  }

  Future<List<Plant>?> fetchAllUserPlants() async {
    final curr = await auth.getCurrent();
    if (curr == null) return null;
    jwtToken = curr.token;
    List<Plant> result = [];

    print(curr.flowers);
    for (String id in curr.flowers) {
      print(id);
      Plant? plant = await fetchById(id);
      if (plant == null) continue;
      result.add(plant);
    }
    print(result);
    return result;
  }

  Future<void> processDetectedPlant(String mlid) async {
    final originalPlant = await fetchByMlid(mlid);

    await createPlantWithUseredTrue(originalPlant);
  }
}
