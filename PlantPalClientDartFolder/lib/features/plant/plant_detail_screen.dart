import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/models/plant_model.dart';
import '../plant/plant_controller.dart';
import '../../shared/theme/design_tokens.dart';

class PlantDetailScreen extends ConsumerWidget {
  final String plantId;
  const PlantDetailScreen({required this.plantId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st = ref.watch(plantControllerProvider(plantId));
    final ctrl = ref.read(plantControllerProvider(plantId).notifier);
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF8BC183),
      body: Stack(
        children: [
          // Белый блок с информацией о растении
          Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: 2 / 3,
              widthFactor: 1,
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: st.status == PlantStatus.loading
                    ? const Center(child: CircularProgressIndicator())
                    : st.status == PlantStatus.error
                    ? Center(
                  child: Text(
                    st.message ?? '',
                    style: const TextStyle(color: Colors.red),
                  ),
                )
                    : _buildDetails(context, st.plant!, ctrl),
              ),
            ),
          ),

          // Кнопка назад
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: GestureDetector(
                onTap: () => context.pop(),
                child: const Icon(
                  Icons.arrow_back,
                  color: Color(0xFFCEDD4C),
                  size: 28,
                ),
              ),
            ),
          ),

          // Заголовок экрана
          Positioned(
            top: screenHeight / 3 - 60,
            left: 16,
            right: 16,
            child: const Text(
              'Растение',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetails(BuildContext context, Plant plant, PlantController ctrl) {
    final nameCtrl = TextEditingController(text: plant.name);

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Фото растения с иконкой полива
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: plant.imageUrl != Null
                    ? Image.memory(
                  base64Decode(plant.imageUrl ?? ""),
                  width: 260,
                  height: 200,
                  fit: BoxFit.cover,
                )
                    : Container(
                  width: 260,
                  height: 200,
                  color: Colors.grey.shade300,
                  child: const Icon(
                    Icons.image,
                    size: 48,
                    color: Colors.white70,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(12),
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: Color(0xFF4A99AC),
                  child: Icon(
                    Icons.water_drop,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Название растения
          const Text(
            'Название растения',
            style: TextStyle(
              color: Color(0xFF789B2F),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(plant.name, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 12),
          // Описание
          const Text(
            'Описание',
            style: TextStyle(
              color: Color(0xFF789B2F),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(plant.description),
          // Text(plant.description),
          const SizedBox(height: 12),
          const SizedBox(height: 8),
          // Следующий полив
          const Text(
            'Следующий полив',
            style: TextStyle(
              color: Color(0xFFBCD840),
              fontWeight: FontWeight.w600,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 24),
          const SizedBox(height: 24),
          // Кнопки "ПОЛИТЬ"
          Row(
            children: [
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: /*ctrl.water*/ () => {},
                  child: const Text('ПОЛИТЬ'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCounterBlock(
      String label,
      int value,
      void Function(int) onChanged,
      ) {
    return Column(
      children: [
        Text(
          '$value',
          style: const TextStyle(
            color: Color(0xFFBCD840),
            fontSize: 24,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            _counterButton(
              Icons.remove,
                  () => onChanged(value > 0 ? value - 1 : 0),
            ),
            const SizedBox(width: 8),
            _counterButton(
              Icons.add,
                  () => onChanged(value + 1),
            ),
          ],
        ),
      ],
    );
  }

  Widget _counterButton(IconData icon, VoidCallback onPressed) {
    return ClipOval(
      child: Material(
        color: Colors.grey.shade200,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox(
            width: 32,
            height: 32,
            child: Icon(
              icon,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }
}
