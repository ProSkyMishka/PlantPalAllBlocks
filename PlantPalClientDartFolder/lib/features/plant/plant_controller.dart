import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/plant_model.dart';
import '../../shared/services/plant_service.dart';

enum PlantStatus { loading, data, error }

class PlantState {
  final PlantStatus status;
  final Plant? plant;
  final String? message;

  PlantState({required this.status, this.plant, this.message});
}

class PlantController extends StateNotifier<PlantState> {
  final String plantId;
  final _svc = PlantService();

  PlantController(this.plantId) : super(PlantState(status: PlantStatus.loading)) {
    _load();
  }

  Future<void> _load() async {
    try {
      final p = await _svc.fetchById(plantId);
      state = PlantState(status: PlantStatus.data, plant: p);
    } catch (e) {
      state = PlantState(status: PlantStatus.error, message: 'Ошибка при загрузке');
    }
  }

  // Future<void> water() async {
  //   await _svc.water(plantId);
  // }

  // Future<void> update(Plant p) async {
  //   await _svc.update(p);
  //   state = PlantState(status: PlantStatus.data, plant: p);
  // }
}

final plantControllerProvider =
StateNotifierProvider.family<PlantController, PlantState, String>(
      (ref, id) => PlantController(id),
);
