// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'world.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

World _$WorldFromJson(Map<String, dynamic> json) => World(
  id: json['id'] as String,
  worldname: json['worldname'] as String,
  creatorname: json['creatorname'] as String,
  worldMode: json['worldMode'] as String,
  worldSeed: json['worldSeed'] as String,
);

Map<String, dynamic> _$WorldToJson(World instance) => <String, dynamic>{
  'id': instance.id,
  'worldname': instance.worldname,
  'creatorname': instance.creatorname,
  'worldMode': instance.worldMode,
  'worldSeed': instance.worldSeed,
};
