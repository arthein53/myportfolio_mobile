import 'package:flutter/material.dart';

class ItemHomepage {
  const ItemHomepage(this.name, this.icon, this.color, {this.route});

  final String name;
  final IconData icon;
  final Color color;
  final String? route;
}

class ItemCard extends StatelessWidget {
  const ItemCard(this.item, {super.key, this.onTap});

  final ItemHomepage item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: item.color,
    borderRadius: BorderRadius.circular(12),
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item.icon, color: Colors.white, size: 30),
              const SizedBox(height: 6),
              Text(
                item.name,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
