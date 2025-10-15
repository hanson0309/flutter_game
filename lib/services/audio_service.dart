import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioService extends ChangeNotifier {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  AudioPlayer? _musicPlayer;
  AudioPlayer? _sfxPlayer;
  
  bool _isMusicEnabled = true;
  bool _isSfxEnabled = true;
  double _musicVolume = 0.5;
  double _sfxVolume = 0.7;
  
  String? _currentBackgroundMusic;
  bool _hasUserInteracted = false;
  
  bool get isMusicEnabled => _isMusicEnabled;
  bool get hasUserInteracted => _hasUserInteracted;
  bool get isSfxEnabled => _isSfxEnabled;
  double get musicVolume => _musicVolume;
  double get sfxVolume => _sfxVolume;

  // 初始化音效系统
  Future<void> initialize() async {
    try {
      debugPrint('🔊 开始初始化音效系统...');
      _musicPlayer = AudioPlayer();
      _sfxPlayer = AudioPlayer();
      
      // 设置音乐播放器为循环播放
      _musicPlayer?.setVolume(_musicVolume);
      _sfxPlayer?.setVolume(_sfxVolume);
      _musicPlayer?.setReleaseMode(ReleaseMode.loop);
      _sfxPlayer?.setReleaseMode(ReleaseMode.stop);
      
      await _loadSettings();
      await _updateVolumes();
      
      debugPrint('🔊 音效系统初始化完成');
      debugPrint('🔊 音乐开关: $_isMusicEnabled, 音效开关: $_isSfxEnabled');
      debugPrint('🔊 音乐音量: $_musicVolume, 音效音量: $_sfxVolume');
      debugPrint('🔊 等待用户交互后播放音乐...');
      
      // 不在初始化时自动播放，等待用户交互
    } catch (e) {
      debugPrint('🔊 音效系统初始化失败: $e');
    }
  }

  // 播放背景音乐
  Future<void> playBackgroundMusic(String musicPath) async {
    if (!_isMusicEnabled) {
      debugPrint('🎵 音乐已关闭，跳过播放: $musicPath');
      return;
    }
    
    try {
      if (_currentBackgroundMusic != musicPath) {
        await _musicPlayer?.stop();
        await _musicPlayer?.play(AssetSource(musicPath));
        _currentBackgroundMusic = musicPath;
        _hasUserInteracted = true; // 标记用户已交互
        debugPrint('🎵 播放背景音乐: $musicPath');
      }
    } catch (e) {
      debugPrint('🎵 播放背景音乐失败: $musicPath - $e');
      if (e.toString().contains('NotAllowedError')) {
        debugPrint('🎵 需要用户交互才能播放音乐，请点击音乐按钮启动');
      }
      // Web平台音乐播放失败时的静默处理，不影响游戏体验
    }
  }

  // 停止背景音乐
  Future<void> stopBackgroundMusic() async {
    try {
      await _musicPlayer?.stop();
      _currentBackgroundMusic = null;
      debugPrint('🎵 停止背景音乐');
    } catch (e) {
      debugPrint('停止背景音乐失败: $e');
    }
  }

  // 播放音效
  Future<void> playSfx(String sfxPath) async {
    if (!_isSfxEnabled || _sfxPlayer == null) return;
    
    try {
      await _sfxPlayer!.play(AssetSource(sfxPath));
      _hasUserInteracted = true; // 标记用户已交互
      debugPrint('🔊 播放音效: $sfxPath');
    } catch (e) {
      debugPrint('🔊 播放音效失败: $sfxPath - $e');
      // Web平台音效播放失败时的静默处理，不影响游戏体验
    }
  }

  // 预定义的音效方法
  Future<void> playClickSound() async {
    await playSfx('audio/sfx/click.mp3');
  }

  Future<void> playLevelUpSound() async {
    await playSfx('audio/sfx/levelup.mp3');
  }

  Future<void> playAchievementSound() async {
    await playSfx('audio/sfx/achievement.mp3');
  }

  Future<void> playEquipSound() async {
    await playSfx('audio/sfx/equip.mp3');
  }

  Future<void> playEnhanceSuccessSound() async {
    await playSfx('audio/sfx/enhance_success.mp3');
  }

  Future<void> playEnhanceFailSound() async {
    await playSfx('audio/sfx/enhance_fail.mp3');
  }

  Future<void> playBattleStartSound() async {
    await playSfx('audio/sfx/battle_start.mp3');
  }

  Future<void> playVictorySound() async {
    await playSfx('audio/sfx/victory.mp3');
  }

  Future<void> playDefeatSound() async {
    await playSfx('audio/sfx/defeat.mp3');
  }

  Future<void> playCoinsSound() async {
    await playSfx('audio/sfx/coins.mp3');
  }

  // 预定义的背景音乐方法
  Future<void> playMainMenuMusic() async {
    await playBackgroundMusic('audio/music/main_menu.mp3');
  }

  Future<void> playGameplayMusic() async {
    await playBackgroundMusic('audio/music/gameplay.mp3');
  }

  Future<void> playBattleMusic() async {
    await playBackgroundMusic('audio/music/battle.mp3');
  }

  // 设置音乐开关
  Future<void> setMusicEnabled(bool enabled) async {
    _isMusicEnabled = enabled;
    
    if (!enabled) {
      await stopBackgroundMusic();
    }
    
    await _saveSettings();
    notifyListeners();
  }

  // 设置音效开关
  Future<void> setSfxEnabled(bool enabled) async {
    _isSfxEnabled = enabled;
    await _saveSettings();
    notifyListeners();
  }

  // 设置音乐音量
  Future<void> setMusicVolume(double volume) async {
    _musicVolume = volume.clamp(0.0, 1.0);
    await _updateVolumes();
    await _saveSettings();
    notifyListeners();
  }

  // 设置音效音量
  Future<void> setSfxVolume(double volume) async {
    _sfxVolume = volume.clamp(0.0, 1.0);
    await _updateVolumes();
    await _saveSettings();
    notifyListeners();
  }

  // 更新音量设置
  Future<void> _updateVolumes() async {
    try {
      await _musicPlayer?.setVolume(_isMusicEnabled ? _musicVolume : 0.0);
      await _sfxPlayer?.setVolume(_isSfxEnabled ? _sfxVolume : 0.0);
    } catch (e) {
      debugPrint('更新音量失败: $e');
    }
  }

  // 保存设置
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('music_enabled', _isMusicEnabled);
      await prefs.setBool('sfx_enabled', _isSfxEnabled);
      await prefs.setDouble('music_volume', _musicVolume);
      await prefs.setDouble('sfx_volume', _sfxVolume);
    } catch (e) {
      debugPrint('保存音效设置失败: $e');
    }
  }

  // 加载设置
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isMusicEnabled = prefs.getBool('music_enabled') ?? true;
      _isSfxEnabled = prefs.getBool('sfx_enabled') ?? true;
      _musicVolume = prefs.getDouble('music_volume') ?? 0.5;
      _sfxVolume = prefs.getDouble('sfx_volume') ?? 0.7;
    } catch (e) {
      debugPrint('加载音效设置失败: $e');
    }
  }

  // 释放资源
  Future<void> dispose() async {
    try {
      _musicPlayer?.dispose();
      _sfxPlayer?.dispose();
    } catch (e) {
      debugPrint('释放音效资源失败: $e');
    }
    super.dispose();
  }

  // 暂停音乐（用于应用进入后台时）
  Future<void> pauseMusic() async {
    try {
      await _musicPlayer?.pause();
    } catch (e) {
      debugPrint('暂停音乐失败: $e');
    }
  }

  // 恢复音乐（用于应用回到前台时）
  Future<void> resumeMusic() async {
    if (!_isMusicEnabled) return;
    
    try {
      await _musicPlayer?.resume();
    } catch (e) {
      debugPrint('恢复音乐失败: $e');
    }
  }

  // 获取当前播放状态
  bool get isMusicPlaying {
    return _musicPlayer?.state == PlayerState.playing ?? false;
  }

  // 切换音乐开关
  Future<void> toggleMusic() async {
    await setMusicEnabled(!_isMusicEnabled);
  }

  // 切换音效开关
  Future<void> toggleSfx() async {
    await setSfxEnabled(!_isSfxEnabled);
  }
}
