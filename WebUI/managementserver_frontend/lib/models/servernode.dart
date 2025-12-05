import 'package:json_annotation/json_annotation.dart';
import 'world.dart';

part 'servernode.g.dart';

@JsonSerializable()
class ServerNode {
  final String id;
  final String cpu;
  final String ram;
  final String network;
  final String disk;
  List<World> worlds;

  ServerNode({
    required this.id,
    required this.cpu,
    required this.ram,
    required this.network,
    required this.disk,
    required this.worlds,
  });

  factory ServerNode.fromJson(Map<String, dynamic> json) => _$ServerNodeFromJson(json);
  
  Map<String, dynamic> toJson() => _$ServerNodeToJson(this);
}
