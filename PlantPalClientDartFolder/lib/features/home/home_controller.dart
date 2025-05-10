import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/plant_model.dart';
import '../../shared/services/plant_service.dart';

enum HomeStatus { loading, data, error }

class HomeState {
  final HomeStatus status;
  final List<Plant> allPlants;
  final List<Plant> filtered;
  final String? message;

  HomeState({
    required this.status,
    this.allPlants = const [],
    this.filtered = const [],
    this.message,
  });

  HomeState copyWith({
    HomeStatus? status,
    List<Plant>? allPlants,
    List<Plant>? filtered,
    String? message,
  }) {
    return HomeState(
      status: status ?? this.status,
      allPlants: allPlants ?? this.allPlants,
      filtered: filtered ?? this.filtered,
      message: message ?? this.message,
    );
  }
}

class HomeController extends StateNotifier<HomeState> {
  final _svc = PlantService();

  HomeController() : super(HomeState(status: HomeStatus.loading)) {
    loadPlants();
  }

  Future<void> loadPlants() async {
    try {
      final list = await _svc.fetchAllUserPlants();
      state = state.copyWith(
        status: HomeStatus.data,
        allPlants: list,
        filtered: list,
      );
    } catch (e) {
      state = state.copyWith(
        status: HomeStatus.error,
        message: 'Не удалось загрузить растения',
      );
    }
  }

  /// Фильтрация по подстроке в имени
  void search(String query) {
    final low = query.toLowerCase();
    final filtered = state.allPlants
        .where((p) => p.name.toLowerCase().contains(low))
        .toList();
    state = state.copyWith(filtered: filtered);
  }
}

final homeControllerProvider =
StateNotifierProvider<HomeController, HomeState>((ref) {
  return HomeController();
});
