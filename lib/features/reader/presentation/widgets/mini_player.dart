import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:just_audio/just_audio.dart';
import '../../../../core/audio/audio_player_manager.dart';
import '../../../../core/theme/app_colors.dart';

class MiniPlayer extends ConsumerWidget {
  final String audioUrl;
  final String chapterId;
  final String bookSlug;
  final String title;
  
  const MiniPlayer({
    super.key, 
    required this.audioUrl,
    required this.chapterId,
    required this.bookSlug,
    required this.title,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioManager = ref.watch(audioPlayerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Auto-start if it's not the current chapter
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (audioManager.currentChapterId != chapterId) {
        audioManager.playChapterAudio(audioUrl, chapterId, bookSlug, title: title);
      }
    });

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.accentLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.headphones, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Now Playing', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textMutedLight)),
                        Text(
                          title, 
                          maxLines: 1, 
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14, 
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.textDark : AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  StreamBuilder<PlayerState>(
                    stream: audioManager.player.playerStateStream,
                    builder: (context, snapshot) {
                      final state = snapshot.data;
                      final playing = state?.playing ?? false;
                      final processingState = state?.processingState;
                      
                      if (processingState == ProcessingState.loading || processingState == ProcessingState.buffering) {
                        return const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
                        );
                      }
                      
                      return IconButton(
                        icon: Icon(playing ? Icons.pause_circle_filled : Icons.play_circle_filled),
                        iconSize: 40,
                        color: Theme.of(context).colorScheme.primary,
                        onPressed: () {
                          if (playing) {
                            audioManager.pause();
                          } else {
                            audioManager.player.play();
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              StreamBuilder<Duration>(
                stream: audioManager.player.positionStream,
                builder: (context, positionSnapshot) {
                  return StreamBuilder<Duration?>(
                    stream: audioManager.player.durationStream,
                    builder: (context, durationSnapshot) {
                      final duration = durationSnapshot.data ?? Duration.zero;
                      final position = positionSnapshot.data ?? Duration.zero;
                      
                      return ProgressBar(
                        progress: position,
                        total: duration,
                        barHeight: 4,
                        baseBarColor: isDark ? AppColors.borderDark : AppColors.borderLight,
                        progressBarColor: Theme.of(context).colorScheme.primary,
                        thumbColor: Theme.of(context).colorScheme.primary,
                        thumbRadius: 6,
                        timeLabelTextStyle: TextStyle(
                          fontSize: 10,
                          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                        ),
                        onSeek: (duration) {
                          audioManager.seek(duration);
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
