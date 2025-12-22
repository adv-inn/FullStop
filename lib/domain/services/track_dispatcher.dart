import 'dart:math';
import '../entities/track.dart';

/// Dispatch mode for traditional (non-BPM, non-LLM) scheduling
enum DispatchMode {
  /// Hits Only - 仅限金曲
  /// deepCutRatio: 0.0, 全是热门歌曲
  hitsOnly,

  /// Balanced - 经典平衡 (默认推荐)
  /// deepCutRatio: 0.3, 主要是金曲，偶尔穿插冷门佳作
  balanced,

  /// Deep Dive - 深度挖掘
  /// deepCutRatio: 0.7, 大量 B-Side，偶尔来首热歌提神
  deepDive,

  /// Unfiltered - 原汁原味
  /// 不去重，直接全量 Shuffle，包含 Live、Remix 版本
  unfiltered,
}

extension DispatchModeExtension on DispatchMode {
  /// Get the deep cut ratio for this mode
  double get deepCutRatio {
    switch (this) {
      case DispatchMode.hitsOnly:
        return 0.0;
      case DispatchMode.balanced:
        return 0.3;
      case DispatchMode.deepDive:
        return 0.7;
      case DispatchMode.unfiltered:
        return 0.5; // Not used, but provide a default
    }
  }

  /// Get the display name for this mode
  String get displayName {
    switch (this) {
      case DispatchMode.hitsOnly:
        return 'Hits Only';
      case DispatchMode.balanced:
        return 'Balanced';
      case DispatchMode.deepDive:
        return 'Deep Dive';
      case DispatchMode.unfiltered:
        return 'Unfiltered';
    }
  }

  /// Get the description for this mode
  String get description {
    switch (this) {
      case DispatchMode.hitsOnly:
        return '仅限金曲，全是热门歌曲';
      case DispatchMode.balanced:
        return '经典平衡，金曲为主偶尔穿插冷门佳作';
      case DispatchMode.deepDive:
        return '深度挖掘，大量 B-Side 偶尔热歌提神';
      case DispatchMode.unfiltered:
        return '原汁原味，包含 Live、Remix 等所有版本';
    }
  }

  /// Get the icon for this mode
  String get iconName {
    switch (this) {
      case DispatchMode.hitsOnly:
        return 'star';
      case DispatchMode.balanced:
        return 'tune';
      case DispatchMode.deepDive:
        return 'explore';
      case DispatchMode.unfiltered:
        return 'all_inclusive';
    }
  }
}

// ============================================================================
// Track Scorer - 版本质量评分器
// ============================================================================

/// Track Scorer - 为去重时选择"最佳版本"提供加权评分
///
/// 解决的问题：
/// 1. Bad Versions Win: 高人气的 "Club Remix" 挤掉原版
/// 2. Artist Rights Loss: Taylor's Version 或 "重生" 版人气较低被丢弃
///
/// 评分策略：
/// - 基础分 = track.popularity
/// - 惩罚项 (Kill List): Remix, Club, Dance, Sped Up, Instrumental, Karaoke, 伴奏
/// - 加分项 (Owner List): 重生, Taylor's Version, Re-recorded
/// - 微调项: Remaster, Deluxe
class TrackScorer {
  /// 计算曲目的综合评分
  static int getScore(Track track) {
    int score = track.popularity;
    final name = track.name.toLowerCase();

    // 1. 惩罚项 - 干扰版本 (扣 50 分)
    // 这些版本通常会破坏专注/陪伴的听感
    if (_containsDistraction(name)) {
      score -= 50;
    }

    // 2. 大加分 - 艺人主权版本 (加 100 分)
    // 优先选择艺人重新录制的版本，尊重艺人意愿
    if (_containsArtistPreferred(name)) {
      score += 100;
    }

    // 3. 小加分 - 质量提升版本 (加 10 分)
    // Remaster/Deluxe 通常音质更好
    if (_containsQualityBonus(name)) {
      score += 10;
    }

    return score;
  }

  /// 检查曲目是否为干扰版本（Remix、伴奏、Club Mix 等）
  ///
  /// 用于过滤掉不需要的曲目版本
  static bool isDistraction(Track track) {
    return _containsDistraction(track.name.toLowerCase());
  }

