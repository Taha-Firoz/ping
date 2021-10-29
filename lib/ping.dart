// You have generated a new plugin project without
// specifying the `--platforms` flag. A plugin project supports no platforms is generated.
// To add platforms, run `flutter create -t plugin --platforms <platforms> .` under the same
// directory. You can also find a detailed instruction on how to add platforms in the `pubspec.yaml` at https://flutter.dev/docs/development/packages-and-plugins/developing-packages#plugin-platforms.

import 'dart:async';
import 'dart:ffi' as ffi;
import 'package:path/path.dart' as p;
import 'package:flutter/services.dart';
import 'dart:typed_data';

/// Audio file format
abstract class FileFormat {
  static const unknown = 0;
  static const wav = 1;
  static const flac = 2;
  static const vorbis = 3;
  static const mp3 = 4;
}

// enum status {
//   unknown,
//   wav,
//   flac,
//   vorbis,
//   mp3,
// }

/// Sample format in memory
abstract class SampleFormat {
  static const unknown = 0;
  static const u8 = 1;
  static const s16 = 2;
  static const s24 = 3;
  static const s32 = 4;
  static const f32 = 5;

  static int widthFromFormat(int arg) {
    switch (arg) {
      case SampleFormat.u8:
        return 1;
      case SampleFormat.s16:
        return 2;
      case SampleFormat.s24:
        return 3;
      case SampleFormat.s32:
        return 4;
      case SampleFormat.f32:
        return 4;
      default:
        throw MiniaudioError("unsupported sample format: $arg");
    }
  }

  static String getFormatName(int arg) {
    switch (arg) {
      case SampleFormat.unknown:
        return "Unknown";
      case SampleFormat.u8:
        return "8-bit Unsigned Integer";
      case SampleFormat.s16:
        return "16-bit Signed Integer";
      case SampleFormat.s24:
        return "24-bit Signed Integer (Tightly Packed)";
      case SampleFormat.s32:
        return "32-bit Signed Integer";
      case SampleFormat.f32:
        return "32-bit IEEE Floating Point";
      default:
        return "Invalid";
    }
  }
}

// enum sampleFormat {
//   maFormatUnknown,
//   maFormatU8,
//   maFormatS16,
//   maFormatS24,
//   maFormatS32,
//   maFormatF32,
// }

/// Type of audio device
abstract class DeviceType {
  static const playBack = 0;
  static const capture = 1;
  static const duplex = 2;
  static const loopBack = 3;
}

// enum deviceType {
//   _ignored_,
//   playBack,
//   capture,
//   duplex,
//   loopBack,
// }

/// How to dither when converting
abstract class DitherMode {
  static const none = 0;
  static const rectangle = 1;
  static const triangle = 2;
}
// enum ditherMode { none, rectangle, triangle }

/// How to mix channels when converting
abstract class ChannelMixMode {
  static const rectangular = 0;
  static const simple = 1;
  static const customWeight = 2;
  static const planarBlend = 0;
  static const default_ = 0;
}
// enum channelMixMode {
//   rectangularOrPlanarBlendOrDefault,
//   simple,
//   customWeight,
//   // planarBlend, // same value as rectangular
//   // default_, // default is a dart keyword same value as rectangular
// }

// class  {
//   static const  ;
// }

/// Operating system audio backend to use (only a subset will be available)
abstract class Backend {
  static const wasapi = 0;
  static const dsound = 1;
  static const winmm = 2;
  static const coreaudio = 3;
  static const sndio = 4;
  static const audio4 = 5;
  static const oss = 6;
  static const pulseAudioSeAudio = 7;
  static const alsa = 8;
  static const jack = 9;
  static const aaudio = 10;
  static const opensl = 11;
  static const webaudio = 12;
  static const custom = 13;

  /// null is a dart keyword
  static const null_ = 14;
}

// enum backend {
//   wasapi,
//   dsound,
//   winmm,
//   coreaudio,
//   sndio,
//   audio4,
//   oss,
//   pulseAudioSeAudio,
//   alsa,
//   jack,
//   aaudio,
//   opensl,
//   webaudio,
//   custom,
//   null_,
// }

/// Modeled as class because of weird values
/// The priority of the worker thread (default=HIGHEST)
abstract class ThreadPriority {
  static const idle = -5;
  static const lowest = -4;
  static const low = -3;
  static const normal = -2;
  static const high = -1;
  static const highest = 0;
  static const realtime = 1;
  static const default_ = 0;
}

/// How to seek() in a source
class SeekOrigin {
  static const start = 0;
  static const current = 1;
  static const end = 1;
}
// enum seekOrigin { start, current, end }

/// Contains various properties of an audio file.

