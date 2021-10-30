// You have generated a new plugin project without
// specifying the `--platforms` flag. A plugin project supports no platforms is generated.
// To add platforms, run `flutter create -t plugin --platforms <platforms> .` under the same
// directory. You can also find a detailed instruction on how to add platforms in the `pubspec.yaml` at https://flutter.dev/docs/development/packages-and-plugins/developing-packages#plugin-platforms.

import 'dart:async';

import 'package:ping/messages.dart';

class Ping {
  AudioPlayerApi api_ = AudioPlayerApi();

  Future<void> initialize() async {
    return await api_.initialize();
  }

  Future<void> playFile(PlayMessage arg) async {
    return await api_.playFile(arg);
  }

  Future<void> dispose() async {
    return await api_.dispose();
  }

  Future<void> setVolume(VolumeMessage arg) async {
    return await api_.setVolume(arg);
  }

  Future<double> getVolume() async {
    return await api_.getVolume();
  }

  Future<void> setState(AudioStateMessage arg) async {
    return await api_.setState(arg);
  }
}