  /// 检查是否包含干扰关键词 (Kill List)
  static bool _containsDistraction(String name) {
    const distractions = [
      'remix',
      'club',
      'dance mix',
      'sped up',
      'slowed',
      'nightcore',
      'instrumental',
      'karaoke',
      'cover',
      '伴奏',
      '纯音乐',
      // TikTok 相关
      'tiktok',
      'douyin',
      '抖音',
    ];

    for (final keyword in distractions) {
      if (name.contains(keyword)) {
        return true;
      }
    }
    return false;
  }

  /// 检查是否包含艺人主权关键词 (Owner List)
  static bool _containsArtistPreferred(String name) {
    const artistPreferred = [
      '重生', // G.E.M. 重录版
      "taylor's version", // Taylor Swift 重录版
      're-recorded',
      're-record',
    ];

    for (final keyword in artistPreferred) {
      if (name.contains(keyword)) {
        return true;
      }
    }
    return false;
  }

  /// 检查是否包含质量提升关键词
  static bool _containsQualityBonus(String name) {
    const qualityBonus = [
      'remaster',
      'deluxe',
      'anniversary',
      'special edition',
    ];

    for (final keyword in qualityBonus) {
      if (name.contains(keyword)) {
        return true;
      }
    }
    return false;
  }
}

// ============================================================================
// True Shuffle Pipeline - 通用后处理管道
// ============================================================================

/// True Shuffle Pipeline - 解决 "Spotify Shuffle Sucks" 问题
///
/// 这是一个通用的后处理管道，适用于所有调度模式：
/// - 传统调度 (Traditional): 专辑隔离，解决原版 Shuffle 的问题
/// - 智能调度 (Smart/BPM): 打散年代和风格，避免听感疲劳
/// - Agent 调度 (AI): 注入"人性"，让推荐更像 DJ 编排
///
/// Pipeline 步骤:
/// 1. Spread Shuffle (专辑隔离洗牌) - 避免连续播放同专辑歌曲
///
/// 注意：去重逻辑已前移到 Pre-Dedupe 阶段（选品前执行），
/// 避免"选 50 首 → 去重变 44 首"的数量损失问题
class TrueShufflePipeline {
  final List<Track> _tracks;
  final Random _random;

  TrueShufflePipeline(List<Track> tracks, {Random? random})
    : _tracks = List.from(tracks),
      _random = random ?? Random();

  /// 获取当前曲目数量
  int get trackCount => _tracks.length;

  /// 执行完整的 True Shuffle 管道（专辑隔离洗牌）
  ///
  /// 注意：去重已前移到 Pre-Dedupe 阶段，这里只做专辑隔离
  List<Track> execute() {
    if (_tracks.isEmpty) return [];
    return _spreadShuffle(List.from(_tracks));
  }

  /// 专辑隔离洗牌 - 避免连续播放同一张专辑的歌曲
  List<Track> _spreadShuffle(List<Track> tracks) {
    if (tracks.isEmpty) return [];

    // Step 1: 按专辑分桶并打乱
    final buckets = _createShuffledAlbumBuckets(tracks);

    // Step 2: 轮询抽取 (Round Robin)
    return _roundRobinExtract(buckets, tracks.length);
  }

  /// 按专辑分桶，桶内和桶间都打乱
  List<List<Track>> _createShuffledAlbumBuckets(List<Track> tracks) {
    final albumMap = <String, List<Track>>{};

    for (final track in tracks) {
      albumMap.putIfAbsent(track.albumId, () => []).add(track);
    }

    // 桶内打乱 & 桶间打乱
    final buckets = albumMap.values.toList();
    for (final bucket in buckets) {
      bucket.shuffle(_random);
    }
    buckets.shuffle(_random);

    return buckets;
  }

  /// 轮询抽取保证专辑隔离
  List<Track> _roundRobinExtract(List<List<Track>> buckets, int targetCount) {
    final result = <Track>[];

    while (result.length < targetCount) {
      var addedAny = false;

      for (final bucket in buckets) {
        if (bucket.isNotEmpty) {
          result.add(bucket.removeLast());
          addedAny = true;
        }
      }

      if (!addedAny) break;
    }

    return result;
  }