class SoundFileInfo {
  String name;
  int nchannels;
  int sampleRate;
  int sampleFormat;
  late String sampleFormatName;
  late int sampleWidth;
  int numFrames;
  double duration;
  int fileFormat;

  SoundFileInfo(
    this.name,
    this.fileFormat,
    this.nchannels,
    this.sampleRate,
    this.sampleFormat,
    this.duration,
    this.numFrames,
  ) {
    sampleWidth = SampleFormat.widthFromFormat(sampleFormat);
    sampleFormatName = SampleFormat.getFormatName(sampleFormat);
  }
}

class DecodedSoundFile extends SoundFileInfo {
  Uint8List samples;
  DecodedSoundFile(String name, int nchannels, int sampleRate, int sampleFormat,
      this.samples)
      : super(name, FileFormat.unknown, nchannels, sampleRate, sampleFormat,
            samples.length / sampleRate, samples.length ~/ nchannels);
}

/// When a miniaudio specific error occurs
class MiniaudioError implements Exception {
  String cause;
  MiniaudioError(this.cause);
}

///When something went wrong during decoding an audio file
class DecodeError extends MiniaudioError {
  DecodeError(String cause) : super(cause);
}

/// Fetch some information about the audio file
SoundFileInfo getFileInfo(String filename) {
  String ext = p.extension(filename);
  if ([".ogg", ".vorbis"].contains(ext)) {
    return vorbisGetFileInfo(filename);
  } else if (ext == ".mp3") {
    return mp3GetFileInfo(filename);
  } else if (ext == ".flac") {
    return flacGetFileInfo(filename);
  } else if (ext == ".wav") {
    return wavGetFileInfo(filename);
  } else {
    throw DecodeError("unsupported file format");
  }
}

/// Reads and decodes the whole audio file.
/// Miniaudio will attempt to return the sound data in exactly the same format as in the file.
/// Unless you set convert_convert_to_16bit to True, then the result is always a 16 bit sample format.
DecodedSoundFile readFile(String filename, {bool convertTo16bit = false}) {
  String ext = p.extension(filename);
  if ([".ogg", ".vorbis"].contains(ext)) {
    if (convertTo16bit) {
      return vorbisReadFile(filename);
    } else {
      SoundFileInfo vorbis = vorbisGetFileInfo(filename);
      if (vorbis.sampleFormat == SampleFormat.s16) {
        return vorbisReadFile(filename);
      } else {
        throw MiniaudioError("file has sample format that must be converted");
      }
    }
  } else if (ext == ".mp3") {
    if (convertTo16bit) {
      return mp3ReadFileS16(filename);
    } else {
      SoundFileInfo mp3 = mp3GetFileInfo(filename);
      if (mp3.sampleFormat == SampleFormat.s16) {
        return mp3ReadFileS16(filename);
      } else if (mp3.sampleFormat == SampleFormat.f32) {
        return mp3ReadFileF32(filename);
      } else {
        throw MiniaudioError("file has sample format that must be converted");
      }
    }
  } else if (ext == ".flac") {
    if (convertTo16bit) {
      return flacReadFileS16(filename);
    } else {
      SoundFileInfo flac = flacGetFileInfo(filename);
      if (flac.sampleFormat == SampleFormat.s16) {
        return flacReadFileS16(filename);
      } else if (flac.sampleFormat == SampleFormat.s32) {
        return flacReadFileS32(filename);
      } else if (flac.sampleFormat == SampleFormat.f32) {
        return flacReadFileF32(filename);
      } else {
        throw MiniaudioError("file has sample format that must be converted");
      }
    }
  } else if (ext == ".wav") {
    if (convertTo16bit) {
      return wavReadFileS16(filename);
    } else {
      SoundFileInfo wav = wavGetFileInfo(filename);
      if (wav.sampleFormat == SampleFormat.s16) {
        return wavReadFileS16(filename);
      } else if (wav.sampleFormat == SampleFormat.s32) {
        return wavReadFileS32(filename);
      } else if (wav.sampleFormat == SampleFormat.f32) {
        return wavReadFileF32(filename);
      } else {
        throw MiniaudioError("file has sample format that must be converted");
      }
    }
  }
  throw DecodeError("unsupported file format");
}

///Fetch some information about the audio file (vorbis format).
SoundFileInfo vorbisGetFileInfo(String filename) {
  throw UnimplementedError();
}

///Fetch some information about the audio data (vorbis format).
SoundFileInfo vorbisGetInfo(Uint8List data) {
  throw UnimplementedError();
}

///Reads and decodes the whole vorbis audio file. Resulting sample format is 16 bits signed integer.
DecodedSoundFile vorbisReadFile(String filename) {
  throw UnimplementedError();
}

///Reads and decodes the whole vorbis audio data. Resulting sample format is 16 bits signed integer.
DecodedSoundFile vorbisRead(Uint8List data) {
  throw UnimplementedError();
}

