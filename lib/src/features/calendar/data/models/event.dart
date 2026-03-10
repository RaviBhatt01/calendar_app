import 'package:flutter/material.dart';

class Event {
  String title;
  String description;
  TimeOfDay time;

  Event({
    required this.title,
    required this.description,
    required this.time,
  });
}