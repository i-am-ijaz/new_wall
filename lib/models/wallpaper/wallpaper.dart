import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'wallpaper.g.dart';

@HiveType(typeId: 1)
@JsonSerializable()
class Wallpaper {
  final String url;
  final String tag;
  final String? id;
  bool isFav;

  Wallpaper({
    required this.url,
    required this.tag,
    this.id,
    this.isFav = false,
  });

  factory Wallpaper.fromJson(Map<String, dynamic> json) =>
      _$WallpaperFromJson(json);

  Map<String, dynamic> toJson() => _$WallpaperToJson(this);
}
