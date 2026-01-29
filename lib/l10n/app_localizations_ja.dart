// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'FullStop';

  @override
  String get focusSessions => 'フォーカスモーメント';

  @override
  String get newSession => '新規セッション';

  @override
  String get noSessionsYet => 'フォーカスセッションがありません';

  @override
  String get createSessionHint => 'お気に入りのアーティストに集中するセッションを作成しましょう';

  @override
  String get focusOnFavoriteArtists => 'お気に入りのアーティストに集中';

  @override
  String get connectWithSpotify => 'Spotifyに接続';

  @override
  String get connectingToSpotify => 'Spotifyに接続中...';

  @override
  String get completeLoginInBrowser => 'ブラウザでログインを完了してください。';

  @override
  String get afterAgreeCloseBrowser => '「同意する」をクリックした後、ブラウザタブを閉じることができます';

  @override
  String get cancelLogin => 'ログインをキャンセル';

  @override
  String get cancelHint => 'キャンセルしてログイン画面に戻る';

  @override
  String get connectionFailed => '接続失敗';

  @override
  String get errorCopied => 'エラーメッセージをクリップボードにコピーしました';

  @override
  String get reconfigureCredentials => '認証情報を再設定';

  @override
  String get apiConfigured => 'API設定済み';

  @override
  String get change => '変更';

  @override
  String get credentialsStayOnDevice => '認証情報はお使いのデバイスにのみ保存されます';

  @override
  String get controlsExistingSession => '既存のSpotifyセッションを操作します';

  @override
  String get requiresPremium => 'Spotify Premiumが必要です';

  @override
  String get logout => 'ログアウト';

  @override
  String get premium => 'Premium';

  @override
  String get free => '無料';

  @override
  String get settings => '設定';

  @override
  String get language => '言語';

  @override
  String get english => 'English';

  @override
  String get chinese => '中文';

  @override
  String get japanese => '日本語';

  @override
  String get systemDefault => 'システムのデフォルト';

  @override
  String get createSession => 'セッションを作成';

  @override
  String get searchArtists => 'アーティストを検索...';

  @override
  String get addMoreArtists => 'さらに追加...';

  @override
  String get selectedArtists => '選択したアーティスト';

  @override
  String get sessionName => 'セッション名';

  @override
  String get sessionNameHint => '例：リラックスミックス';

  @override
  String get create => '作成';

  @override
  String get cancel => 'キャンセル';

  @override
  String get nowPlaying => '再生中';

  @override
  String get nothingPlaying => '再生中の曲はありません';

  @override
  String get play => '再生';

  @override
  String get pause => '一時停止';

  @override
  String get previous => '前へ';

  @override
  String get next => '次へ';

  @override
  String get setupGuide => 'セットアップガイド';

  @override
  String get welcomeToApp => 'Spotify Focus Someoneへようこそ！';

  @override
  String get setupDescription => 'まず、Spotify開発者アプリを作成し、認証情報を入力する必要があります。';

  @override
  String get step1Title => 'Spotify開発者ダッシュボードにアクセス';

  @override
  String get step2Title => '新しいアプリを作成';

  @override
  String get step3Title => 'リダイレクトURIを追加';

  @override
  String get step4Title => '認証情報をコピー';

  @override
  String get clientId => 'Client ID';

  @override
  String get clientSecret => 'Client Secret';

  @override
  String get saveAndContinue => '保存して続行';

  @override
  String get errorInvalidClient => 'API認証情報が無効です。Client IDとSecretを確認してください。';

  @override
  String get errorRedirectUri =>
      'リダイレクトURIが一致しません！SpotifyアプリにリダイレクトURIが正しく設定されていることを確認してください。';

  @override
  String get errorNetwork => 'ネットワークエラー。インターネット接続を確認してください。';

  @override
  String get errorCancelled => 'ログインがキャンセルされました。もう一度お試しください。';

  @override
  String get errorTimeout => '認証がタイムアウトしました。もう一度お試しください。';

  @override
  String get errorAccessDenied =>
      'アクセスが拒否されました。Spotifyアカウントへのアクセスを許可する必要があります。';

  @override
  String get errorNeedsReauth => '権限が不足しています。ログアウトして再度ログインし、必要な権限を付与してください。';

  @override
  String tracks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count トラック',
      one: '1 トラック',
      zero: 'トラックなし',
    );
    return '$_temp0';
  }

  @override
  String artists(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count アーティスト',
      one: '1 アーティスト',
      zero: 'アーティストなし',
    );
    return '$_temp0';
  }

  @override
  String get deleteSession => 'セッションを削除';

  @override
  String deleteSessionConfirm(String name) {
    return '「$name」を削除しますか？';
  }

  @override
  String get delete => '削除';

  @override
  String get sessionDeleted => 'セッションが削除されました';

  @override
  String get shuffle => 'シャッフル';

  @override
  String get shuffleOn => 'Shuffle On';

  @override
  String get shuffleOff => 'Shuffle Off';

  @override
  String get repeat => 'リピート';

  @override
  String get repeatOff => '再生後停止';

  @override
  String get repeatAll => 'リピート';

  @override
  String get repeatOne => '1曲リピート';

  @override
  String get sessionNameOptional => 'セッション名（任意）';

  @override
  String get searchForArtists => 'セッションに追加するアーティストを検索';

  @override
  String get noArtistsFound => 'アーティストが見つかりません';

  @override
  String createdSession(String name) {
    return 'セッションを作成しました：$name';
  }

  @override
  String get more => 'その他';

  @override
  String get edit => '編集';

  @override
  String get save => '保存';

  @override
  String get noTracksInSession => 'このセッションにはトラックがありません';

  @override
  String get removeTrack => 'トラックを削除';

  @override
  String get sessionUpdated => 'セッションを更新しました';

  @override
  String get editSession => 'セッションを編集';

  @override
  String get dragToReorder => 'ドラッグしてトラックを並べ替え';

  @override
  String get creatingSession => 'セッションを作成中、トラックを取得しています...';

  @override
  String get smartSchedule => 'スマートスケジュール';

  @override
  String get smartScheduleHint => 'テンポスタイルでフィルター';

  @override
  String get styleSlow => 'スロー';

  @override
  String get styleSlowDesc => 'バラード、感動的、リラックス';

  @override
  String get styleMidTempo => 'ミッドテンポ';

  @override
  String get styleMidTempoDesc => '軽快、R&Bグルーヴ';

  @override
  String get styleUpTempo => 'アップテンポ';

  @override
  String get styleUpTempoDesc => '活気、ポップ、ダンス';

  @override
  String get styleFast => 'ファスト';

  @override
  String get styleFastDesc => 'ロック、メタル、激しい';

  @override
  String bpmRange(int min, int max) {
    return '$min-$max BPM';
  }

  @override
  String get selectStyle => 'スタイルを選択';

  @override
  String get proxy => 'プロキシ設定';

  @override
  String get proxyEnabled => 'プロキシを有効にする';

  @override
  String get proxyType => 'プロキシタイプ';

  @override
  String get proxyHost => 'ホスト';

  @override
  String get proxyPort => 'ポート';

  @override
  String get proxyUsername => 'ユーザー名（任意）';

  @override
  String get proxyPassword => 'パスワード（任意）';

  @override
  String get proxyHint => 'SOCKS5またはHTTPプロキシを使用してSpotify APIへのアクセスを高速化';

  @override
  String get proxySaved => 'プロキシ設定を保存しました';

  @override
  String get proxyCleared => 'プロキシ設定をクリアしました';

  @override
  String get proxyInvalid => 'プロキシ設定が無効です';

  @override
  String get testProxy => '接続テスト';

  @override
  String get proxyTestSuccess => 'プロキシ接続に成功しました';

  @override
  String proxyTestFailed(String error) {
    return 'プロキシ接続に失敗しました：$error';
  }

  @override
  String get matchByStyle => 'スタイル';

  @override
  String get matchByArtistTrack => 'アーティスト';

  @override
  String get matchByPlaylist => 'プレイリスト';

  @override
  String get selectPlaylist => 'プレイリストを選択';

  @override
  String get selectTrackForMatch => 'BPMをマッチングする曲を選択';

  @override
  String get yourPlaylists => 'マイプレイリスト';

  @override
  String get loadingPlaylists => 'プレイリストを読み込み中...';

  @override
  String get noPlaylists => 'プレイリストがありません';

  @override
  String matchingBpm(int bpm) {
    return 'マッチングBPM：$bpm';
  }

  @override
  String get selectArtistFirst => '先にアーティストを選択してください';

  @override
  String get loadingArtistTracks => 'アーティストの曲を読み込み中...';

  @override
  String get noArtistTracks => '選択したアーティストの曲が見つかりません';

  @override
  String get selectTrackFromArtist => 'アーティストの曲から選択';

  @override
  String get selectTracksFromArtist => 'BPMにマッチする曲を選択';

  @override
  String selectedTracksCount(int count) {
    return '$count曲選択中';
  }

  @override
  String bpmRangesHint(String ranges) {
    return 'BPM範囲：$ranges';
  }

  @override
  String get clearAll => 'すべてクリア';

  @override
  String get retry => '再試行';

  @override
  String get loadingBpm => 'BPM読み込み中...';

  @override
  String get bpmUnavailable => 'BPMデータ利用不可';

  @override
  String get advancedFeatures => 'BPM機能';

  @override
  String get getSongBpmAttribution => 'GetSongBPM提供';

  @override
  String get getSongBpmHint =>
      'BPMデータはGetSongBPM.comから提供されています。BPMマッチング機能を有効にするには、無料のAPIキーを登録してください。';

  @override
  String get getSongBpmApiKey => 'GetSongBPM APIキー';

  @override
  String get getSongBpmApiKeyHint => 'GetSongBPM APIキーを入力';

  @override
  String get getSongBpmApiKeyConfigured => 'APIキー設定済み';

  @override
  String get getSongBpmApiKeySaved => 'APIキーを保存しました';

  @override
  String get getSongBpmApiKeyError => 'APIキーの保存に失敗しました';

  @override
  String get getSongBpmApiKeyEmpty => 'APIキーを入力してください';

  @override
  String get getSongBpmApiKeyCleared => 'APIキーをクリアしました';

  @override
  String get experimentalFeature => '実験的機能';

  @override
  String get experimentalSmartScheduleWarning =>
      'このモードはすべての曲のBPMを取得するため、数分かかる場合があります。セッションはバックグラウンドで作成されますので、アプリを引き続きご利用いただけます。';

  @override
  String get continueButton => '続ける';

  @override
  String get creatingSessionBackground => 'バックグラウンドでセッション作成中...';

  @override
  String fetchingTracksProgress(int count) {
    return '$countアーティストから曲を取得中...';
  }

  @override
  String fetchingArtistTracks(String artistName) {
    return '取得中：$artistName';
  }

  @override
  String fetchingBpmProgress(int current, int total) {
    return 'BPM分析中 ($current/$total)...';
  }

  @override
  String get filteringTracks => 'BPMでフィルタリング中...';

  @override
  String sessionCreatedBackground(String name, int count) {
    return 'セッション「$name」が作成されました（$count曲）';
  }

  @override
  String sessionCreationFailed(String error) {
    return 'セッション作成失敗：$error';
  }

  @override
  String get pendingSession => '作成中...';

  @override
  String get viewPendingSession => '表示';

  @override
  String get trackLimit => 'トラック制限';

  @override
  String trackLimitEnabled(int count) {
    return '$count曲に制限';
  }

  @override
  String get trackLimitDisabled => '制限なし';

  @override
  String get trackLimitHint => 'スマートスケジュールセッションのトラック数を制限';

  @override
  String bpmCacheStats(int count) {
    return 'BPMキャッシュ：$count件';
  }

  @override
  String get clearBpmCache => 'BPMキャッシュをクリア';

  @override
  String get bpmCacheCleared => 'BPMキャッシュをクリアしました';

  @override
  String get trayShowWindow => 'FullStopを表示';

  @override
  String get trayExit => '終了';

  @override
  String get trayPreviousTrack => '前のトラック';

  @override
  String get trayNextTrack => '次のトラック';

  @override
  String get trayTooltip => 'FullStop - Spotifyコントローラー';

  @override
  String get errorNoActiveDevice =>
      'アクティブなSpotifyデバイスが見つかりません。スマートフォン、パソコン、または他のデバイスでSpotifyを先に開いてください。';

  @override
  String get errorSpotifyConnectionFailed =>
      'FullStop cannot connect to Spotify. Please manually open Spotify and play any music, then try again.';

  @override
  String get connectingToSpotifyDevice => 'Connecting to Spotify...';

  @override
  String get spotifyNotInstalled => 'Spotify app not detected';

  @override
  String get traditionalSchedule => 'トラディショナル';

  @override
  String get dispatchHitsOnly => 'ヒット曲のみ';

  @override
  String get dispatchHitsOnlyDesc => 'スキップ不要、全曲サビまで歌える。';

  @override
  String get dispatchBalanced => 'バランス';

  @override
  String get dispatchBalancedDesc => '定番の中に嬉しい発見、飽きのこない選曲。';

  @override
  String get dispatchDeepDive => 'ディープダイブ';

  @override
  String get dispatchDeepDiveDesc => '忘れられたB面の宝石を探して。';

  @override
  String get dispatchUnfiltered => 'ノーフィルター';

  @override
  String get dispatchUnfilteredDesc => 'ライブ会場に戻り、アンコールの熱狂を。';

  @override
  String get trueShuffle => 'トゥルーシャッフル';

  @override
  String get trueShuffleDesc => 'スマート重複排除 & アルバム分散';

  @override
  String get artistLimitReached => 'Artist limit reached';

  @override
  String artistLimitHint(int count) {
    return 'For best focus experience and dedupe quality, limit to $count artists.';
  }

  @override
  String selectedArtistsCount(int current, int max) {
    return 'Selected ($current/$max)';
  }

  @override
  String get tapToExpand => 'Tap to expand';

  @override
  String get cacheManagement => 'Cache';

  @override
  String get imageCacheSize => 'Image Cache';

  @override
  String get clearCache => 'Clear Cache';

  @override
  String get cacheCleared => 'Cache cleared successfully';

  @override
  String get cacheClearFailed => 'Failed to clear cache';

  @override
  String get calculating => 'Calculating...';

  @override
  String get rename => 'Rename';

  @override
  String get renameSession => 'Rename Session';

  @override
  String get sessionRenamed => 'Session renamed';

  @override
  String get likeAllTracks => 'Like All Tracks';

  @override
  String likeAllTracksConfirm(int count) {
    return 'Add $count tracks to your Liked Songs?';
  }

  @override
  String get tracksAlreadyLiked => 'All tracks are already liked';

  @override
  String tracksLiked(int count) {
    return '$count tracks added to Liked Songs';
  }

  @override
  String get addToPlaylist => 'Add to Playlist';

  @override
  String get createPlaylistFromSession => 'Create Playlist from This';

  @override
  String createPlaylistConfirm(String name, int count) {
    return 'Create a Spotify playlist \"$name\" with $count tracks?';
  }

  @override
  String playlistCreated(String name) {
    return 'Playlist \"$name\" created';
  }

  @override
  String get playlistCreationFailed => 'Failed to create playlist';

  @override
  String get checkingLikedStatus => 'Checking liked status...';

  @override
  String get likingTracks => 'Liking tracks...';

  @override
  String get creatingPlaylist => 'Creating playlist...';

  @override
  String get moveUp => '上に移動';

  @override
  String get moveDown => '下に移動';

  @override
  String get pinToTop => '最前面に固定';

  @override
  String get unpinFromTop => '最前面を解除';

  @override
  String lastPlayed(String time) {
    return '最後に再生：$time';
  }

  @override
  String get moreArtists => 'その他のアーティスト';

  @override
  String get expand => '展開';

  @override
  String get collapse => '閉じる';

  @override
  String minutesAgo(int count) {
    return '$count分前';
  }

  @override
  String hoursAgo(int count) {
    return '$count時間前';
  }

  @override
  String daysAgo(int count) {
    return '$count日前';
  }

  @override
  String get performance => 'パフォーマンス';

  @override
  String get gpuAcceleration => 'GPUアクセラレーション';

  @override
  String get gpuAccelerationDesc => 'GPUでアニメーションを滑らかに';

  @override
  String get gpuAccelerationHint =>
      '波形アニメーションを滑らかにするためにGPUアクセラレーションを有効にします。グラフィックの問題が発生した場合や、専用GPUがない場合は無効にしてください。';

  @override
  String get pinSession => '上にピン留め';

  @override
  String get unpinSession => 'ピン留めを解除';

  @override
  String get pinSessionHint => '最大3つのセッションをピン留め';

  @override
  String get sessionPinned => 'セッションをピン留めしました';

  @override
  String get sessionUnpinned => 'ピン留めを解除しました';

  @override
  String get aboutVersion => 'バージョン';

  @override
  String get aboutPrivacySecurity => 'プライバシーとセキュリティ';

  @override
  String get aboutDeveloper => '開発者';

  @override
  String get aboutGitHub => 'GitHub';

  @override
  String get aboutStarProject => 'プロジェクトにスターを';

  @override
  String get aboutTwitter => 'X (Twitter)';

  @override
  String get aboutFollowUpdates => '最新情報をフォロー';

  @override
  String get aboutPoweredBySpotify => 'Spotifyを使用';

  @override
  String get aboutUsesSpotifyApi => 'Spotify Web APIを使用';

  @override
  String get privacySecureStorage => '安全なローカルストレージ';

  @override
  String get privacySecureStorageDesc =>
      'APIクレデンシャルは暗号化され、デバイスにのみ保存されます。外部サーバーに送信されることはありません。';

  @override
  String get privacyDirectConnection => 'Spotifyへの直接接続';

  @override
  String get privacyDirectConnectionDesc =>
      'このアプリはSpotifyの公式APIに直接接続します。中間サーバーを経由してデータを送信することはありません。';

  @override
  String get privacyNoDataCollection => 'データ収集なし';

  @override
  String get privacyNoDataCollectionDesc =>
      '使用状況分析、再生履歴、個人情報を収集、保存、送信することはありません。';

  @override
  String get privacyOAuthSecurity => 'OAuthセキュリティ';

  @override
  String get privacyOAuthSecurityDesc =>
      '認証はポート8888-8891、8080、または3000のローカルHTTPサーバーを使用し、stateパラメータによるCSRF保護を行います。';

  @override
  String get privacyYouControl => 'データはあなたの管理下に';

  @override
  String get privacyYouControlDesc =>
      '設定ページからいつでもクレデンシャルを削除できます。アプリをアンインストールすると、すべての保存データが削除されます。';

  @override
  String get close => '閉じる';

  @override
  String get welcomeToFullStop => 'FullStopへようこそ';

  @override
  String get updateCredentials => 'クレデンシャルを更新';

  @override
  String get connectSpotifyToStart => 'Spotifyアカウントを接続して開始';

  @override
  String get updateSpotifyCredentials => 'Spotify APIクレデンシャルを更新';

  @override
  String get credentialsSecurelyStored => 'クレデンシャルはデバイスにのみ安全に保存されます';

  @override
  String get privacyPolicy => 'プライバシーポリシー';

  @override
  String get step1CreateApp => 'ステップ1：Spotifyアプリを作成';

  @override
  String get openDeveloperDashboard => 'Spotify開発者ダッシュボードを開く';

  @override
  String get openDeveloperDashboardHint =>
      '下のボタンをクリックして、ブラウザでSpotify開発者ダッシュボードを開きます。';

  @override
  String get createNewApp => '新しいアプリを作成';

  @override
  String get createNewAppDesc =>
      '「Create App」をクリックして入力：\n• App name：任意の名前（例：「My Focus App」）\n• App description：個人使用\n• Website：空欄またはURLを入力\n• 「Web API」オプションをチェック';

  @override
  String get createNewAppDescShort =>
      '「Create App」をクリックして以下のフィールドを入力し、「Web API」オプションをチェック。';

  @override
  String get appNameLabel => 'App name（アプリ名）';

  @override
  String get appNameCopied => 'アプリ名をコピーしました！';

  @override
  String get appDescriptionLabel => 'App description（アプリの説明）';

  @override
  String get appDescriptionCopied => 'アプリの説明をコピーしました！';

  @override
  String get redirectUriLabel => 'Redirect URI（リダイレクトURI）';

  @override
  String get setRedirectUri => 'リダイレクトURIを設定（重要！）';

  @override
  String get setRedirectUriDesc => '「Redirect URIs」フィールドに以下のURIを追加：';

  @override
  String get copy => 'コピー';

  @override
  String get redirectUriCopied => 'リダイレクトURIをコピーしました！';

  @override
  String get redirectUriWarning => '貼り付け後「Add」をクリックし、下の「Save」をクリック！';

  @override
  String get step2EnterCredentials => 'ステップ2：クレデンシャルを入力';

  @override
  String get updateYourCredentials => 'クレデンシャルを更新';

  @override
  String get findCredentialsHint =>
      'Spotify開発者ダッシュボードのアプリ設定ページでクレデンシャルを確認できます。';

  @override
  String get modifyCredentialsHint => '以下のクレデンシャルを変更してください。正しい場合は変更不要です。';

  @override
  String get enterClientId => 'Client IDを入力';

  @override
  String get clientIdRequired => 'Client IDは必須です';

  @override
  String get clientIdTooShort => 'Client IDが短すぎます';

  @override
  String get enterClientSecret => 'Client Secretを入力';

  @override
  String get clientSecretRequired => 'Client Secretは必須です';

  @override
  String get clientSecretTooShort => 'Client Secretが短すぎます';

  @override
  String get whereToFindCredentials => 'どこで見つけられますか？';

  @override
  String get whereToFindCredentialsDesc =>
      'SpotifyアプリのSettingsページでClient IDが表示されます。「View client secret」をクリックしてシークレットを表示します。';

  @override
  String get step3ReadyToConnect => 'ステップ3：接続準備完了';

  @override
  String get credentialsSaved => 'クレデンシャルを保存しました！';

  @override
  String get waitingForCredentials => 'クレデンシャルを待機中';

  @override
  String get credentialsSavedDesc =>
      'Spotify APIクレデンシャルが安全に保存されました。Spotifyに接続できます。';

  @override
  String get waitingForCredentialsDesc => 'ステップ2に戻ってクレデンシャルを入力してください。';

  @override
  String get spotifyPremiumRequired => 'Spotify Premiumが必要';

  @override
  String get spotifyPremiumRequiredDesc =>
      'このアプリの再生コントロール機能にはSpotify Premiumが必要です。';

  @override
  String get back => '戻る';

  @override
  String get nextEnterCredentials => '次へ：クレデンシャルを入力';

  @override
  String get saveCredentials => 'クレデンシャルを保存';

  @override
  String get updateCredentialsButton => 'クレデンシャルを更新';

  @override
  String get connectToSpotify => 'Spotifyに接続';

  @override
  String get reconfigureApiCredentials => 'APIクレデンシャルを再設定';

  @override
  String get changeClientIdSecret => 'Client IDとSecretを変更';

  @override
  String get reconfigureDialogTitle => 'APIクレデンシャルを再設定';

  @override
  String get reconfigureDialogContent =>
      '現在のAPIクレデンシャルを削除してログアウトします。\n\nClient IDとSecretを再入力する必要があります。';

  @override
  String get reconfigure => '再設定';

  @override
  String get redirectUriForSpotifyApp => 'SpotifyアプリのリダイレクトURI';

  @override
  String get spotifyApi => 'Spotify API';

  @override
  String configured(String clientId) {
    return '設定済み（$clientId）';
  }

  @override
  String get notConfigured => '未設定';

  @override
  String get llmOpenAiCompatible => 'OpenAI互換API';

  @override
  String get llmOpenAiCompatibleDesc =>
      'OpenAI、Ollama、その他のOpenAI互換APIで動作します。\nOllamaなどのローカルモデルではAPI Keyは不要です。';

  @override
  String get enableAiFeatures => 'AI機能を有効化';

  @override
  String get smartPlaylistCuration => 'LLMによるスマートプレイリストキュレーション';

  @override
  String get llmBaseUrl => 'Base URL *';

  @override
  String get llmBaseUrlHint => 'https://api.openai.com/v1';

  @override
  String get llmBaseUrlHelper => '/chat/completionsが自動的に追加されます';

  @override
  String get llmModel => 'モデル *';

  @override
  String get llmModelHint => 'gpt-4';

  @override
  String get llmModelHelper => '例：gpt-4o-mini、llama3、qwen2、gemini-pro';

  @override
  String get llmApiKey => 'API Key（オプション）';

  @override
  String get llmApiKeyHint => 'sk-...';

  @override
  String get llmApiKeyHelper => 'Ollamaなどのローカルモデルでは空欄可';

  @override
  String get test => 'テスト';

  @override
  String get llmExamples => '例：';

  @override
  String llmConfigured(String model) {
    return 'LLM設定済み：$model';
  }

  @override
  String get llmConfigSaved => 'LLM設定を保存しました';

  @override
  String get llmConfigSaveFailed => '設定の保存に失敗しました';

  @override
  String get llmBaseUrlModelRequired => 'Base URLとモデルは必須です';

  @override
  String llmTesting(String url) {
    return 'テスト中：$url';
  }

  @override
  String llmTestSuccess(String response) {
    return '成功！レスポンス：$response...';
  }

  @override
  String get request => 'リクエスト：';

  @override
  String get llmError404 => 'エラー404：エンドポイントが見つかりません。API Endpoint URLを確認してください';

  @override
  String get llmError401 => 'エラー401：無効なAPI Keyまたは未認証アクセス';

  @override
  String get llmError403 => 'エラー403：アクセスが禁止されています。API Keyの権限を確認してください';

  @override
  String get llmError429 => 'エラー429：レート制限を超えました。しばらく待ってから再試行してください';

  @override
  String get llmErrorServer => 'サーバーエラー：APIサーバーが一時的に利用できません';

  @override
  String get llmErrorTimeout => '接続タイムアウト：サーバーの応答に時間がかかりすぎています';

  @override
  String get llmErrorConnection => '接続失敗：ネットワークとプロキシ設定を確認してください';

  @override
  String get miniPlayer => 'ミニプレーヤー';

  @override
  String get exitMiniPlayer => 'ミニプレーヤーを終了';
}
