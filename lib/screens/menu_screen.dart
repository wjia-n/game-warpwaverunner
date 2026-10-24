// DISTINCT ROLLOUT V5 — warpwaverunner: "Logo-top pills + footer strip"
// Layout template from distinct-samples/poprocketrun.
import 'package:flutter/material.dart';
import '../theme/arcade_config.dart';
import '../engine/arcade_engine.dart';
import '../services/settings_service.dart';
import '../services/sound_service.dart';
import 'game_screen.dart';
import 'settings_screen.dart';
import 'support_screen.dart';

const List<String> _emojiFb = ['Noto Color Emoji'];

class MenuScreen extends StatefulWidget {
  final ArcadeConfig config;
  const MenuScreen({super.key, required this.config});
  @override State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  int highScore = 0;
  String playerName = 'Player 1';

  @override void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final svc = SettingsService('${widget.config.slug}_');
    final h = await svc.getHighScore();
    final n = await svc.getPlayerName();
    if (mounted) setState(() { highScore = h; playerName = n; });
  }

  void _play() async {
    final svc = SettingsService('${widget.config.slug}_');
    final diff = await svc.getDifficulty();
    final shape = await svc.getShape();
    final mul = [0.8, 1.0, 1.3][diff.clamp(0, 2)];
    final sound = SoundService('${widget.config.slug}_');
    await sound.load();
    await sound.click();
    if (!mounted) return;
    Navigator.push(context, MaterialPageRoute(builder: (_) => GameScreen(
      config: widget.config,
      engine: ArcadeEngine(cfg: widget.config, diffMul: mul),
      sound: sound,
      shape: shape,
    ))).then((_) => _load());
  }

  @override Widget build(BuildContext context) {
    final c = widget.config;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [c.darkColor, c.primaryColor.withOpacity(0.5)])),
        child: SafeArea(child: Column(children: [
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 8),
            child: Column(children: [
              Text(c.playerEmoji, textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 88, fontFamilyFallback: _emojiFb)),
              const SizedBox(height: 14),
              Text(c.displayName.toUpperCase(), textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: 2.0, fontFamilyFallback: _emojiFb)),
              const SizedBox(height: 6),
              Text(c.tagline, textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 14, fontFamilyFallback: _emojiFb)),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  border: Border.all(color: c.accentColor.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('🏆 $playerName — Best: $highScore',
                    style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontFamilyFallback: _emojiFb)),
              ),
              const SizedBox(height: 26),
              FractionallySizedBox(widthFactor: 0.78, child: Column(children: [
                _pillBtn('▶  PLAY', c.accentColor, Colors.black, null, _play),
                _pillBtn('❓  HOW TO PLAY', Colors.white10, Colors.white,
                    BorderSide(color: c.accentColor, width: 2), () => _howTo(context, c)),
                _pillBtn('⚙️  SETTINGS', Colors.white10, Colors.white,
                    BorderSide(color: c.accentColor, width: 2), () {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (_) => SettingsScreen(config: c))).then((_) => _load());
                }),
                _pillBtn('💛  SUPPORT', Colors.white10, Colors.white,
                    BorderSide(color: c.accentColor, width: 2), () {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (_) => SupportScreen(config: c)));
                }),
              ])),
            ]))),
          Container(
            height: 64, width: double.infinity,
            color: c.primaryColor.withOpacity(0.3),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('Credits: WAJIHA', style: TextStyle(color: Colors.white38, fontSize: 12, fontFamilyFallback: _emojiFb)),
              const Text('   •   ', style: TextStyle(color: Colors.white38, fontSize: 12, fontFamilyFallback: _emojiFb)),
              Text('${c.playerEmoji} ${c.collectEmoji} ${c.bgEmoji}',
                  style: const TextStyle(fontSize: 16, fontFamilyFallback: _emojiFb)),
            ]),
          ),
        ]))),
      );
  }

  void _howTo(BuildContext ctx, ArcadeConfig c) {
    showDialog(context: ctx, builder: (_) => AlertDialog(
      backgroundColor: c.darkColor,
      title: Text(c.displayName, style: const TextStyle(color: Colors.white, fontFamilyFallback: _emojiFb)),
      content: Text(c.howTo, style: const TextStyle(color: Colors.white70, fontFamilyFallback: _emojiFb)),
      actions: [TextButton(
        onPressed: () => Navigator.pop(ctx),
        child: Text('GOT IT', style: TextStyle(color: c.accentColor, fontFamilyFallback: _emojiFb)))],
    ));
  }

  Widget _pillBtn(String label, Color bg, Color fg, BorderSide? side, VoidCallback onTap) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: SizedBox(width: double.infinity, child: ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: bg, foregroundColor: fg,
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: side,
        shape: const StadiumBorder()),
      onPressed: onTap, child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamilyFallback: _emojiFb)))),
  );
}
