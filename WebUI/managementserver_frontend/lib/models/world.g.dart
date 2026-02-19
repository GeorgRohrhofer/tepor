// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'world.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

World _$WorldFromJson(Map<String, dynamic> json) => World(
  id: json['Id'] as String,
  name: json['Name'] as String,
  ownerId: json['OwnerId'] as String,
  hash: json['Hash'] as String,
  config: json['Config'] as String,
);

Map<String, dynamic> _$WorldToJson(World instance) => <String, dynamic>{
  'Id': instance.id,
  'Name': instance.name,
  'OwnerId': instance.ownerId,
  'Hash': instance.hash,
  'Config': instance.config,
};
