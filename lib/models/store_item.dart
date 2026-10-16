import 'package:flutter/material.dart';

class StoreItem {
  final String id;
  final String name;
  final String category;
  final int price;
  final IconData icon;
  final Color tint;
  bool owned;

  StoreItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.icon,
    required this.tint,
    this.owned = false,
  });
}