  /// 静态便捷方法：对任意曲目列表执行 True Shuffle（专辑隔离洗牌）
  ///
  /// [skipDedupe] 已废弃，保留仅为向后兼容，实际不再使用
  static List<Track> shuffle(
    List<Track> tracks, {
    @Deprecated('Dedupe is now handled in Pre-Dedupe phase')
    bool skipDedupe = false,
    Random? random,
  }) {
    return TrueShufflePipeline(tracks, random: random).execute();
  }

  /// Pre-Dedupe: 在选品前对原始曲目池进行智能去重
  ///
  /// 这是管道重排的核心改进：
  /// - 旧流程: Raw → Selection(50) → Dedupe → 可能只剩 44 首
  /// - 新流程: Raw → Pre-Dedupe → Selection(55) → Shuffle → Trim(50) → 保证 50 首
  ///
  /// 返回去重后的纯净曲目池
  static List<Track> preDedupe(List<Track> tracks) {
    if (tracks.isEmpty) return [];
    return _dedupeByName(tracks);
  }

  /// 智能去重逻辑：按归一化歌名去重，使用 TrackScorer 选择最佳版本
  ///
  /// 使用加权评分而非单纯热度，解决两个问题：
  /// 1. Bad Versions Win: 高人气 Remix 挤掉原版
  /// 2. Artist Rights Loss: Taylor's Version 等重录版人气较低被丢弃
  ///
  /// 此方法被 TrueShufflePipeline.preDedupe 和 MultiArtistPipeline 共用
  ///
  /// 注意：去重后会再过滤掉干扰版本（Remix、伴奏等），
  /// 确保最终结果不包含这些版本（即使它们是唯一版本）
  static List<Track> _dedupeByName(List<Track> tracks) {
    final uniqueMap = <String, Track>{};
    final scoreMap = <String, int>{}; // 缓存分数避免重复计算

    for (var track in tracks) {
      final cleanName = normalizeTrackName(track.name);
      final score = TrackScorer.getScore(track);

      if (!uniqueMap.containsKey(cleanName)) {
        uniqueMap[cleanName] = track;
        scoreMap[cleanName] = score;
      } else {
        // 使用 TrackScorer 评分决定最佳版本
        if (score > scoreMap[cleanName]!) {
          uniqueMap[cleanName] = track;
          scoreMap[cleanName] = score;
        }
      }
    }

    // 过滤掉仍然是干扰版本的曲目
    // 如果选出的"最佳版本"仍是 Remix/伴奏等，说明没有原版可选，直接排除
    return uniqueMap.values
        .where((track) => !TrackScorer.isDistraction(track))
        .toList();
  }

  /// 归一化歌名 - 去除 Live、Remix、Acoustic 等后缀
  ///
  /// 用于智能去重，将同一首歌的不同版本识别为同一首
  /// 例如: "First Love (Live)" → "first love"
  /// 例如: "倒流时间（伴奏）" → "倒流时间"
  static String normalizeTrackName(String name) {
    return name
        .replaceAll(RegExp(r'\s*\([^)]*\)\s*'), '') // (Live), (Remix)
        .replaceAll(RegExp(r'\s*（[^）]*）\s*'), '') // 中文全角括号（伴奏）
        .replaceAll(RegExp(r'\s*\[[^\]]*\]\s*'), '') // [Live], [Remix]
        .replaceAll(RegExp(r'\s*【[^】]*】\s*'), '') // 中文方括号【Live】
        .replaceAll(
          RegExp(
            // 匹配破折号后的修饰词，如 "- Dance Remix", "- Club Mix"
            r'\s*[-–—]\s*(\w+\s+)?(Live|Remix|Acoustic|Instrumental|Radio|Edit|Version|Ver\.|Mix|Remaster|Remastered|Extended|Original|Demo|Bonus|Deluxe).*',
            caseSensitive: false,
          ),
          '',
        )
        .trim()
        .toLowerCase();
  }
}

// ============================================================================
// Track Dispatcher - 传统调度的选品逻辑
// ============================================================================

