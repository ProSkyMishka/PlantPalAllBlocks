import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/theme/design_tokens.dart';
import '../home/home_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var state = ref.watch(homeControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF01262E),
      floatingActionButton: FloatingActionButton(
        onPressed: ()  async {
          final result = await context.push('/detect');
          if (result == 'updated') {
            await ref.read(homeControllerProvider.notifier).loadPlants();
          }
        },
        backgroundColor: const Color(0xFF709E1F),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Верхняя картинка
            // Верхний фон с ростками и градиентом
            SizedBox(
              height: 200,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/plant_header.png',
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Color(0xFF01262E), // основной фон
                        ],
                      ),
                    ),
                  ),
                  // Виджет Positioned теперь внутри Stack
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: SizedBox(
                      height: 200,
                      child: Container(),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Заголовок и меню
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Мои растения',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium!
                            .copyWith(color: Colors.white),
                      ),
                      IconButton(
                        icon: const Icon(Icons.menu, color: Colors.white),
                        onPressed: () {
                          context.push('/settings');
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Температура и влажность
                  Row(
                    children: const [
                      _InfoBox(title: 'Температура', value: '0.0 °C'),
                      _InfoBox(title: 'Влажность', value: '0.0%'),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Поиск
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5ED),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        const Icon(Icons.search, color: Color(0xFF6E7D88)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            style: const TextStyle(color: Colors.black),
                            decoration: const InputDecoration(
                              hintText: 'Поиск',
                              hintStyle: TextStyle(color: Color(0xFF6E7D88)),
                              border: InputBorder.none,
                              filled: true,
                              fillColor: Color(0xFFE8F5ED),
                            ),
                            onChanged: (v) => ref
                                .read(homeControllerProvider.notifier)
                                .search(v),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.swap_vert, color: Color(0xFF6E7D88)),
                          onPressed: () {
                            // логика сортировки
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Сетка карточек
                  if (state.status == HomeStatus.loading)
                    const Center(child: CircularProgressIndicator())
                  else if (state.status == HomeStatus.error)
                    Center(
                      child: Text(
                        state.message!,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    )
                  else if (state.filtered.isEmpty)
                      const Center(
                        child: Text(
                          'Пока что их нет',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 16, top: 8),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1,
                        ),
                        itemCount: state.filtered.length,
                        itemBuilder: (ctx, i) {
                          final plant = state.filtered[i];
                          return GestureDetector(
                            onTap: () async {
                              final result = await context.push('/plant/${plant.id}');
                              if (result == 'updated') {
                                await ref.read(homeControllerProvider.notifier).loadPlants();
                              }
                            },
                            child: Stack(
                              children: [
                                Container(
                                  width: double.infinity,  // Растягиваем контейнер на всю ширину
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2A6A2C),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const SizedBox(height: 8),
                                      if (plant.imageUrl != Null)
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(16), // радиус скругления
                                          child: Image.memory(
                                            base64Decode(plant.imageUrl ?? ""),
                                            width: 120,
                                            height: 120,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      Text(
                                        plant.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Icon(Icons.star_border, color: Colors.white),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String title;
  final String value;

  const _InfoBox({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 64,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF9EAE4A),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(color: Colors.white),
            ),
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
