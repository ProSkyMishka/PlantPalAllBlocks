import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/design_tokens.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const icons = ['leaf', 'plus', 'settings'];
    const labels = ['Растения', 'Добавить', 'Настройки'];
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: List.generate(3, (i) => BottomNavigationBarItem(
        icon: SvgPicture.asset(
          'assets/images/icons/${icons[i]}.svg',
          color: i == currentIndex
              ? AppColors.primaryDark
              : AppColors.textSecondary,
        ),
        label: labels[i],
      )),
    );
  }
}