/// Track Dispatcher - 传统调度的选品器
///
/// 职责：根据热度比例选出候选曲目 (Selection)
/// 注意：这只负责"选品"，最终排列由 TrueShufflePipeline 负责
///
/// 双重保险机制:
/// 1. Dynamic Median Threshold - 动态中位数阈值，根据歌手实际热度分布分桶
/// 2. Aggressive Backfill - 强力回填，只要库存够就必须给满目标数量
class TrackDispatcher {
  List<Track> _tracks;
  final Random _random;

  TrackDispatcher(List<Track> tracks, {Random? random})
    : _tracks = List.from(tracks),
      _random = random ?? Random();

  /// 获取当前曲目数量
  int get trackCount => _tracks.length;

  /// 获取当前曲目列表（不执行 shuffle）
  List<Track> get tracks => List.from(_tracks);

  /// 计算曲目列表的热度中位数
  ///
  /// 动态阈值策略：不使用固定的 50 分阈值，而是根据歌手实际热度分布
  /// - 宇多田光：中位数可能是 35，>35 算热门
  /// - 邓紫棋：中位数可能是 60，>60 才算热门
  /// 这样保证 Hot/Deep 两个池子始终接近 50:50 平分
  static int calculateMedianPopularity(List<Track> tracks) {
    if (tracks.isEmpty) return 50; // 默认回退值
    if (tracks.length < 10) return 50; // 样本太小，使用默认值

    final popularities = tracks.map((t) => t.popularity).toList()..sort();
    return popularities[popularities.length ~/ 2];
  }

  /// Sandwich Selection (配比选品) with Dynamic Threshold + Aggressive Backfill
  ///
  /// 双重保险机制：
  /// 1. 动态中位数阈值 - 根据歌手热度分布自适应分桶
  /// 2. 强力回填 - 只要库存够，必须给满目标数量
  ///
  /// [deepCutRatio] 0.0 - 1.0, 代表冷门歌占比
  /// [totalCount] 最终需要的歌曲数量，null 表示不限制
  TrackDispatcher sandwichSelect(double deepCutRatio, {int? totalCount}) {
    final targetTotal = totalCount ?? _tracks.length;
    if (_tracks.isEmpty || targetTotal <= 0) {
      _tracks = [];
      return this;
    }

    // 1. 动态阈值：计算中位数作为热门/冷门分界线
    final medianPopularity = calculateMedianPopularity(_tracks);

    // 2. 分桶（使用动态阈值）
    final hotPool = _tracks
        .where((t) => t.popularity >= medianPopularity)
        .toList();
    final deepPool = _tracks
        .where((t) => t.popularity < medianPopularity)
        .toList();

    // 3. 打乱两个池子
    hotPool.shuffle(_random);
    deepPool.shuffle(_random);

    // 4. 计算理想配额
    final targetDeep = (targetTotal * deepCutRatio).round();
    final targetHot = targetTotal - targetDeep;

    // 5. Phase 1: 按理想比例取歌
    final takenHot = hotPool.take(targetHot).toList();
    final takenDeep = deepPool.take(targetDeep).toList();

    final selected = <Track>[...takenHot, ...takenDeep];

    // 6. Phase 2: 强力回填 (Aggressive Backfill)
    // 如果还没凑够目标，从剩余的所有歌里继续填
    if (selected.length < targetTotal) {
      final deficit = targetTotal - selected.length;

      // 收集所有剩余的歌（不管热度）
      final leftovers = <Track>[
        ...hotPool.skip(takenHot.length),
        ...deepPool.skip(takenDeep.length),
      ];

      leftovers.shuffle(_random);

      // 填满缺口
      selected.addAll(leftovers.take(deficit));
    }

    _tracks = selected;
    return this;
  }

  /// 限制曲目数量
  TrackDispatcher limit(int? count) {
    if (count != null && count < _tracks.length) {
      _tracks.shuffle(_random);
      _tracks = _tracks.take(count).toList();
    }
    return this;
  }

