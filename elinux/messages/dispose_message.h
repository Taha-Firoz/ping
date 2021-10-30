// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef PACKAGES_PING_PING_ELINUX_MESSAGES_DISPOSE_MESSAGE_H_
#define PACKAGES_PING_PING_ELINUX_MESSAGES_DISPOSE_MESSAGE_H_
#include <flutter/binary_messenger.h>
#include <flutter/encodable_value.h>

class DisposeMessage
{
public:
  DisposeMessage() = default;
  ~DisposeMessage() = default;

  // Prevent copying.
  DisposeMessage(DisposeMessage const &) = default;
  DisposeMessage &operator=(DisposeMessage const &) = default;

  void SetOperation(const bool dispose)
  {
    dispose_ = dispose;
  }

  bool GetOperation() const { return dispose_; }

  flutter::EncodableValue ToMap()
  {
    // todo: Add httpHeaders.
    flutter::EncodableMap map = {
        {flutter::EncodableValue("dispose"), flutter::EncodableValue(dispose_)},
    };
    return flutter::EncodableValue(map);
  }

  static DisposeMessage FromMap(const flutter::EncodableValue &value)
  {
    DisposeMessage message;
    if (std::holds_alternative<flutter::EncodableMap>(value))
    {
      auto map = std::get<flutter::EncodableMap>(value);

      flutter::EncodableValue &dispose = map[flutter::EncodableValue("dispose")];
      if (std::holds_alternative<bool>(dispose))
      {
        message.SetOperation(std::get<bool>(dispose));
      }

    }

    return message;
  }

private:
  bool dispose_;
};

#endif // PACKAGES_VIDEO_PLAYER_VIDEO_PLAYER_ELINUX_MESSAGES_CREATE_MESSAGE_H_