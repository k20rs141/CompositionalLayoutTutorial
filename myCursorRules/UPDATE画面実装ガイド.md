# UPDATE画面 実装ガイド（UpdateV2対応）

---

## 目次
1. 概要・全体方針
2. ディレクトリ・ファイル構成
3. データ設計・API連携
4. UI/UX設計・各セクション実装方針
5. 実装上の注意点・ベストプラクティス

---

## 1. 概要・全体方針

- 曜日セクションは **UIPageViewController** を用い、各曜日ごとに独立したViewControllerを配置し、その中に **UICollectionView（CompositionalLayout）** を実装
- ランキング・プレビュー・タイトルリスト・バナー等のセクションは、**UICollectionView＋CompositionalLayout** で実装
- 各パーツ（Cell/SectionView）は既存のUpdateディレクトリ配下の実装済みCellを参照・再利用
- 新規実装は **UpdateV2ディレクトリ** 配下にまとめ、Updateディレクトリと分離して管理

---

## 2. ディレクトリ・ファイル構成

- UpdateV2/
    - View/
        - UpdateV2ViewController.swift（画面全体の親VC、UIPageViewController管理）
        - WeeklyPageViewController.swift（曜日ごとのページVC）
        - その他必要なViewController
    - ViewModel/
        - UpdateV2ViewModel.swift
        - WeeklyPageViewModel.swift
    - Model/
        - 既存Modelを参照
- 既存のCell/SectionView（例：WeeklySectionCell, MVBannerCell, PRBannerCell, TitleListCell, RankingSectionCell, PreviewSectionCell等）はUpdateディレクトリ配下を参照

---

## 3. データ設計・API連携

- 既存のModel（Update/Model/UpdateModels.swift等）を活用し、ViewModelでデータ整形・状態管理
- 曜日ごとのデータはViewModelで分割し、各曜日ViewControllerに渡す
- 日付・時刻変換やバナー表示制御などのロジックもViewModelで一元管理
- PRバナーやマイナー言語バナーなど、データが空の場合は非表示
- アプリ初回DLから7日経過判定などはローカルストレージ（UserDefaults等）で管理

---

## 4. UI/UX設計・各セクション実装方針

### 4.1 曜日セクション
- UIPageViewController＋各曜日ViewController＋CollectionView（CompositionalLayout）
- 曜日タブは横スクロール・タップ・スワイプで切り替え、スティッキーヘッダーで固定
- MVタイトル数によるカルーセルバナー表示分岐もViewModelで制御

### 4.2 各曜日ページ内
- MVバナー、PRバナー、タイトルリスト、カルーセルバナー、マイナー言語バナー等をCollectionViewの各Cellとして表示
- 既存のCell（MVBannerCell, PRBannerCell, TitleListCell, CarouselBannerCell, MinorLanguageBannerCell, LatestUpdateCell, DaySelectorCell等）を再利用

### 4.3 ランキング・プレビュー・タイトルリスト・バナーセクション
- 画面下部は従来通りUICollectionView＋CompositionalLayoutで実装
- RankingSectionCell, PreviewSectionCell, BannerSectionCell等を再利用

---

## 5. 実装上の注意点・ベストプラクティス

- セルの高さ計算はCompositionalLayoutのNSCollectionLayoutSizeで完結させ、セル側での都度再計算は避ける
- contentViewの上にサブビューを追加し、contentView自体は削除しない
- 横スクロールページング＋セル内縦スクロールビューはUIPageViewController方式を推奨
- ViewModelでデータ整形・表示制御を一元化し、Viewは表示に専念
- 各種バッジやアイコンはAssetsで一元管理
- アクセシビリティ・パフォーマンスにも配慮

---

## UIScrollView＋UIPageViewController＋UICollectionView構成に関する注意事項

### 構成概要
- 親ビューとしてUIScrollViewを用意し、その中にUIPageViewController（曜日ごとのページ）とUICollectionView（ランキング・プレビュー等）を縦に並べて配置する構成。

### 採用理由
- デザイン要件上、曜日ごとのページ（UIPageViewController）はページごとに高さが可変であり、全体を縦スクロールでつなげる必要があるため。

### 実装上の注意点・推奨事項
- UIScrollViewの中にUIScrollView系（UIPageViewController/UICollectionView）を入れる場合、**スクロール競合や高さ調整の問題が発生しやすい**ため、以下の点に注意すること。
    - 親UIScrollViewの`isScrollEnabled`はfalseにし、子のスクロールのみ有効にする（親は高さ調整用ラッパーとして使う）。
    - UIPageViewControllerのページ切り替え時に、**現在のページの高さを計算し、親UIScrollViewの高さ制約を都度更新**すること。
    - UICollectionViewの`contentSize`が変化した場合も、親の高さを更新すること。
    - スクロールの伝播や優先順位は`gestureRecognizer(_:shouldRecognizeSimultaneouslyWith:)`等で適切に制御すること。
    - Apple公式も「UIScrollViewの中にUIScrollView」は非推奨としているため、**この構成はやむを得ない場合のみ採用し、十分なテスト・検証を行うこと**。
- ページごとに高さが異なる場合は、**ページ切り替え時に親の高さをアニメーションで変える**方式を推奨。
- スクロールの不具合や高さの不一致が発生しやすいため、**実装時は必ず実機・複数端末での動作確認を徹底すること**。

---

このガイドをもとに、UpdateV2ディレクトリ配下での新規実装を進めてください。
ご要望・修正点があればご指摘ください。 