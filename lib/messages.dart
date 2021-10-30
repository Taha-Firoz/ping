import 'dart:async';

import 'package:flutter/services.dart';

enum DataSourceType {
  /// The audio was included in the app's asset files.
  asset,

  /// The audio was downloaded from the internet.
  network,

  /// The audio was loaded off of the local filesystem.
  file,
}

/// Description of the data source used to play the audio
class DataSource {
  /// Constructs an instance of [DataSource].
  ///
  /// The [sourceType] is always required.
  ///
  /// The [uri] argument takes the form of `'https://example.com/video.mp4'` or
  /// `'file://${file.path}'`.
  ///
  /// The [formatHint] argument can be null.
  ///
  /// The [asset] argument takes the form of `'assets/video.mp4'`.
  ///
  /// The [package] argument must be non-null when the asset comes from a
  /// package and null otherwise.
  DataSource({
    required this.sourceType,
    this.uri,
    this.asset,
    this.package,
    this.httpHeaders = const {},
  });

  /// The way in which the video was originally loaded.
  ///
  /// This has nothing to do with the video's file type. It's just the place
  /// from which the video is fetched from.
  final DataSourceType sourceType;

  /// The URI to the video file.
  ///
  /// This will be in different formats depending on the [DataSourceType] of
  /// the original video.
  final String? uri;

  /// HTTP headers used for the request to the [uri].
  /// Only for [DataSourceType.network] videos.
  /// Always empty for other video types.
  Map<String, String> httpHeaders;

  /// The name of the asset. Only set for [DataSourceType.asset] videos.
  final String? asset;

  /// The package that the asset was loaded from. Only set for
  /// [DataSourceType.asset] videos.
  final String? package;
}

class PlayMessage {
  bool loop = false;
  String? asset;
  String? uri;
  String? packageName;
  Map<Object?, Object?>? httpHeaders;

  Object encode() {
    final Map<Object?, Object?> pigeonMap = <Object?, Object?>{};
    pigeonMap['loop'] = loop;
    pigeonMap['asset'] = asset;
    pigeonMap['uri'] = uri;
    pigeonMap['packageName'] = packageName;
    pigeonMap['httpHeaders'] = httpHeaders;
    return pigeonMap;
  }

  static PlayMessage decode(Object message) {
    final Map<Object?, Object?> pigeonMap = message as Map<Object?, Object?>;
    return PlayMessage()
      ..loop = pigeonMap['loop'] as bool
      ..asset = pigeonMap['asset'] as String?
      ..uri = pigeonMap['uri'] as String?
      ..packageName = pigeonMap['packageName'] as String?
      ..httpHeaders = pigeonMap['httpHeaders'] as Map<Object?, Object?>?;
  }
}

enum audioControl { pause, stop, play, noop }

class AudioStateMessage {
  audioControl operation = audioControl.noop;

  static AudioStateMessage decode(Object message) {
    final Map<Object?, Object?> pigeonMap = message as Map<Object?, Object?>;
    return AudioStateMessage()
      ..operation = pigeonMap['operation'] as audioControl;
  }

  Object encode() {
    final Map<Object?, Object?> pigeonMap = <Object?, Object?>{};
    pigeonMap['operation'] = operation;
    return pigeonMap;
  }
}

class VolumeMessage {
  double? volume;

  Object encode() {
    final Map<Object?, Object?> pigeonMap = <Object?, Object?>{};
    pigeonMap['volume'] = volume;
    return pigeonMap;
  }

  static VolumeMessage decode(Object message) {
    final Map<Object?, Object?> pigeonMap = message as Map<Object?, Object?>;
    return VolumeMessage()..volume = pigeonMap['volume'] as double?;
  }
}

class AudioPlayerApi {
  Future<void> initialize() async {
    const BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.AudioPlayerApi.initialize', StandardMessageCodec());
    final Map<Object?, Object?>? replyMap =
        await channel.send(null) as Map<Object?, Object?>?;
    if (replyMap == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
        details: null,
      );
    } else if (replyMap['error'] != null) {
      final Map<Object?, Object?> error =
          replyMap['error'] as Map<Object?, Object?>;
      throw PlatformException(
        code: error['code'] as String,
        message: error['message'] as String?,
        details: error['details'],
      );
    } else {
      // noop
    }
  }

  Future<void> playFile(PlayMessage arg) async {
    final Object encoded = arg.encode();
    const BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.AudioPlayerApi.playAudioFile',
        StandardMessageCodec());

    final Map<Object?, Object?>? replyMap =
        await channel.send(encoded) as Map<Object?, Object?>?;
    if (replyMap == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
        details: null,
      );
    } else if (replyMap['error'] != null) {
      final Map<Object?, Object?> error =
          replyMap['error'] as Map<Object?, Object?>;
      throw PlatformException(
        code: error['code'] as String,
        message: error['message'] as String?,
        details: error['details'],
      );
    } else {
      // noop
    }
  }

  Future<void> dispose() async {
    const BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.AudioPlayerApi.dispose', StandardMessageCodec());
    final Map<Object?, Object?>? replyMap =
        await channel.send(null) as Map<Object?, Object?>?;
    if (replyMap == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
        details: null,
      );
    } else if (replyMap['error'] != null) {
      final Map<Object?, Object?> error =
          replyMap['error'] as Map<Object?, Object?>;
      throw PlatformException(
        code: error['code'] as String,
        message: error['message'] as String?,
        details: error['details'],
      );
    } else {
      // noop
    }
  }

  Future<void> setVolume(VolumeMessage arg) async {
    final Object encoded = arg.encode();
    const BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.AudioPlayerApi.setVolume', StandardMessageCodec());
    final Map<Object?, Object?>? replyMap =
        await channel.send(encoded) as Map<Object?, Object?>?;
    if (replyMap == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
        details: null,
      );
    } else if (replyMap['error'] != null) {
      final Map<Object?, Object?> error =
          replyMap['error'] as Map<Object?, Object?>;
      throw PlatformException(
        code: error['code'] as String,
        message: error['message'] as String?,
        details: error['details'],
      );
    } else {
      // noop
    }
  }

  Future<double> getVolume() async {
    const BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.AudioPlayerApi.getVolume', StandardMessageCodec());
    final Map<Object?, Object?>? replyMap =
        await channel.send(null) as Map<Object?, Object?>?;
    if (replyMap == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
        details: null,
      );
    } else if (replyMap['error'] != null) {
      final Map<Object?, Object?> error =
          replyMap['error'] as Map<Object?, Object?>;
      throw PlatformException(
        code: error['code'] as String,
        message: error['message'] as String?,
        details: error['details'],
      );
    } else {
      return replyMap['result'] as double;
    }
  }

  Future<void> setState(AudioStateMessage arg) async {
    final Object encoded = arg.encode();
    const BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.AudioPlayerApi.setAudioState',
        StandardMessageCodec());
    final Map<Object?, Object?>? replyMap =
        await channel.send(encoded) as Map<Object?, Object?>?;
    if (replyMap == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
        details: null,
      );
    } else if (replyMap['error'] != null) {
      final Map<Object?, Object?> error =
          replyMap['error'] as Map<Object?, Object?>;
      throw PlatformException(
        code: error['code'] as String,
        message: error['message'] as String?,
        details: error['details'],
      );
    } else {
      // noop
    }
  }
}
