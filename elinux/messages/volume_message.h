// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef PACKAGES_PING_PING_ELINUX_MESSAGES_VOLUME_MESSAGE_H_
#define PACKAGES_PING_PING_ELINUX_MESSAGES_VOLUME_MESSAGE_H_
#include <flutter/binary_messenger.h>
#include <flutter/encodable_value.h>
#include <variant>

class VolumeMessage {
 public:
  VolumeMessage() = default;
  ~VolumeMessage() = default;

  // Prevent copying.
  VolumeMessage(VolumeMessage const&) = default;
  VolumeMessage& operator=(VolumeMessage const&) = default;
  
  void SetVolume(double volume) { volume_ = volume; }

  float GetVolume() const { return volume_; }

  flutter::EncodableValue ToMap() {
    // todo: Add httpHeaders.
    flutter::EncodableMap map = {{flutter::EncodableValue("volume"), flutter::EncodableValue(volume_)}};
    return flutter::EncodableValue(map);
  }

  static VolumeMessage FromMap(const flutter::EncodableValue& value) {
    VolumeMessage message;
    if (std::holds_alternative<flutter::EncodableMap>(value)) {
      auto map = std::get<flutter::EncodableMap>(value);

      flutter::EncodableValue& volume = map[flutter::EncodableValue("volume")];
      if (std::holds_alternative<double>(volume)) {
        message.SetVolume(std::get<double>(volume));
      }
    }

    return message;
  }

 private:
  float volume_ = 0;
};

#endif  // PACKAGES_VIDEO_PLAYER_VIDEO_PLAYER_ELINUX_MESSAGES_CREATE_MESSAGE_H_