///Streams the ogg vorbis audio file as interleaved 16 bit signed integer sample arrays segments.
///This uses a variable unconfigurable chunk size and cannot be used as a generic miniaudio decoder input stream.
///Consider using stream_file() instead.
Stream<List> vorbisStreamFile(String filename, {int seekFrame = 0}) async* {
  throw UnimplementedError();
}

///Fetch some information about the audio file (flac format).
SoundFileInfo flacGetFileInfo(String filename) {
  throw UnimplementedError();
}

///Fetch some information about the audio data (flac format).
SoundFileInfo flacGetInfo(Uint8List data) {
  throw UnimplementedError();
}

///Reads and decodes the whole flac audio file. Resulting sample format is 32 bits signed integer.
DecodedSoundFile flacReadFileS32(String filename) {
  throw UnimplementedError();
}

///Reads and decodes the whole flac audio file. Resulting sample format is 16 bits signed integer.
DecodedSoundFile flacReadFileS16(String filename) {
  throw UnimplementedError();
}

///Reads and decodes the whole flac audio file. Resulting sample format is 32 bits float.
DecodedSoundFile flacReadFileF32(String filename) {
  throw UnimplementedError();
}

///Reads and decodes the whole flac audio data. Resulting sample format is 32 bits signed integer.
DecodedSoundFile flacReadS32(Uint8List data) {
  throw UnimplementedError();
}

///Reads and decodes the whole flac audio data. Resulting sample format is 16 bits signed integer.
DecodedSoundFile flacReadS16(Uint8List data) {
  throw UnimplementedError();
}

///Reads and decodes the whole flac audio file. Resulting sample format is 32 bits float.
DecodedSoundFile flacReadF32(Uint8List data) {
  throw UnimplementedError();
}

///Streams the flac audio file as interleaved 16 bit signed integer sample arrays segments.
///This uses a fixed chunk size and cannot be used as a generic miniaudio decoder input stream.
///Consider using stream_file() instead.
Stream<List> flacStreamFile(String filename,
    {int framesToRead = 1024, int seekFrame = 0}) async* {
  throw UnimplementedError();
}

///Fetch some information about the audio file (mp3 format).
SoundFileInfo mp3GetFileInfo(String filename) {
  throw UnimplementedError();
}

///Fetch some information about the audio data (mp3 format).
SoundFileInfo mp3GetInfo(Uint8List data) {
  throw UnimplementedError();
}

///Reads and decodes the whole mp3 audio file. Resulting sample format is 16 bits signed integer.
DecodedSoundFile mp3ReadFileS16(String filename) {
  throw UnimplementedError();
}

///Reads and decodes the whole mp3 audio file. Resulting sample format is 32 bits float.
DecodedSoundFile mp3ReadFileF32(String filename) {
  throw UnimplementedError();
}

///Reads and decodes the whole mp3 audio data. Resulting sample format is 16 bits signed integer.
DecodedSoundFile mp3ReadS16(Uint8List data) {
  throw UnimplementedError();
}

///Reads and decodes the whole mp3 audio data. Resulting sample format is 32 bits float.
DecodedSoundFile mp3ReadF32(Uint8List data) {
  throw UnimplementedError();
}

///Streams the mp3 audio file as interleaved 16 bit signed integer sample arrays segments.
///This uses a fixed chunk size and cannot be used as a generic miniaudio decoder input stream.
///Consider using stream_file() instead.
Stream<List> mp3StreamFile(String filename,
    {int framesToRead = 1024, int seekFrame = 0}) async* {
  throw UnimplementedError();
}

///Fetch some information about the audio file (wav format).
SoundFileInfo wavGetFileInfo(String filename) {
  throw UnimplementedError();
}

///Fetch some information about the audio data (wav format).
SoundFileInfo wavGetInfo(Uint8List data) {
  throw UnimplementedError();
}

///Reads and decodes the whole wav audio file. Resulting sample format is 32 bits signed integer.
DecodedSoundFile wavReadFileS32(String filename) {
  throw UnimplementedError();
}

///Reads and decodes the whole wav audio file. Resulting sample format is 16 bits signed integer.
DecodedSoundFile wavReadFileS16(String filename) {
  throw UnimplementedError();
}

///Reads and decodes the whole wav audio file. Resulting sample format is 32 bits float.
DecodedSoundFile wavReadFileF32(String filename) {
  throw UnimplementedError();
}

///Reads and decodes the whole wav audio data. Resulting sample format is 32 bits signed integer.
DecodedSoundFile wavReadS32(Uint8List data) {
  throw UnimplementedError();
}

///Reads and decodes the whole wav audio data. Resulting sample format is 16 bits signed integer.
DecodedSoundFile wavReadS16(Uint8List data) {
  throw UnimplementedError();
}

