import 'package:equatable/equatable.dart';
import 'artist.dart';

class User extends Equatable {
  final String id;
  final String displayName;
  final String? email;
  final String country;
  final String product;
  final List<SpotifyImage> images;
  final int followers;
  final String? externalUrl;

  const User({
    required this.id,
    required this.displayName,
    this.email,
    required this.country,
    required this.product,
    this.images = const [],
    this.followers = 0,
    this.externalUrl,
  });

  bool get isPremium => product == 'premium';

  String? get imageUrl => images.isNotEmpty ? images.first.url : null;

  @override
  List<Object?> get props => [
    id,
    displayName,
    email,
    country,
    product,
    images,
    followers,
    externalUrl,
  ];
}
