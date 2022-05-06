// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallpaper.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Wallpaper _$WallpaperFromJson(Map<String, dynamic> json) => Wallpaper(
      url: json['url'] as String,
      tag: json['tag'] as String,
      id: json['id'] as String?,
      isFav: json['isFav'] as bool? ?? false,
    );

Map<String, dynamic> _$WallpaperToJson(Wallpaper instance) => <String, dynamic>{
      'url': instance.url,
      'tag': instance.tag,
      'id': instance.id,
      'isFav': instance.isFav,
    };
