import 'package:flutter/material.dart';
import 'flashcard.dart';

class Topic {
  final String id;
  String name;
  Color color;
  IconData icon;
  final List<Flashcard> cards;
  final DateTime createdAt;

  Topic({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
    List<Flashcard>? cards,
    DateTime? createdAt,
  }) : cards = cards ?? [],
       createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color.value,
      'icon': icon.codePoint,
      'cards': cards.map((card) => card.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id'],
      name: json['name'],
      color: Color(json['color']),
      icon: IconData(json['icon'], fontFamily: 'MaterialIcons'),
      cards: (json['cards'] as List)
          .map((cardJson) => Flashcard.fromJson(cardJson))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
