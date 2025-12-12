import 'package:equatable/equatable.dart';

class Playlist extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final int trackCount;
  final String ownerName;

  const Playlist({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    required this.trackCount,
    required this.ownerName,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    imageUrl,
    trackCount,
    ownerName,
  ];
}

class PlaylistTrack extends Equatable {
  final String id;
  final String name;
  final String uri;
  final int durationMs;
  final List<String> artistNames;
  final String? albumName;
  final String? albumImageUrl;

  const PlaylistTrack({
    required this.id,
    required this.name,
    required this.uri,
    required this.durationMs,
    required this.artistNames,
    this.albumName,
    this.albumImageUrl,
  });

  String get artistsString => artistNames.join(', ');

  String get durationString {
    final minutes = durationMs ~/ 60000;
    final seconds = (durationMs % 60000) ~/ 1000;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  List<Object?> get props => [
    id,
    name,
    uri,
    durationMs,
    artistNames,
    albumName,
    albumImageUrl,
  ];
}
