import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/models/plant_model.dart';
import '../plant/plant_controller.dart';

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
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: GestureDetector(
                onTap: () => context.pop('updated'),
                child: const Icon(
                  Icons.arrow_back,
                  color: Color(0xFFCEDD4C),
                  size: 28,
                ),
              ),
            ),
          ),
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
    DateTime selectedDate = DateTime.now();

    return StatefulBuilder(
      builder: (context, setState) {
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.topRight,
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: plant.imageUrl != null
                            ? Image.memory(
                          base64Decode(plant.imageUrl!),
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
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: GestureDetector(
                      onTap: () {
                        // TODO: реализовать поведение редактирования
                      },
                      child: const CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.white70,
                        child: Icon(
                          Icons.edit,
                          size: 22,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

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

              const Text(
                'Описание',
                style: TextStyle(
                  color: Color(0xFF789B2F),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(plant.description),
              const SizedBox(height: 12),

              const Text(
                'Следующий полив',
                style: TextStyle(
                  color: Color(0xFFBCD840),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8BC183),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 16.0,
                  ),
                ),
                icon: const Icon(Icons.calendar_today, color: Colors.white),
                label: const Text('Выбрать дату и время полива', style: TextStyle(fontSize: 16),),
                  onPressed: () async {
                    final now = DateTime.now();
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDate.isBefore(now) ? now : selectedDate,
                      firstDate: now,
                      lastDate: now.add(const Duration(days: 365)),
                    );
                    if (pickedDate != null) {
                      final pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(
                          pickedDate.day == now.day &&
                              pickedDate.month == now.month &&
                              pickedDate.year == now.year
                              ? now
                              : DateTime(pickedDate.year, pickedDate.month, pickedDate.day, 9, 0),
                        ),
                      );
                      if (pickedTime != null) {
                        final combined = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );
                        if (combined.isBefore(now)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Нельзя выбрать прошедшее время'),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                          return;
                        }
                        setState(() {
                          selectedDate = combined;
                        });
                        // TODO: сохранить selectedDate
                      }
                    }
                  }
              ),
              const SizedBox(height: 8),
              Text(
                'Выбрано: ${selectedDate.day.toString().padLeft(2, '0')}.${selectedDate.month.toString().padLeft(2, '0')}.${selectedDate.year} '
                    '${selectedDate.hour.toString().padLeft(2, '0')}:${selectedDate.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),

              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