  /// 执行传统调度的完整流程
  ///
  /// 两阶段架构:
  /// 1. Selection (选品): 根据 DispatchMode 选出候选曲目
  /// 2. Rendering (渲染): 通过 TrueShufflePipeline 进行专辑隔离洗牌
  ///
  /// [trueShuffle] 是否启用 True Shuffle 后处理（默认启用）
  static List<Track> dispatch(
    List<Track> tracks,
    DispatchMode mode, {
    int? trackLimit,
    bool trueShuffle = true,
  }) {
    // === 第一阶段：选品 (Selection) ===
    final List<Track> candidates;

    if (mode == DispatchMode.unfiltered) {
      // Unfiltered 模式：不按比例选，直接全量随机抽取
      candidates = TrackDispatcher(tracks).limit(trackLimit).tracks;
    } else {
      // 其他模式：使用 deepCutRatio 进行配比选品
      candidates = TrackDispatcher(
        tracks,
      ).sandwichSelect(mode.deepCutRatio, totalCount: trackLimit).tracks;
    }

    // === 第二阶段：渲染 (Rendering) - True Shuffle ===
    if (trueShuffle) {
      return TrueShufflePipeline.shuffle(candidates);
    }

    // 如果不启用 True Shuffle，简单 shuffle 后返回
    candidates.shuffle();
    return candidates;
  }
}

// ============================================================================
// Multi-Artist Fair Share Pipeline - 多歌手公平分配
// ============================================================================

/// Multi-Artist Fair Share Pipeline
///
/// 解决多歌手模式下的两个问题：
/// 1. 数量分布不均：热门歌手可能挤压其他人的空间
/// 2. 总量不够：去重后可能凑不够目标数量
///
/// 策略：独立清洗 + 轮询抽取 (Fair Share + Dynamic Backfill)
///
/// 使用场景：
/// - 用户选择多个歌手（如 G.E.M. + 邓丽君 + 陶喆）创建会话
/// - 需要保证每个歌手都有公平的曝光机会
/// - 同时确保能凑够目标数量
class MultiArtistPipeline {
  final Random _random;

  MultiArtistPipeline({Random? random}) : _random = random ?? Random();

  /// 从多个歌手的曲目池中公平混合
  ///
  /// [artistTrackPools] Map<artistId, List<Track>> - 每个歌手的原始曲目
  /// [targetCount] 目标曲目数量
  /// [mode] 调度模式
  /// [skipDedupe] 是否跳过去重（用于 Unfiltered 模式）
  ///
  /// 返回公平混合后的曲目列表
  List<Track> fairMix({
    required Map<String, List<Track>> artistTrackPools,
    required int targetCount,
    required DispatchMode mode,
    bool skipDedupe = false,
  }) {
    if (artistTrackPools.isEmpty) return [];

    // Step 1: 独立清洗每个歌手的池子
    final cleanPools = _prepareArtistPools(
      artistTrackPools,
      mode,
      targetCount,
      skipDedupe,
    );

    // Step 2: 公平混合 (Round Robin)
    return _roundRobinMix(cleanPools, targetCount);
  }

  /// Step 1: 准备每个歌手的曲目池（去重 + 选品 + 打乱）
  List<List<Track>> _prepareArtistPools(
    Map<String, List<Track>> artistTrackPools,
    DispatchMode mode,
    int targetCount,
    bool skipDedupe,
  ) {
    return artistTrackPools.values.map((tracks) {
      var pool = List<Track>.from(tracks);

      // 去重（除非是 Unfiltered 模式）
      if (!skipDedupe) {
        pool = TrueShufflePipeline.preDedupe(pool);
      }

      // 按调度模式进行选品
      pool = _selectByMode(pool, mode, targetCount, artistTrackPools.length);

      // 打乱顺序
      pool.shuffle(_random);

      return pool;
    }).toList();
  }

