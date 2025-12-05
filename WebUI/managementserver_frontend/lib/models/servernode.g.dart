// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'servernode.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServerNode _$ServerNodeFromJson(Map<String, dynamic> json) => ServerNode(
  id: json['id'] as String,
  cpu: json['cpu'] as String,
  ram: json['ram'] as String,
  network: json['network'] as String,
  disk: json['disk'] as String,
  worlds: (json['worlds'] as List<dynamic>)
      .map((e) => World.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ServerNodeToJson(ServerNode instance) =>
    <String, dynamic>{
      'id': instance.id,
      'cpu': instance.cpu,
      'ram': instance.ram,
      'network': instance.network,
      'disk': instance.disk,
      'worlds': instance.worlds,
    };
