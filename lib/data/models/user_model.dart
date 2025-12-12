import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user.dart';
import 'artist_model.dart';
import 'spotify_image_model.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String id;
  @JsonKey(name: 'display_name')
  final String? displayName;
  final String? email;
  final String? country;
  final String? product;
  final List<SpotifyImageModel>? images;
  final FollowersModel? followers;
  @JsonKey(name: 'external_urls')
  final ExternalUrlsModel? externalUrls;

  const UserModel({
    required this.id,
    this.displayName,
    this.email,
    this.country,
    this.product,
    this.images,
    this.followers,
    this.externalUrls,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  User toEntity() => User(
    id: id,
    displayName: displayName ?? 'Unknown',
    email: email,
    country: country ?? 'US',
    product: product ?? 'free',
    images: images?.map((i) => i.toEntity()).toList() ?? [],
    followers: followers?.total ?? 0,
    externalUrl: externalUrls?.spotify,
  );
}
