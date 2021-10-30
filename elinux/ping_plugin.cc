#include "include/ping/ping_plugin.h"
#include "miniaudio/miniaudio.h"
#include "messages/messages.h"
#include "ping_miniaudio.h"

#include <flutter/basic_message_channel.h>
#include <flutter/encodable_value.h>
#include <flutter/plugin_registrar.h>
#include <flutter/standard_message_codec.h>
#include <unistd.h>

#include <map>
#include <memory>
#include <sstream>
#include <string>

namespace
{
  const std::string GetExecutableDirectory();
  
  constexpr char playAudioFile[] =
      "dev.flutter.pigeon.AudioPlayerApi.playAudioFile";

  constexpr char setAudioState[] =
      "dev.flutter.pigeon.AudioPlayerApi.setAudioState";

  constexpr char setVolume[] =
      "dev.flutter.pigeon.AudioPlayerApi.setVolume";

  constexpr char getVolume[] =
      "dev.flutter.pigeon.AudioPlayerApi.getVolume";
      
  constexpr char dispose[] =
      "dev.flutter.pigeon.AudioPlayerApi.dispose";

  constexpr char kEncodableMapkeyResult[] = "result";
  constexpr char kEncodableMapkeyError[] = "error";
  class PingPlugin : public flutter::Plugin
  {
  public:
    static void RegisterWithRegistrar(flutter::PluginRegistrar *registrar);

    PingPlugin();

    virtual ~PingPlugin();

  private:
    void HandlePlayAudioFile(
        const flutter::EncodableValue &message,
        flutter::MessageReply<flutter::EncodableValue> reply);

    void HandleSetAudioState(
        const flutter::EncodableValue &message,
        flutter::MessageReply<flutter::EncodableValue> reply);

    void HandleSetVolume(
        const flutter::EncodableValue &message,
        flutter::MessageReply<flutter::EncodableValue> reply);

    void HandleGetVolume(
        const flutter::EncodableValue &message,
        flutter::MessageReply<flutter::EncodableValue> reply);

    void HandleDispose(
        const flutter::EncodableValue &message,
        flutter::MessageReply<flutter::EncodableValue> reply);

