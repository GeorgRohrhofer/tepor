import 'package:json_annotation/json_annotation.dart';

part 'world.g.dart';

@JsonSerializable()
class World {
  final String id;
  String name;
  String ownerId;
  String hash;
  String config;

  World({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.hash,
    required this.config
  });

  factory World.fromJson(Map<String, dynamic> json) => _$WorldFromJson(json);

  Map<String, dynamic> toJson() => _$WorldToJson(this);
}

