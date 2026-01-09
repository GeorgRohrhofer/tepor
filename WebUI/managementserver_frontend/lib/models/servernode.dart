import 'package:json_annotation/json_annotation.dart';
import 'world.dart';

part 'servernode.g.dart';

@JsonSerializable(explicitToJson: true)
class ServerNode {
  @JsonKey(name: 'Id')
  final String id;

  @JsonKey(name: 'Cpu')
  final int cpu;

  @JsonKey(name: 'Ram')
  final int ram;

  /// Backend currently does NOT send this → must be optional
  final List<World> worlds;

  ServerNode({
    required this.id,
    required this.cpu,
    required this.ram,
    List<World>? worlds,
  }) : worlds = worlds ?? const [];

  factory ServerNode.fromJson(Map<String, dynamic> json) =>
      _$ServerNodeFromJson(json);

  Map<String, dynamic> toJson() => _$ServerNodeToJson(this);
}
