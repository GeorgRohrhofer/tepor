// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'servernode.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServerNode _$ServerNodeFromJson(Map<String, dynamic> json) => ServerNode(
  id: json['Id'] as String,
  cpu: (json['Cpu'] as num).toInt(),
  ram: (json['Ram'] as num).toInt(),
  worlds: (json['worlds'] as List<dynamic>?)
      ?.map((e) => World.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ServerNodeToJson(ServerNode instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'Cpu': instance.cpu,
      'Ram': instance.ram,
      'worlds': instance.worlds.map((e) => e.toJson()).toList(),
    };
