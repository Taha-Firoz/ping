// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef PACKAGES_PING_PING_ELINUX_MESSAGES_AUDIO_STATE_MESSAGE_H_
#define PACKAGES_PING_PING_ELINUX_MESSAGES_AUDIO_STATE_MESSAGE_H_
#include <flutter/binary_messenger.h>
#include <flutter/encodable_value.h>

enum audioControl
{
  pause,
  stop,
  play,
  noop
};

class AudioStateMessage
{
public:
  AudioStateMessage() = default;
  ~AudioStateMessage() = default;

  // Prevent copying.
  AudioStateMessage(AudioStateMessage const &) = default;
  AudioStateMessage &operator=(AudioStateMessage const &) = default;

  void SetOperation(const audioControl operation)
  {
    operation_ = operation;
  }

  audioControl GetOperation() const { return operation_; }

  flutter::EncodableValue ToMap()
  {
    // todo: Add httpHeaders.
    flutter::EncodableMap map = {
        {flutter::EncodableValue("operation"), flutter::EncodableValue(operation_)},
    };
    return flutter::EncodableValue(map);
  }

  static AudioStateMessage FromMap(const flutter::EncodableValue &value)
  {
    AudioStateMessage message;
    if (std::holds_alternative<flutter::EncodableMap>(value))
    {
      auto map = std::get<flutter::EncodableMap>(value);

      flutter::EncodableValue &operation = map[flutter::EncodableValue("operation")];
      if (std::holds_alternative<audioControl>(operation))
      {
        message.SetOperation(std::get<audioControl>(operation));
      }

    }

    return message;
  }

private:
  audioControl operation_;
};

#endif // PACKAGES_VIDEO_PLAYER_VIDEO_PLAYER_ELINUX_MESSAGES_CREATE_MESSAGE_H_