import 'package:json_annotation/json_annotation.dart';

part 'world.g.dart';

@JsonSerializable()
class World {
  final String id;
  String worldname;
  String creatorname;
  String worldMode;
  final String worldSeed;

  World({
    required this.id,
    required this.worldname,
    required this.creatorname,
    required this.worldMode,
    required this.worldSeed,
  });

  factory World.fromJson(Map<String, dynamic> json) => _$WorldFromJson(json);

  Map<String, dynamic> toJson() => _$WorldToJson(this);
}

