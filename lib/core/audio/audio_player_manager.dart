import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import '../network/api_config.dart';

final audioPlayerProvider = Provider<AudioPlayerManager>((ref) {
  final manager = AudioPlayerManager();
  ref.onDispose(() => manager.dispose());
  return manager;
});

class AudioPlayerManager {
  final AudioPlayer player;
  String? currentChapterId;
  String? currentBookSlug;

  AudioPlayerManager() : player = AudioPlayer() {
    _initSession();
  }

  Future<void> _initSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
  }

  Future<void> playChapterAudio(String audioUrl, String chapterId, String bookSlug, {String? title, String? author, String? coverUrl}) async {
    if (currentChapterId == chapterId) {
      if (!player.playing) {
        await player.play();
      }
      return;
    }

    try {
      currentChapterId = chapterId;
      currentBookSlug = bookSlug;
      
      String fullUrl = audioUrl;
      if (!fullUrl.startsWith('http')) {
        fullUrl = '${ApiConfig.baseUrl}$fullUrl';
      }
      
      await player.setAudioSource(
        AudioSource.uri(
          Uri.parse(fullUrl),
          // We can add MediaItem here later for lock screen controls using audio_service
        ),
      );
      
      await player.play();
    } catch (e) {
      debugPrint("Error loading audio: $e");
    }
  }

  Future<void> pause() async {
    await player.pause();
  }

  Future<void> stop() async {
    await player.stop();
    currentChapterId = null;
  }

  Future<void> seek(Duration position) async {
    await player.seek(position);
  }

  void dispose() {
    player.dispose();
  }
}
