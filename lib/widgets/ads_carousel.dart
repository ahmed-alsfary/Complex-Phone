import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_config.dart';
import '../core/l10n.dart';
import '../core/theme.dart';
import '../models/models.dart';
import '../providers/settings_provider.dart';
import '../services/complex_ad_service.dart';

class AdsCarousel extends StatefulWidget {
  const AdsCarousel({super.key, this.complexId});

  final String? complexId;

  @override
  State<AdsCarousel> createState() => _AdsCarouselState();
}

class _AdsCarouselState extends State<AdsCarousel> {
  PageController? _pageController;
  List<ComplexAd> _ads = [];
  bool _loading = true;
  int _index = 0;
  Timer? _timer;
  bool _userDragging = false;

  /// نقطة بداية كبيرة لتكرار لا نهائي في الاتجاهين.
  static const int _loopOffset = 5000;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController?.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final ads = await context.read<ComplexAdService>().getActive(
            complexId: widget.complexId,
          );
      if (!mounted) return;
      _timer?.cancel();
      _pageController?.dispose();
      _pageController = null;

      if (ads.isEmpty) {
        setState(() {
          _ads = [];
          _loading = false;
          _index = 0;
        });
        return;
      }

      final initial = ads.length == 1 ? 0 : _loopOffset;
      _pageController = PageController(
        viewportFraction: 0.92,
        initialPage: initial,
      );
      setState(() {
        _ads = ads;
        _loading = false;
        _index = 0;
      });
      // انتظر بناء PageView ثم شغّل التمرير التلقائي
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _restartTimer();
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _ads = [];
        _loading = false;
      });
    }
  }

  void _restartTimer() {
    _timer?.cancel();
    if (_ads.isEmpty || _pageController == null) return;

    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted || _userDragging) return;
      final controller = _pageController;
      if (controller == null || !controller.hasClients) return;

      final current = controller.page?.round() ?? controller.initialPage;
      controller.animateToPage(
        current + 1,
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  int _realIndex(int page) {
    if (_ads.isEmpty) return 0;
    return page % _ads.length;
  }

  String _abs(String path) {
    if (path.startsWith('http')) return path;
    return '${AppConfig.apiBaseUrl}$path';
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>().s;
    if (_loading) {
      return const SizedBox(
        height: 160,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    if (_ads.isEmpty || _pageController == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.ads,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 168,
          child: NotificationListener<ScrollNotification>(
            onNotification: (n) {
              if (n is ScrollStartNotification && n.dragDetails != null) {
                _userDragging = true;
                _timer?.cancel();
              } else if (n is ScrollEndNotification) {
                _userDragging = false;
                _restartTimer();
              }
              return false;
            },
            child: PageView.builder(
              controller: _pageController,
              // itemCount: null → تمرير وتكرار لا نهائي
              onPageChanged: (page) {
                setState(() => _index = _realIndex(page));
              },
              itemBuilder: (context, page) {
                final ad = _ads[_realIndex(page)];
                final title =
                    ad.localizedTitle(context.read<SettingsProvider>().lang.code);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          _abs(ad.imageUrl),
                          fit: BoxFit.cover,
                          errorBuilder: (_, error, stack) => Container(
                            color: AppTheme.brandSoft,
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.campaign_outlined,
                              color: AppTheme.brandMid,
                            ),
                          ),
                        ),
                        if (title.isNotEmpty)
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(14, 28, 14, 12),
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.transparent, Colors.black54],
                                ),
                              ),
                              child: Text(
                                title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        if (_ads.length > 1) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_ads.length, (i) {
              final active = i == _index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: active ? 16 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color: active ? AppTheme.brandMid : AppTheme.border,
                  borderRadius: BorderRadius.circular(99),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}