    ma_result result;
    ma_decoder decoder;
    ma_device_config deviceConfig;
    ma_device device;
  };
  // static
  void PingPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrar *registrar)
  {
    auto plugin = std::make_unique<PingPlugin>();
    {
      auto channel =
          std::make_unique<flutter::BasicMessageChannel<flutter::EncodableValue>>(
              registrar->messenger(), playAudioFile,
              &flutter::StandardMessageCodec::GetInstance());

      channel->SetMessageHandler(
          [plugin_pointer = plugin.get()](const auto &call, auto result)
          {
            plugin_pointer->HandlePlayAudioFile(call, std::move(result));
          });
    }

    {
      auto channel =
          std::make_unique<flutter::BasicMessageChannel<flutter::EncodableValue>>(
              registrar->messenger(), setAudioState,
              &flutter::StandardMessageCodec::GetInstance());

      channel->SetMessageHandler(
          [plugin_pointer = plugin.get()](const auto &call, auto result)
          {
            plugin_pointer->HandleSetAudioState(call, std::move(result));
          });
    }

    {
      auto channel =
          std::make_unique<flutter::BasicMessageChannel<flutter::EncodableValue>>(
              registrar->messenger(), setVolume,
              &flutter::StandardMessageCodec::GetInstance());

      channel->SetMessageHandler(
          [plugin_pointer = plugin.get()](const auto &call, auto result)
          {
            plugin_pointer->HandleSetVolume(call, std::move(result));
          });
    }

    {
      auto channel =
          std::make_unique<flutter::BasicMessageChannel<flutter::EncodableValue>>(
              registrar->messenger(), getVolume,
              &flutter::StandardMessageCodec::GetInstance());

      channel->SetMessageHandler(
          [plugin_pointer = plugin.get()](const auto &call, auto result)
          {
            plugin_pointer->HandleGetVolume(call, std::move(result));
          });
    }

    {
      auto channel =
          std::make_unique<flutter::BasicMessageChannel<flutter::EncodableValue>>(
              registrar->messenger(), dispose,
              &flutter::StandardMessageCodec::GetInstance());

      channel->SetMessageHandler(
          [plugin_pointer = plugin.get()](const auto &call, auto result)
          {
            plugin_pointer->HandleDispose(call, std::move(result));
          });
    }

    registrar->AddPlugin(std::move(plugin));
  }

  PingPlugin::PingPlugin() {}

  PingPlugin::~PingPlugin() {}

  void PingPlugin::HandlePlayAudioFile(
      const flutter::EncodableValue &message,
      flutter::MessageReply<flutter::EncodableValue> reply)
  {
    flutter::EncodableMap messageResult;
    ma_device_state device_state = ma_device_get_state(&device);
    if (device_state != ma_device_state_uninitialized && device_state != ma_device_state_stopped)
    {
      messageResult.emplace(flutter::EncodableValue(kEncodableMapkeyError), flutter::EncodableValue("Some Error"));
      reply(flutter::EncodableValue(messageResult));
      return;
    }

    auto meta = PlayMessage::FromMap(message);
    std::string uri;
    if (!meta.GetAsset().empty())
    {
      // todo: gets propery path of the Flutter project.
      std::string flutter_project_path = GetExecutableDirectory() + "/data/";
      uri = flutter_project_path + "flutter_assets/" + meta.GetAsset();
    }
    else
    {
      uri = meta.GetUri();
    }

    result = ma_decoder_init_file(uri.c_str(), NULL, &decoder);
    if (result != MA_SUCCESS)
    {
      messageResult.emplace(flutter::EncodableValue(kEncodableMapkeyError), flutter::EncodableValue("File not found!: " + std::to_string(result)));
      reply(flutter::EncodableValue(messageResult));
      return;
    }

    if (meta.GetLoop())
    {
      ma_data_source_set_looping(&decoder, MA_TRUE);
    }
    deviceConfig = ma_device_config_init(ma_device_type_playback);
    deviceConfig.playback.format = decoder.outputFormat;
    deviceConfig.playback.channels = decoder.outputChannels;
    deviceConfig.sampleRate = decoder.outputSampleRate;
    deviceConfig.dataCallback = data_callback;
    deviceConfig.pUserData = &decoder;

    result = ma_device_init(NULL, &deviceConfig, &device);
    if (result != MA_SUCCESS)
    {
      ma_decoder_uninit(&decoder);
      messageResult.emplace(flutter::EncodableValue(kEncodableMapkeyError), flutter::EncodableValue("Failed to open playback device: " + std::to_string(result)));
      reply(flutter::EncodableValue(messageResult));
      return;
    }

    result = ma_device_start(&device);
    if (result != MA_SUCCESS)
    {
      ma_device_uninit(&device);
      ma_decoder_uninit(&decoder);
      messageResult.emplace(flutter::EncodableValue(kEncodableMapkeyError), flutter::EncodableValue("Failed to start playback device: " + std::to_string(result)));
      reply(flutter::EncodableValue(messageResult));
      return;
    }
    messageResult.emplace(flutter::EncodableValue(kEncodableMapkeyResult), flutter::EncodableValue());

    reply(flutter::EncodableValue(messageResult));
  }

  void PingPlugin::HandleSetAudioState(
      const flutter::EncodableValue &message,
      flutter::MessageReply<flutter::EncodableValue> reply)
  {
    flutter::EncodableMap messageResult;
    auto meta = AudioStateMessage::FromMap(message);
    ma_device_state device_state = ma_device_get_state(&device);

    switch (meta.GetOperation())
    {
    case audioControl::noopAudio:
    {
      messageResult.emplace(flutter::EncodableValue(kEncodableMapkeyResult), flutter::EncodableValue());
      break;
    }
    // Stops and unitilizes devices so no more playback
    case audioControl::stopAudio:
    {
      if (device_state == ma_device_state_started)
      {
        result = ma_device_stop(&device);
        if (result != MA_SUCCESS)
        {
          ma_device_uninit(&device);
          ma_decoder_uninit(&decoder);
          messageResult.emplace(flutter::EncodableValue(kEncodableMapkeyError), flutter::EncodableValue("Failed to stop playback device: " + std::to_string(result)));
        }
        else
        {
          ma_device_uninit(&device);
          ma_decoder_uninit(&decoder);
          messageResult.emplace(flutter::EncodableValue(kEncodableMapkeyResult), flutter::EncodableValue());
        }
      }
      break;
    }
    case audioControl::playAudio:
    {
      if (device_state == ma_device_state_stopped)
      {
        result = ma_device_start(&device);
        if (result != MA_SUCCESS)
        {
          ma_device_uninit(&device);
          ma_decoder_uninit(&decoder);
          messageResult.emplace(flutter::EncodableValue(kEncodableMapkeyError), flutter::EncodableValue("Failed to start playback device: " + std::to_string(result)));
          reply(flutter::EncodableValue(messageResult));
          return;
        }
        else
        {
          messageResult.emplace(flutter::EncodableValue(kEncodableMapkeyResult), flutter::EncodableValue());
        }
      }
      break;
    }
    // Only stops audio, resumable
    case audioControl::pauseAudio:
    {
      if (device_state == ma_device_state_started)
      {
        result = ma_device_stop(&device);
        if (result != MA_SUCCESS)
        {
          ma_device_uninit(&device);
          ma_decoder_uninit(&decoder);
          messageResult.emplace(flutter::EncodableValue(kEncodableMapkeyError), flutter::EncodableValue("Failed to stop playback device: " + std::to_string(result)));
        }
        else
        {
          messageResult.emplace(flutter::EncodableValue(kEncodableMapkeyResult), flutter::EncodableValue());
        }
      }
      break;
    }
    }
    // messageResult.emplace(flutter::EncodableValue(kEncodableMapkeyError), flutter::EncodableValue("Some Error"));

    reply(flutter::EncodableValue(messageResult));
  }

  void PingPlugin::HandleSetVolume(
      const flutter::EncodableValue &message,
      flutter::MessageReply<flutter::EncodableValue> reply)
  {

    flutter::EncodableMap messageResult;
    auto meta = VolumeMessage::FromMap(message);
    result = ma_device_set_master_volume(&device, meta.GetVolume());
    if (result != MA_SUCCESS)
    {
      ma_device_uninit(&device);
      ma_decoder_uninit(&decoder);
      messageResult.emplace(flutter::EncodableValue(kEncodableMapkeyError), flutter::EncodableValue("Failed to set volume : " + std::to_string(result)));
    }
    else
    {
      messageResult.emplace(flutter::EncodableValue(kEncodableMapkeyResult), flutter::EncodableValue());
    }
    reply(flutter::EncodableValue(result));
  }

  void PingPlugin::HandleGetVolume(
      const flutter::EncodableValue &message,
      flutter::MessageReply<flutter::EncodableValue> reply)
  {

    flutter::EncodableMap messageResult;
    float volume = -1;
    result = ma_device_get_master_volume(&device, &volume);
    if (result != MA_SUCCESS)
    {
      ma_device_uninit(&device);
      ma_decoder_uninit(&decoder);
      messageResult.emplace(flutter::EncodableValue(kEncodableMapkeyError), flutter::EncodableValue("Failed to set volume : " + std::to_string(result)));
    }
    else
    {
      messageResult.emplace(flutter::EncodableValue(kEncodableMapkeyResult), flutter::EncodableValue(volume));
    }
    reply(flutter::EncodableValue(result));
  }

  void PingPlugin::HandleDispose(
      const flutter::EncodableValue &message,
      flutter::MessageReply<flutter::EncodableValue> reply)
  {
    flutter::EncodableMap messageResult;
    ma_device_uninit(&device);
    ma_decoder_uninit(&decoder);
    messageResult.emplace(flutter::EncodableValue(kEncodableMapkeyResult), flutter::EncodableValue());
    reply(flutter::EncodableValue(result));
  }

  const std::string GetExecutableDirectory()
  {
    static char buf[1024] = {};
    readlink("/proc/self/exe", buf, sizeof(buf) - 1);

    std::string exe_path = std::string(buf);
    const int slash_pos = exe_path.find_last_of('/');
    return exe_path.substr(0, slash_pos);
  }

} // namespace

void PingPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar)
{
  PingPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrar>(registrar));
}