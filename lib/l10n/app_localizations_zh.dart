// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'FullStop 句号';

  @override
  String get focusSessions => '专注时刻';

  @override
  String get newSession => '新建会话';

  @override
  String get noSessionsYet => '暂无专注会话';

  @override
  String get createSessionHint => '创建一个会话来专注聆听你喜爱的艺术家';

  @override
  String get focusOnFavoriteArtists => '专注聆听你喜爱的艺术家';

  @override
  String get connectWithSpotify => '连接 Spotify';

  @override
  String get connectingToSpotify => '正在连接 Spotify...';

  @override
  String get completeLoginInBrowser => '请在浏览器中完成登录。';

  @override
  String get afterAgreeCloseBrowser => '点击「同意」后，可以关闭浏览器标签页';

  @override
  String get cancelLogin => '取消登录';

  @override
  String get cancelHint => '点击取消并返回登录界面';

  @override
  String get connectionFailed => '连接失败';

  @override
  String get errorCopied => '错误信息已复制到剪贴板';

  @override
  String get reconfigureCredentials => '重新配置凭据';

  @override
  String get apiConfigured => 'API 已配置';

  @override
  String get change => '更改';

  @override
  String get credentialsStayOnDevice => '您的凭据仅保存在本地设备';

  @override
  String get controlsExistingSession => '控制您现有的 Spotify 会话';

  @override
  String get requiresPremium => '需要 Spotify Premium';

  @override
  String get logout => '退出登录';

  @override
  String get premium => 'Premium';

  @override
  String get free => '免费版';

  @override
  String get settings => '设置';

  @override
  String get language => '语言';

  @override
  String get english => 'English';

  @override
  String get chinese => '中文';

  @override
  String get japanese => '日本語';

  @override
  String get systemDefault => '跟随系统';

  @override
  String get createSession => '创建会话';

  @override
  String get searchArtists => '搜索艺术家...';

  @override
  String get addMoreArtists => '继续添加...';

  @override
  String get selectedArtists => '已选艺术家';

  @override
  String get sessionName => '会话名称';

  @override
  String get sessionNameHint => '例如：我的放松音乐';

  @override
  String get create => '创建';

  @override
  String get cancel => '取消';

  @override
  String get nowPlaying => '正在播放';

  @override
  String get nothingPlaying => '当前无播放内容';

  @override
  String get play => '播放';

  @override
  String get pause => '暂停';

  @override
  String get previous => '上一首';

  @override
  String get next => '下一首';

  @override
  String get setupGuide => '设置向导';

  @override
  String get welcomeToApp => '欢迎使用 Spotify 专注听歌！';

  @override
  String get setupDescription => '首先，您需要创建一个 Spotify 开发者应用并输入您的凭据。';

  @override
  String get step1Title => '前往 Spotify 开发者控制台';

  @override
  String get step2Title => '创建新应用';

  @override
  String get step3Title => '添加重定向 URI';

  @override
  String get step4Title => '复制您的凭据';

  @override
  String get clientId => 'Client ID';

  @override
  String get clientSecret => 'Client Secret';

  @override
  String get saveAndContinue => '保存并继续';

  @override
  String get errorInvalidClient => 'API 凭据无效。请检查您的 Client ID 和 Secret。';

  @override
  String get errorRedirectUri => '重定向 URI 不匹配！请确保您的 Spotify 应用配置了正确的重定向 URI。';

  @override
  String get errorNetwork => '网络错误。请检查您的网络连接。';

  @override
  String get errorCancelled => '登录已取消。请重试。';

  @override
  String get errorTimeout => '认证超时。请重试。';

  @override
  String get errorAccessDenied => '访问被拒绝。您需要授权应用访问您的 Spotify 账户。';

  @override
  String get errorNeedsReauth => '权限不足。请退出登录后重新登录以授予所需权限。';

  @override
  String tracks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 首曲目',
      one: '1 首曲目',
      zero: '无曲目',
    );
    return '$_temp0';
  }

  @override
  String artists(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 位艺术家',
      one: '1 位艺术家',
      zero: '无艺术家',
    );
    return '$_temp0';
  }

  @override
  String get deleteSession => '删除会话';

  @override
  String deleteSessionConfirm(String name) {
    return '确定要删除「$name」吗？';
  }

  @override
  String get delete => '删除';

  @override
  String get sessionDeleted => '会话已删除';

  @override
  String get shuffle => '随机播放';

  @override
  String get shuffleOn => '随机播放已开启';

  @override
  String get shuffleOff => '随机播放已关闭';

  @override
  String get repeat => '循环';

  @override
  String get repeatOff => '播完结束';

  @override
  String get repeatAll => '循环歌单';

  @override
  String get repeatOne => '单曲循环';

  @override
  String get sessionNameOptional => '会话名称（可选）';

  @override
  String get searchForArtists => '搜索艺术家以添加到会话';

  @override
  String get noArtistsFound => '未找到艺术家';

  @override
  String createdSession(String name) {
    return '已创建会话：$name';
  }

  @override
  String get more => '更多';

  @override
  String get edit => '编辑';

  @override
  String get save => '保存';

  @override
  String get noTracksInSession => '此会话暂无曲目';

  @override
  String get removeTrack => '移除曲目';

  @override
  String get sessionUpdated => '会话已更新';

  @override
  String get editSession => '编辑会话';

  @override
  String get dragToReorder => '拖动以重新排序曲目';

  @override
  String get creatingSession => '正在创建会话，获取曲目中...';

  @override
  String get smartSchedule => '智能调度';

  @override
  String get smartScheduleHint => '按曲风筛选歌曲';

  @override
  String get styleSlow => '慢板';

  @override
  String get styleSlowDesc => '抒情、悲伤、慵懒';

  @override
  String get styleMidTempo => '中速';

  @override
  String get styleMidTempoDesc => '轻松、律动、R&B';

  @override
  String get styleUpTempo => '快板';

  @override
  String get styleUpTempoDesc => '活力、流行、舞曲';

  @override
  String get styleFast => '极速';

  @override
  String get styleFastDesc => '摇滚、金属、激烈';

  @override
  String bpmRange(int min, int max) {
    return '$min-$max BPM';
  }

  @override
  String get selectStyle => '选择曲风';

  @override
  String get proxy => '代理设置';

  @override
  String get proxyEnabled => '启用代理';

  @override
  String get proxyType => '代理类型';

  @override
  String get proxyHost => '主机地址';

  @override
  String get proxyPort => '端口';

  @override
  String get proxyUsername => '用户名（可选）';

  @override
  String get proxyPassword => '密码（可选）';

  @override
  String get proxyHint => '使用 SOCKS5 或 HTTP 代理加速访问 Spotify API';

  @override
  String get proxySaved => '代理设置已保存';

  @override
  String get proxyCleared => '代理设置已清除';

  @override
  String get proxyInvalid => '代理配置无效';

  @override
  String get testProxy => '测试连接';

  @override
  String get proxyTestSuccess => '代理连接成功';

  @override
  String proxyTestFailed(String error) {
    return '代理连接失败：$error';
  }

  @override
  String get matchByStyle => '按曲风';

  @override
  String get matchByArtistTrack => '按艺术家';

  @override
  String get matchByPlaylist => '按歌单';

  @override
  String get selectPlaylist => '选择歌单';

  @override
  String get selectTrackForMatch => '选择一首歌曲来匹配 BPM';

  @override
  String get yourPlaylists => '我的歌单';

  @override
  String get loadingPlaylists => '正在加载歌单...';

  @override
  String get noPlaylists => '暂无歌单';

  @override
  String matchingBpm(int bpm) {
    return '匹配 BPM：$bpm';
  }

  @override
  String get selectArtistFirst => '请先选择艺术家';

  @override
  String get loadingArtistTracks => '正在加载艺术家曲目...';

  @override
  String get noArtistTracks => '未找到已选艺术家的曲目';

  @override
  String get selectTrackFromArtist => '从艺术家曲目中选择';

  @override
  String get selectTracksFromArtist => '选择曲目匹配 BPM';

  @override
  String selectedTracksCount(int count) {
    return '已选择 $count 首曲目';
  }

  @override
  String bpmRangesHint(String ranges) {
    return 'BPM 范围：$ranges';
  }

  @override
  String get clearAll => '清除全部';

  @override
  String get retry => '重试';

  @override
  String get loadingBpm => '正在获取 BPM...';

  @override
  String get bpmUnavailable => 'BPM 数据不可用';

  @override
  String get advancedFeatures => 'BPM 功能';

  @override
  String get getSongBpmAttribution => '由 GetSongBPM 提供支持';

  @override
  String get getSongBpmHint =>
      'BPM 数据由 GetSongBPM.com 提供。注册免费 API 密钥以启用 BPM 匹配功能。';

  @override
  String get getSongBpmApiKey => 'GetSongBPM API 密钥';

  @override
  String get getSongBpmApiKeyHint => '输入您的 GetSongBPM API 密钥';

  @override
  String get getSongBpmApiKeyConfigured => 'API 密钥已配置';

  @override
  String get getSongBpmApiKeySaved => 'API 密钥保存成功';

  @override
  String get getSongBpmApiKeyError => '保存 API 密钥失败';

  @override
  String get getSongBpmApiKeyEmpty => '请输入 API 密钥';

  @override
  String get getSongBpmApiKeyCleared => 'API 密钥已清除';

  @override
  String get experimentalFeature => '实验性功能';

  @override
  String get experimentalSmartScheduleWarning =>
      '此模式需要为所有曲目获取 BPM 数据，可能需要几分钟时间。会话将在后台创建，您可以继续使用应用。';

  @override
  String get continueButton => '继续';

  @override
  String get creatingSessionBackground => '正在后台创建会话...';

  @override
  String fetchingTracksProgress(int count) {
    return '正在从 $count 位艺术家获取曲目...';
  }

  @override
  String fetchingArtistTracks(String artistName) {
    return '正在获取：$artistName';
  }

  @override
  String fetchingBpmProgress(int current, int total) {
    return '正在分析 BPM ($current/$total)...';
  }

  @override
  String get filteringTracks => '正在按 BPM 筛选曲目...';

  @override
  String sessionCreatedBackground(String name, int count) {
    return '已创建会话「$name」，共 $count 首曲目';
  }

  @override
  String sessionCreationFailed(String error) {
    return '创建会话失败：$error';
  }

  @override
  String get pendingSession => '创建中...';

  @override
  String get viewPendingSession => '查看';

  @override
  String get trackLimit => '曲目限制';

  @override
  String trackLimitEnabled(int count) {
    return '限制为 $count 首曲目';
  }

  @override
  String get trackLimitDisabled => '无曲目限制';

  @override
  String get trackLimitHint => '限制智能调度会话中的曲目数量';

  @override
  String bpmCacheStats(int count) {
    return 'BPM 缓存：$count 条记录';
  }

  @override
  String get clearBpmCache => '清除 BPM 缓存';

  @override
  String get bpmCacheCleared => 'BPM 缓存已清除';

  @override
  String get trayShowWindow => '显示 FullStop';

  @override
  String get trayExit => '退出';

  @override
  String get trayPreviousTrack => '上一首';

  @override
  String get trayNextTrack => '下一首';

  @override
  String get trayTooltip => 'FullStop - Spotify 控制器';

  @override
  String get errorNoActiveDevice =>
      '未找到活跃的 Spotify 设备。请先在手机、电脑或其他设备上打开 Spotify。';

  @override
  String get errorSpotifyConnectionFailed =>
      'FullStop 无法连接到 Spotify。请手动打开 Spotify 并播放任意音乐，然后重试。';

  @override
  String get connectingToSpotifyDevice => '正在连接 Spotify...';

  @override
  String get spotifyNotInstalled => '未检测到 Spotify 客户端';

  @override
  String get traditionalSchedule => '传统调度';

  @override
  String get dispatchHitsOnly => '仅限金曲';

  @override
  String get dispatchHitsOnlyDesc => '闭眼入坑，首首都是大合唱。';

  @override
  String get dispatchBalanced => '经典平衡';

  @override
  String get dispatchBalancedDesc => '熟悉中偶遇惊喜，久听不累。';

  @override
  String get dispatchDeepDive => '深度挖掘';

  @override
  String get dispatchDeepDiveDesc => '寻找那首被遗忘的宝藏 B 面。';

  @override
  String get dispatchUnfiltered => '原汁原味';

  @override
  String get dispatchUnfilteredDesc => '重返现场，感受每一次安可。';

  @override
  String get trueShuffle => '真随机';

  @override
  String get trueShuffleDesc => '智能去重 & 专辑隔离';

  @override
  String get artistLimitReached => '已达艺术家上限';

  @override
  String artistLimitHint(int count) {
    return '为保证最佳专注体验与去重效果，建议限制在 $count 位艺术家以内。';
  }

  @override
  String selectedArtistsCount(int current, int max) {
    return '已选 ($current/$max)';
  }

  @override
  String get tapToExpand => '点击展开';

  @override
  String get cacheManagement => '缓存';

  @override
  String get imageCacheSize => '图片缓存';

  @override
  String get clearCache => '清除缓存';

  @override
  String get cacheCleared => '缓存已清除';

  @override
  String get cacheClearFailed => '清除缓存失败';

  @override
  String get calculating => '计算中...';

  @override
  String get rename => '重命名';

  @override
  String get renameSession => '重命名会话';

  @override
  String get sessionRenamed => '会话已重命名';

  @override
  String get likeAllTracks => '全部加入点赞';

  @override
  String likeAllTracksConfirm(int count) {
    return '将 $count 首曲目添加到「喜欢的歌曲」？';
  }

  @override
  String get tracksAlreadyLiked => '所有曲目已在点赞列表中';

  @override
  String tracksLiked(int count) {
    return '已将 $count 首曲目添加到「喜欢的歌曲」';
  }

  @override
  String get addToPlaylist => '添加到歌单';

  @override
  String get createPlaylistFromSession => '以此创建歌单';

  @override
  String createPlaylistConfirm(String name, int count) {
    return '创建 Spotify 歌单「$name」，包含 $count 首曲目？';
  }

  @override
  String playlistCreated(String name) {
    return '已创建歌单「$name」';
  }

  @override
  String get playlistCreationFailed => '创建歌单失败';

  @override
  String get checkingLikedStatus => '正在检查点赞状态...';

  @override
  String get likingTracks => '正在添加点赞...';

  @override
  String get creatingPlaylist => '正在创建歌单...';

  @override
  String get moveUp => '上移';

  @override
  String get moveDown => '下移';

  @override
  String get pinToTop => '置顶';

  @override
  String get unpinFromTop => '取消置顶';

  @override
  String lastPlayed(String time) {
    return '上次播放：$time';
  }

  @override
  String get moreArtists => '更多艺术家';

  @override
  String get expand => '展开';

  @override
  String get collapse => '收起';

  @override
  String minutesAgo(int count) {
    return '$count分钟前';
  }

  @override
  String hoursAgo(int count) {
    return '$count小时前';
  }

  @override
  String daysAgo(int count) {
    return '$count天前';
  }

  @override
  String get performance => '性能';

  @override
  String get gpuAcceleration => 'GPU 加速';

  @override
  String get gpuAccelerationDesc => '使用 GPU 提升动画流畅度';

  @override
  String get gpuAccelerationHint =>
      '启用 GPU 加速以获得更流畅的波浪动画效果。如果遇到图形问题或没有独立显卡，请关闭此选项。';

  @override
  String get pinSession => '置顶会话';

  @override
  String get unpinSession => '取消置顶';

  @override
  String get pinSessionHint => '最多置顶3个会话';

  @override
  String get sessionPinned => '会话已置顶';

  @override
  String get sessionUnpinned => '已取消置顶';

  @override
  String get aboutVersion => '版本';

  @override
  String get aboutPrivacySecurity => '隐私与安全';

  @override
  String get aboutDeveloper => '开发者';

  @override
  String get aboutGitHub => 'GitHub';

  @override
  String get aboutStarProject => '为项目点个Star';

  @override
  String get aboutTwitter => 'X (Twitter)';

  @override
  String get aboutFollowUpdates => '关注获取更新';

  @override
  String get aboutPoweredBySpotify => '由 Spotify 提供支持';

  @override
  String get aboutUsesSpotifyApi => '使用 Spotify Web API';

  @override
  String get privacySecureStorage => '安全本地存储';

  @override
  String get privacySecureStorageDesc =>
      '您的 API 凭据经过加密，仅存储在您的设备上，从不会传输到任何外部服务器。';

  @override
  String get privacyDirectConnection => '直连 Spotify';

  @override
  String get privacyDirectConnectionDesc =>
      '本应用直接连接 Spotify 官方 API，不通过任何中间服务器中转您的数据。';

  @override
  String get privacyNoDataCollection => '无数据收集';

  @override
  String get privacyNoDataCollectionDesc => '我们不收集、存储或传输任何使用分析、播放历史或个人信息。';

  @override
  String get privacyOAuthSecurity => 'OAuth 安全';

  @override
  String get privacyOAuthSecurityDesc =>
      '身份验证使用本地 HTTP 服务器（端口 8888-8891、8080 或 3000），并通过 state 参数进行 CSRF 保护。';

  @override
  String get privacyYouControl => '数据由您掌控';

  @override
  String get privacyYouControlDesc => '您可以随时在设置页面清除凭据。卸载应用将删除所有存储的数据。';

  @override
  String get close => '关闭';

  @override
  String get welcomeToFullStop => '欢迎使用 FullStop';

  @override
  String get updateCredentials => '更新凭据';

  @override
  String get connectSpotifyToStart => '连接您的 Spotify 账户以开始使用';

  @override
  String get updateSpotifyCredentials => '更新您的 Spotify API 凭据';

  @override
  String get credentialsSecurelyStored => '您的凭据仅安全存储在您的设备上';

  @override
  String get privacyPolicy => '隐私政策';

  @override
  String get step1CreateApp => '第一步：创建 Spotify 应用';

  @override
  String get openDeveloperDashboard => '打开 Spotify 开发者控制台';

  @override
  String get openDeveloperDashboardHint => '点击下方按钮，在浏览器中打开 Spotify 开发者控制台。';

  @override
  String get createNewApp => '创建新应用';

  @override
  String get createNewAppDesc =>
      '点击「Create App」并填写：\n• App name：任意名称（如 \"My Focus App\"）\n• App description：个人使用\n• Website：留空或填写任意 URL\n• 勾选「Web API」选项';

  @override
  String get createNewAppDescShort => '点击「Create App」并填写以下字段，勾选「Web API」选项。';

  @override
  String get appNameLabel => 'App name（应用名称）';

  @override
  String get appNameCopied => '应用名称已复制！';

  @override
  String get appDescriptionLabel => 'App description（应用描述）';

  @override
  String get appDescriptionCopied => '应用描述已复制！';

  @override
  String get redirectUriLabel => 'Redirect URI（重定向 URI）';

  @override
  String get setRedirectUri => '设置重定向 URI（重要！）';

  @override
  String get setRedirectUriDesc => '在「Redirect URIs」字段中添加以下 URI：';

  @override
  String get copy => '复制';

  @override
  String get redirectUriCopied => '重定向 URI 已复制！';

  @override
  String get redirectUriWarning => '粘贴后点击「Add」，然后点击底部的「Save」！';

  @override
  String get step2EnterCredentials => '第二步：输入凭据';

  @override
  String get updateYourCredentials => '更新您的凭据';

  @override
  String get findCredentialsHint => '在 Spotify 开发者控制台的应用设置页面中找到您的凭据。';

  @override
  String get modifyCredentialsHint => '修改下方凭据，如正确则无需更改。';

  @override
  String get enterClientId => '输入您的 Client ID';

  @override
  String get clientIdRequired => 'Client ID 为必填项';

  @override
  String get clientIdTooShort => 'Client ID 似乎太短';

  @override
  String get enterClientSecret => '输入您的 Client Secret';

  @override
  String get clientSecretRequired => 'Client Secret 为必填项';

  @override
  String get clientSecretTooShort => 'Client Secret 似乎太短';

  @override
  String get whereToFindCredentials => '在哪里找到这些？';

  @override
  String get whereToFindCredentialsDesc =>
      '在您的 Spotify 应用设置页面中，您会看到 Client ID。点击「View client secret」查看密钥。';

  @override
  String get step3ReadyToConnect => '第三步：准备连接';

  @override
  String get credentialsSaved => '凭据已保存！';

  @override
  String get waitingForCredentials => '等待输入凭据';

  @override
  String get credentialsSavedDesc => '您的 Spotify API 凭据已安全存储。现在可以连接 Spotify 了。';

  @override
  String get waitingForCredentialsDesc => '请返回第二步输入您的凭据。';

  @override
  String get spotifyPremiumRequired => '需要 Spotify Premium';

  @override
  String get spotifyPremiumRequiredDesc =>
      '本应用需要 Spotify Premium 订阅才能使用播放控制功能。';

  @override
  String get back => '返回';

  @override
  String get nextEnterCredentials => '下一步：输入凭据';

  @override
  String get saveCredentials => '保存凭据';

  @override
  String get updateCredentialsButton => '更新凭据';

  @override
  String get connectToSpotify => '连接 Spotify';

  @override
  String get reconfigureApiCredentials => '重新配置 API 凭据';

  @override
  String get changeClientIdSecret => '更改您的 Client ID 和 Secret';

  @override
  String get reconfigureDialogTitle => '重新配置 API 凭据';

  @override
  String get reconfigureDialogContent =>
      '这将清除当前的 API 凭据并登出。\n\n您需要重新输入 Client ID 和 Secret。';

  @override
  String get reconfigure => '重新配置';

  @override
  String get redirectUriForSpotifyApp => 'Spotify 应用的重定向 URI';

  @override
  String get spotifyApi => 'Spotify API';

  @override
  String configured(String clientId) {
    return '已配置（$clientId）';
  }

  @override
  String get notConfigured => '未配置';

  @override
  String get llmOpenAiCompatible => 'OpenAI 兼容 API';

  @override
  String get llmOpenAiCompatibleDesc =>
      '支持 OpenAI、Ollama 及其他 OpenAI 兼容 API。\n本地模型（如 Ollama）可不填 API Key。';

  @override
  String get enableAiFeatures => '启用 AI 功能';

  @override
  String get smartPlaylistCuration => '使用 LLM 智能策划播放列表';

  @override
  String get llmBaseUrl => 'Base URL *';

  @override
  String get llmBaseUrlHint => 'https://api.openai.com/v1';

  @override
  String get llmBaseUrlHelper => '将自动添加 /chat/completions';

  @override
  String get llmModel => '模型 *';

  @override
  String get llmModelHint => 'gpt-4';

  @override
  String get llmModelHelper => '例如：gpt-4o-mini、llama3、qwen2、gemini-pro';

  @override
  String get llmApiKey => 'API Key（可选）';

  @override
  String get llmApiKeyHint => 'sk-...';

  @override
  String get llmApiKeyHelper => '本地模型（如 Ollama）可留空';

  @override
  String get test => '测试';

  @override
  String get llmExamples => '示例：';

  @override
  String llmConfigured(String model) {
    return 'LLM 已配置：$model';
  }

  @override
  String get llmConfigSaved => 'LLM 配置已保存';

  @override
  String get llmConfigSaveFailed => '保存配置失败';

  @override
  String get llmBaseUrlModelRequired => 'Base URL 和模型为必填项';

  @override
  String llmTesting(String url) {
    return '测试中：$url';
  }

  @override
  String llmTestSuccess(String response) {
    return '成功！响应：$response...';
  }

  @override
  String get request => '请求：';

  @override
  String get llmError404 => '错误 404：未找到端点，请检查 API 端点 URL 是否正确';

  @override
  String get llmError401 => '错误 401：无效的 API Key 或未授权访问';

  @override
  String get llmError403 => '错误 403：访问被禁止，请检查 API Key 权限';

  @override
  String get llmError429 => '错误 429：请求频率超限，请稍后重试';

  @override
  String get llmErrorServer => '服务器错误：API 服务器暂时不可用';

  @override
  String get llmErrorTimeout => '连接超时：服务器响应时间过长';

  @override
  String get llmErrorConnection => '连接失败：请检查网络和代理设置';
}