  /// Step 2: 轮询抽取实现公平混合 + 全局回填
  List<Track> _roundRobinMix(List<List<Track>> pools, int targetCount) {
    final result = <Track>[];

    // Phase 1: 公平轮询（Round Robin）
    while (result.length < targetCount) {
      final addedCount = _takeOneFromEachPool(pools, result, targetCount);
      if (addedCount == 0) break; // 所有池子都空了
    }

    // Phase 2: 全局回填（Global Backfill）
    // 如果总数还不够，从所有池子的剩余歌曲中继续取
    if (result.length < targetCount) {
      final allLeftovers = <Track>[];
      for (final pool in pools) {
        allLeftovers.addAll(pool);
      }
      allLeftovers.shuffle(_random);

      final deficit = targetCount - result.length;
      result.addAll(allLeftovers.take(deficit));
    }

    return result;
  }

  /// 从每个非空池子中取出一首歌，返回本轮取出的数量
  int _takeOneFromEachPool(
    List<List<Track>> pools,
    List<Track> result,
    int targetCount,
  ) {
    var addedCount = 0;

    for (final pool in pools) {
      if (pool.isEmpty) continue;

      result.add(pool.removeAt(_random.nextInt(pool.length)));
      addedCount++;

      if (result.length >= targetCount) break;
    }

    return addedCount;
  }

  /// 根据调度模式选品（单个歌手）with Dynamic Threshold + Aggressive Backfill
  ///
  /// 双重保险机制：
  /// 1. 动态中位数阈值 - 根据歌手热度分布自适应分桶
  /// 2. 强力回填 - 只要库存够，必须给满目标数量
  List<Track> _selectByMode(
    List<Track> tracks,
    DispatchMode mode,
    int totalTarget,
    int artistCount,
  ) {
    if (tracks.isEmpty) return [];

    // 计算单人配额
    final perArtistQuota = (totalTarget / artistCount).ceil();

    // Unfiltered 模式：不筛选，直接返回全部（限制数量）
    if (mode == DispatchMode.unfiltered) {
      final all = List<Track>.from(tracks)..shuffle(_random);
      return all.take(perArtistQuota).toList();
    }

    // 其他模式：使用动态阈值分桶 + 强力回填
    final medianPop = TrackDispatcher.calculateMedianPopularity(tracks);
    final hotPool = tracks.where((t) => t.popularity >= medianPop).toList();
    final deepPool = tracks.where((t) => t.popularity < medianPop).toList();

    hotPool.shuffle(_random);
    deepPool.shuffle(_random);

    // hotRatio = 1 - deepCutRatio (deepCutRatio 是冷门占比，hotRatio 是热门占比)
    final hotRatio = 1.0 - mode.deepCutRatio;

    return _selectWithAggressiveBackfill(
      hotPool: hotPool,
      deepPool: deepPool,
      targetTotal: perArtistQuota,
      hotRatio: hotRatio,
    );
  }

  /// 强力回填选品辅助方法 (Aggressive Backfill)
  ///
  /// 保证：只要总库存 >= 目标数量，就必须给满
  List<Track> _selectWithAggressiveBackfill({
    required List<Track> hotPool,
    required List<Track> deepPool,
    required int targetTotal,
    required double hotRatio,
  }) {
    // Phase 1: 按理想比例取歌
    final targetHot = (targetTotal * hotRatio).round();
    final targetDeep = targetTotal - targetHot;

    final takenHot = hotPool.take(targetHot).toList();
    final takenDeep = deepPool.take(targetDeep).toList();

    final selected = <Track>[...takenHot, ...takenDeep];

    // Phase 2: 强力回填
    // 如果还没凑够目标，从剩余的所有歌里继续填
    if (selected.length < targetTotal) {
      final deficit = targetTotal - selected.length;

      // 收集所有剩余的歌（不管热度）
      final leftovers = <Track>[
        ...hotPool.skip(takenHot.length),
        ...deepPool.skip(takenDeep.length),
      ];

      leftovers.shuffle(_random);

      // 填满缺口
      selected.addAll(leftovers.take(deficit));
    }

    return selected;
  }

  /// 静态便捷方法
  static List<Track> mix({
    required Map<String, List<Track>> artistTrackPools,
    required int targetCount,
    required DispatchMode mode,
    bool skipDedupe = false,
    Random? random,
  }) {
    return MultiArtistPipeline(random: random).fairMix(
      artistTrackPools: artistTrackPools,
      targetCount: targetCount,
      mode: mode,
      skipDedupe: skipDedupe,
    );
  }
}