///Reads and decodes the whole wav audio data. Resulting sample format is 32 bits float.
DecodedSoundFile wavReadF32(Uint8List data) {
  throw UnimplementedError();
}

///Streams the WAV audio file as interleaved 16 bit signed integer sample arrays segments.
///This uses a fixed chunk size and cannot be used as a generic miniaudio decoder input stream.
///Consider using stream_file() instead.
Stream<List> wavStreamFile(String filename,
    {int framesToRead = 1024, int seekFrame = 0}) async* {
  throw UnimplementedError();
}

///Query the audio playback and record devices that miniaudio provides
class Devices {
  ffi.Pointer context;
  Devices({List<Backend>? backends}) : context = ffi.nullptr {
    throw UnimplementedError();
  }

  // Either delete the context on the side of C++ or dart, dart doesn't have destructors though :/
  void dispose() {
    if (context != ffi.nullptr) {
      throw UnimplementedError();
    }
  }

  ///Get a list of playback devices and some details about them
  List<Map<String, dynamic>> getPlaybacks() {
    throw UnimplementedError();
  }

  ///Get a list of capture devices and some details about them
  List<Map<String, dynamic>> getCaptures() {
    throw UnimplementedError();
  }

// deviceInfo: ffi.CData
  Map<String, dynamic> getInfo(DeviceType deviceType, dynamic deviceInfo) {
    throw UnimplementedError();
    return {
      "formats": "",
      "minChannels": deviceInfo.minChannels,
      "maxChannels": deviceInfo.maxChannels,
      "minSampleRate": deviceInfo.minSampleRate,
      "maxSampleRate": deviceInfo.maxSampleRate
    };
  }
}

int _format_from_width(int sampleWidth, {bool isFloat = false}) {
  if (isFloat) {
    return SampleFormat.f32;
  } else if (sampleWidth == 1) {
    return SampleFormat.u8;
  } else if (sampleWidth == 2) {
    return SampleFormat.s16;
  } else if (sampleWidth == 3) {
    return SampleFormat.s24;
  } else if (sampleWidth == 4) {
    return SampleFormat.s32;
  } else {
    throw MiniaudioError("unsupported sample width: $sampleWidth");
  }
}

///Convenience function to decode any supported audio file to raw PCM samples in your chosen format
DecodedSoundFile decode_file(String filename,
    {int outputFormat = SampleFormat.s16,
    int nchannels = 2,
    int sampleRate = 44100,
    int dither = DitherMode.none}) {
  throw UnimplementedError();
}

///Convenience function to decode any supported audio file in memory to raw PCM samples in your chosen format
DecodedSoundFile decode(Uint8List data,
    {int outputFormat = SampleFormat.s16,
    int nchannels = 2,
    int sampleRate = 44100,
    int dither = DitherMode.none}) {
  throw UnimplementedError();
}

Stream<ffi.Array> _samples_stream_generator(int framesToRead, int nchannels,
    int outputFormat, ffi.Struct decoder, dynamic data, ffi.Pointer onClose) {
  throw UnimplementedError();
}

/// Convenience generator function to decode and stream any supported audio file
/// as chunks of raw PCM samples in the chosen format.
/// If you send() a number into the generator rather than just using next() on it,
/// you'll get that given number of frames, instead of the default configured amount.
/// This is particularly useful to plug this stream into an audio device callback that
/// wants a variable number of frames per call.
Stream<ffi.Array> stream_file(String filename,
    {int outputFormat = SampleFormat.s16,
    int nchannels = 2,
    int sampleRate = 44100,
    int framesToRead = 1024,
    int dither = DitherMode.none,
    int seekFrame = 0}) {
  throw UnimplementedError();
}

///Convenience generator function to decode and stream any supported audio file in memory
///as chunks of raw PCM samples in the chosen format.
///If you send() a number into the generator rather than just using next() on it,
///you'll get that given number of frames, instead of the default configured amount.
///This is particularly useful to plug this stream into an audio device callback that
///wants a variable number of frames per call.
Stream<ffi.Array> stream_memory(Uint8List data,
    {int outputFormat = SampleFormat.s16,
    int nchannels = 2,
    int sampleRate = 44100,
    int framesToRead = 1024,
    int dither = DitherMode.none}) {
  throw UnimplementedError();
}

class Ping {
  static const MethodChannel _channel = MethodChannel('ping');

  Future<SoundFileInfo> getSoundFileInfo(
      String name,
      int nchannels,
      int sampleRate,
      int sampleFormat,
      int numFrames,
      double duration,
      int fileFormat) async {
    return SoundFileInfo(name, fileFormat, nchannels, sampleRate, sampleFormat,
        duration, numFrames);
  }

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
