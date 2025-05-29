# 画面・セクションごとのファイル配置ルール

このファイルは、プロジェクト内で新たに画面やセクションを追加した際に、
ディレクトリ・ファイル配置ルールを都度手動で追記・更新するためのものです。

---

## テンプレート

```
## [画面名]
- 概要: [画面の説明]
- ディレクトリ: `CompositionalLayoutTutorial/[画面名]/`
- Model: `[画面名]/Model/〇〇Model.swift`
- View: `[画面名]/View/〇〇View.swift`
- Component: `[画面名]/View/Component/〇〇/〇〇View.swift`
- 追加日: yyyy/mm/dd
- 備考: [特記事項]
```

---

## 既存画面ルール例

### UPDATE画面
- 概要: マンガアプリの最新アップデート情報を表示する画面
- ディレクトリ: `CompositionalLayoutTutorial/Update/`
- Model:
    - `Update/Model/UpdateScreenModel.swift`
    - `Update/Model/DaySectionModel.swift`
    - `Update/Model/RankingModel.swift`
    - `Update/Model/PreviewModel.swift`
    - `Update/Model/BannerModel.swift`
- View:
    - `Update/View/UpdateViewController.swift`
    - `Update/View/UpdateView.swift`
- Component:
    - `Update/View/Component/Header/UpdateHeaderView.swift`
    - `Update/View/Component/Banner/PRBannerView.swift`
    - `Update/View/Component/Banner/MVBannerView.swift`
    - `Update/View/Component/Banner/MinorLanguageBannerView.swift`
    - `Update/View/Component/Weekly/WeeklySelectorView.swift`
    - `Update/View/Component/Weekly/WeeklyTabCell.swift`
    - `Update/View/Component/Weekly/WeeklyListView.swift`
    - `Update/View/Component/Weekly/WeeklyItemCell.swift`
    - `Update/View/Component/Ranking/RankingSectionView.swift`
    - `Update/View/Component/Ranking/RankingTabView.swift`
    - `Update/View/Component/Ranking/RankingCell.swift`
    - `Update/View/Component/Preview/PreviewSectionView.swift`
    - `Update/View/Component/Preview/PreviewCell.swift`
    - `Update/View/Component/Carousel/CarouselBannerView.swift`
    - `Update/View/Component/Banner/AdBannerView.swift`
- 追加日: 2024/06/10
- 備考: 仕様詳細は`UPDATE画面仕様.md`を参照

---

## 追加・変更履歴
- 2024/06/10: 本ファイル新規作成 