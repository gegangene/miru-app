import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:miru_app/controllers/watch/video_controller.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/views/widgets/cache_network_image.dart';
import 'package:miru_app/views/widgets/progress.dart';

class VideoPlayerMobileControls extends StatefulWidget {
  const VideoPlayerMobileControls({super.key, required this.controller});
  final VideoPlayerController controller;

  @override
  State<VideoPlayerMobileControls> createState() =>
      _VideoPlayerMobileControlsState();
}

class _VideoPlayerMobileControlsState extends State<VideoPlayerMobileControls> {
  late final VideoPlayerController _c = widget.controller;
  final _subtitleViewKey = GlobalKey<SubtitleViewState>();

  bool _showControls = true;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const SizedBox.expand(),
        Positioned.fill(
          child: Obx(
            () {
              final textStyle = TextStyle(
                height: 1.4,
                fontSize: _c.subtitleFontSize.value,
                letterSpacing: 0.0,
                wordSpacing: 0.0,
                color: _c.subtitleFontColor.value,
                fontWeight: _c.subtitleFontWeight.value,
                backgroundColor: _c.subtitleBackgroundColor.value,
              );
              _subtitleViewKey.currentState?.textAlign =
                  _c.subtitleTextAlign.value;
              _subtitleViewKey.currentState?.style = textStyle;
              _subtitleViewKey.currentState?.padding = EdgeInsets.fromLTRB(
                16.0,
                0.0,
                16.0,
                _showControls ? 100.0 : 16.0,
              );
              return SubtitleView(
                controller: _c.videoController,
                configuration: SubtitleViewConfiguration(
                  style: textStyle,
                  textAlign: _c.subtitleTextAlign.value,
                ),
                key: _subtitleViewKey,
              );
            },
          ),
        ),
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              setState(() {
                _showControls = !_showControls;
              });
            },
            onDoubleTap: () {
              if (_c.player.state.playing) {
                _c.player.pause();
              } else {
                _c.player.play();
              }
            },
            // 左右滑动
            onHorizontalDragUpdate: (details) {
              if (details.delta.dx > 0) {
                _c.player.seek(
                  _c.player.state.position + const Duration(seconds: 1),
                );
              } else {
                _c.player.seek(
                  _c.player.state.position - const Duration(seconds: 1),
                );
              }
            },
            child: const SizedBox.expand(),
          ),
        ),
        Positioned.fill(
          child: Center(
            child: Obx(() {
              if (_c.error.value.isNotEmpty) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Getting streamlink error",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FilledButton(
                          child: const Text('Error message'),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Error message'),
                                content: SelectableText(_c.error.value),
                                actions: [
                                  FilledButton(
                                    child: Text('common.close'.i18n),
                                    onPressed: () {
                                      Get.back();
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 10),
                        FilledButton(
                          child: Text('Retry'.i18n),
                          onPressed: () {
                            _c.error.value = '';
                            _c.play();
                          },
                        ),
                      ],
                    )
                  ],
                );
              }
              if (!_c.isGettingWatchData.value) {
                return StreamBuilder(
                  stream: _c.player.stream.buffering,
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data! ||
                        _c.player.state.buffering) {
                      return const ProgressRing();
                    }
                    return const SizedBox.shrink();
                  },
                );
              }
              return Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_c.runtime.extension.icon != null)
                        Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          clipBehavior: Clip.antiAlias,
                          margin: const EdgeInsets.only(right: 10),
                          child: CacheNetWorkImagePic(
                            _c.runtime.extension.icon!,
                            width: 30,
                            height: 30,
                          ),
                        ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _c.runtime.extension.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Getting streamlink...',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Opacity(
            opacity: _showControls ? 1.0 : 0.0,
            child: _Header(
              controller: _c,
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Opacity(
            opacity: _showControls ? 1.0 : 0.0,
            child: _Footer(controller: _c),
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.controller});
  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black,
            Colors.transparent,
          ],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Get.back();
            },
          ),
          Expanded(
            child: Obx(() {
              final data = controller.playList[controller.index.value];
              final episode = data.name;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    episode,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              );
            }),
          ),
          // 设置按钮
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              final show = controller.showSidebar.value;
              controller.showSidebar.value = !show;
            },
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.controller});
  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black54,
            Colors.transparent,
          ],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MaterialSeekBar(),
          const SizedBox(height: 10),
          Row(
            children: [
              Obx(
                () => IconButton(
                  icon: const Icon(Icons.skip_previous),
                  onPressed: controller.index.value > 0
                      ? () {
                          controller.index.value--;
                        }
                      : null,
                ),
              ),
              StreamBuilder(
                stream: controller.player.stream.playing,
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data!) {
                    return IconButton(
                      onPressed: controller.player.pause,
                      icon: const Icon(
                        Icons.pause,
                        size: 30,
                      ),
                    );
                  }
                  return IconButton(
                    onPressed: controller.player.play,
                    icon: const Icon(
                      Icons.play_arrow,
                      size: 30,
                    ),
                  );
                },
              ),
              Obx(
                () => IconButton(
                  icon: const Icon(Icons.skip_next),
                  onPressed:
                      controller.playList.length - 1 > controller.index.value
                          ? () {
                              controller.index.value++;
                            }
                          : null,
                ),
              ),
              // 播放进度
              StreamBuilder(
                stream: controller.player.stream.position,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final position = snapshot.data as Duration;
                    return Text(
                      '${position.inMinutes}:${position.inSeconds % 60}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              const Text('/'),
              StreamBuilder(
                stream: controller.player.stream.duration,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final duration = snapshot.data as Duration;
                    return Text(
                      '${duration.inMinutes}:${duration.inSeconds % 60}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
