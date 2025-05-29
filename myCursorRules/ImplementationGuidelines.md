# UPDATE画面 実装ガイドライン

このファイルは、UPDATE画面の開発における「避けるべき実装方法（NG例）」と「推奨する実装方法（OK例）」、および可変高さページングUIに関するDeepResearchまとめを記載したものです。
AIや開発者は必ず本ガイドラインを参照し、同じ失敗を繰り返さず、推奨パターンに従って実装してください。

---

## 注意
- 「セクションごとにUICollectionViewを複数配置する」構成は、現状の実装・要件では問題ありません。
- 「ModelとViewのロジックが密結合」も、UPDATE画面の現状では許容範囲とします。
- 今後、パフォーマンスや保守性に問題が出た場合は再検討します。

---

## NG例（やってはいけない実装）

### 1. セルの高さ計算やレイアウトをpreferredLayoutAttributesFittingで都度再計算
- **該当ファイル例**: WeeklySectionCell, MVBannerCell, TitleListCell, RankingSectionCell, BannerSectionCell
- **内容**: 各セルで`preferredLayoutAttributesFitting(_:)`をオーバーライドし、`layoutIfNeeded()`や`frame`の再計算を頻繁に行っている。
- **問題点**: レイアウトパフォーマンス低下、レイアウトループや高さ計算のバグ発生リスク
- **代替案**: CompositionalLayoutの`NSCollectionLayoutSize`で高さ・幅を完結させ、セル側での都度再計算は最小限にする。

### 2. contentViewをremoveFromSuperviewして独自ViewをaddSubview
- **該当ファイル例**: MVBannerCell, TitleListCell, RankingSectionCell, BannerSectionCell, LatestUpdateCell, PRBannerCell, MinorLanguageBannerCell, CarouselBannerCell
- **内容**: セルの初期化時に`contentView.removeFromSuperview()`を呼び、独自のViewを`addSubview`している。
- **問題点**: UICollectionViewCellの本来のライフサイクルやレイアウト管理を壊すリスク、Appleの推奨パターンから外れる
- **代替案**: 必ず`contentView`の上にサブビューを追加し、`contentView`自体は削除しない

### 3. CompositionalLayoutの親子構造＋orthogonalScrollingBehavior.paging＋可変コンテンツ量による高さ再計算問題
- **該当ファイル例**: WeeklySectionCell（子）、UpdateViewController（親）
- **内容**: 親UICollectionViewでWeeklySectionCellを.estimatedの高さで配置し、その中でもCompositionalLayout（UICollectionView）を使っている。親のViewでWeeklySectionCellのセクションを`orthogonalScrollingBehavior = .groupPagingCentered`でページングし、各ページ（曜日）ごとにコンテンツ量が可変。
- **問題点**: コンテンツ量の多いページから少ないページにスワイプした際、高さ再計算がうまくいかず、WeeklySectionとその下のセクションの間に余白ができてしまう。考えうる修正は一通り試したが解消できなかった。
- **代替案・注意点**: CompositionalLayoutの親子構造＋orthogonalScrollingBehavior.paging＋可変高さの組み合わせはApple公式でも未解決の挙動が多く、仕様上の限界がある可能性が高い。どうしても必要な場合は、ページごとに高さを固定する・高さを事前計算しておく・ページングをやめる等の根本的な設計見直しを検討する。この構成は今後も避けること。

---

## OK例（推奨する実装・今後やってほしい方法）

### 1. MVVMパターンの採用（必要に応じて）
- Model, View, ViewModelの責務を明確に分離し、テストや保守性を高める
- ViewModelでデータ整形・ロジックを担い、Viewは表示に専念する

### 2. セル・Viewの再利用
- `dequeueReusableCell`やViewの再利用を徹底し、パフォーマンスを最適化する

### 3. 横スクロールページング＋セル内縦スクロールビュー（推奨）
- **ページごとに高さが異なる場合は、UIPageViewController方式が最も自然で安全**
    - 各ページ（子ViewController）が自身の高さを計算し、親View（例: WeeklySectionView）に「高さが変わった」と伝える
    - 親ViewがheightConstraint.constantを更新し、layoutIfNeeded()で反映
    - ページごとに高さが違っても、親Viewの高さが自動で切り替わるのでUIが安定
    - UIKit的にも推奨されるやり方
    - 実装例（擬似コード）:
      ```swift
      // 子ページVCで高さが変わったら
      heightChangedHandler?(contentHeight)
      // 親(WeeklySectionView)がそれを受けて
      self.heightConstraint.constant = contentHeight
      UIView.animate(withDuration: 0.2) { self.layoutIfNeeded() }
      ```
- **UICollectionView(horizontal)方式でもページごとに高さ可変は一応可能だが、工夫と注意が必要**
    - 各セル（ページ）の内容を先に計算し、必要な高さを配列等で持っておく
    - スクロールやページ切り替え時に「表示中のセルの高さ」に合わせて親Viewの高さ制約を変える
    - collectionView(_:layout:sizeForItemAt:) で CGSize(width: ..., height: currentPageHeight) のように返す
    - ただし高さの伝播タイミングやレイアウト反映が難しく、表示が一瞬ずれる・余白が出るなどの課題が出やすい
    - 実運用では「最大ページの高さで固定」することが多い
- **ViewControllerの中に、UIPageViewControllerのセクションとCollectionViewのセクションが並ぶ構成も推奨**
    - 例：上部にタブ＋ページング、下部に通常のリストやバナーなど

#### まとめ（実用的アドバイス）
- 親Viewの高さをページごとに変えることは「できる」
- 実装負担・見た目の安定性を考えると、UIPageViewController方式が断然おすすめ
- UICollectionView(horizontal)でどうしても可変高さをやりたい場合は「高さ計算・伝播・制約の調整」を頑張る必要あり
- 一瞬余白が出るなどのUI的ブレは避けづらい

---

## Deep Researchまとめ

### CompositionalLayout横スクロールページでページごとに高さを可変にしたい場合の知見

#### 背景・課題
- iOS 14以降のUICollectionViewCompositionalLayoutで、曜日ごとなど「横スクロールページング」UIを実装する際、各ページ（グループ）ごとにコンテンツ量が異なり、高さも可変にしたいという要望がある。
- CompositionalLayoutのorthogonalScrollingBehavior = .groupPagingCenteredを使うと、セクション全体の高さは固定または推定値で決め打ちされ、ページごとに高さを変えることは標準では想定されていない。
- そのため「全ページが一番高いコンテンツの高さで余白が出る」または「高さが足りないページでは内容がはみ出す」などの問題が起こる。

#### 一般的なアプローチ
- セルやグループのheightDimensionに.estimated(X)を指定し、Auto Layoutによる自己サイズ調整を利用する。
- 各セルのAuto Layout制約をしっかり設定し、内容に応じて高さが可変になるようにする。
- 例:
```swift
let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(120))
let item = NSCollectionLayoutItem(layoutSize: itemSize)
let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(450))
let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item1, item2, ...])
let section = NSCollectionLayoutSection(group: group)
section.orthogonalScrollingBehavior = .groupPagingCentered
```

#### 想定される制限・問題点
- iOS 14系のバグ: 横スクロール＋.estimatedサイズの組み合わせで、初期表示時にセルが正しく包まれない、タップやスクロールが効かない等の不具合が報告されている。
- セクション高さが推定値のまま固定される: 実際のセル内容が推定値より大きくてもスクロールビュー自体の高さは更新されず、内容が切れる場合がある。逆に推定値を大きくすると余白が生じる。
- Auto Layout競合: 推定サイズ利用時に制約競合やレイアウトジャンプが発生しやすい。
- Apple公式も推奨していない: AppleのサンプルやWWDCでも横スクロールセクションは基本的に固定高さで設計されている。

#### 回避策・代替案
- 最大高さで固定する: 一番高さが必要なページに合わせてセクション高さを固定し、他のページでは余白が出ることを許容する（Apple公式もこの方針）。
- ページごとにセクションを分ける: ページ数が少ない場合は、各ページごとにセクションを分けて表示/非表示を切り替える。ただし横スワイプの自前実装が必要。
- UIPageViewControllerやネストしたコレクションビューの利用: ページ単位でUIViewControllerを切り替える、または外側を横スクロール・内側を縦スクロールのネスト構成にする。ただし複雑化・パフォーマンス負荷増に注意。
- UI設計の見直し: 各ページの高さが大きく異なりすぎないようUIを調整する、推定高さを十分大きめに設定する、ページ遷移時にレイアウトをinvalidateする等の工夫も有効。

#### 結論
- 現状のUIKitでは「横スクロール＋ページごとに高さ可変」は制約が多く、完全な実現は困難。
- 安全策は「最大高さで固定」または「UI設計を統一高さに寄せる」こと。
- どうしても実現したい場合は、上記の回避策や実装上の工夫を慎重に検討・テストすること。

---

### Swiftで可変高さの横スクロールページングUIを実現する方法

#### 課題: CompositionalLayoutでの可変高さページングの困難
- UICollectionViewCompositionalLayoutでは各ページごとに高さが異なるレイアウトを扱うのが難しく、デザイン上高さ固定が許容されない場合は適切に対応できません。
- Compositional Layoutはセクション内のアイテムサイズをあらかじめ決める必要があり、ページ（曜日）ごとにコンテンツ高さが変動するケースではレイアウト計算が複雑になります。
- そのため、CompositionalLayoutで横方向ページングを実現するよりも、ページング用のコンテナと縦スクロールのリストをネストさせるアプローチが現実的です。

#### StackOverflowの指摘
- ページ数が少ない場合はUIPageViewControllerでのページングが簡単で、ページ数が多い場合はUICollectionViewでの水平方向ページングが適しています。
- どちらの場合も各ページ内で縦スクロールが必要なら、ページ(ViewController)内またはセル内にUIScrollView/UICollectionViewを配置する構成になります。
- ページ数が多い状態で多数のスクロールビューをネストするとパフォーマンス上好ましくないため、ページ数に応じて適切な方式を選ぶと良いでしょう。

#### 解決策1: UIPageViewController＋子UIViewControllerによるページング
- iOS標準のUIPageViewControllerを使えば、横スワイプでページを切り替えるUIを簡単に構築できます。
- 各曜日ページを独立したUIViewControllerとして実装し、それらをUIPageViewControllerに登録する方式です。
- 各ページは縦方向のスクロールビュー（UITableViewやUICollectionViewなど）を持てるため、ページごとに高さが異なっても問題ありません。
- スクロール競合やパフォーマンス対策として、UIGestureRecognizerの優先度調整やページキャッシュの活用が有効です。
- SmartNews風のタブUIや、曜日ごとに独立したページを持つUIに最適です。

#### 解決策2: UICollectionView（横方向ページング）＋セル内に縦スクロールビュー
- 横スクロールのUICollectionViewを用意し、各セルに曜日ページのコンテンツを配置します。
- セル内には縦方向にスクロール可能なビュー（UITableViewやUICollectionView、UIScrollView＋UIStackViewなど）をネストします。
- セルに子ViewControllerのビューを埋め込む方法も有効で、各ページの状態管理やUI分離がしやすくなります。
- ページ数が少ない場合は全ページ分のセルやViewControllerを保持しておくと、状態復元やパフォーマンス面で有利です。
- スクロールジェスチャーの競合対策や、prefetchDataSourceによるプリフェッチも有効です。

#### 実装上の注意点まとめ
1. UIPageViewController方式はページ数が少ない場合に有力な選択肢で、各ページを独立したUIViewControllerとして管理できます。スクロール競合を避けるためにはジェスチャーの優先度制御が有効であり、パフォーマンス向上にはページキャッシュによるプリロードが重要です。
2. UICollectionViewネスト方式はページ数が多い場合や柔軟な再利用が必要な場合に有効ですが、実装複雑度が増します。セル再利用による状態リセットに注意し、必要に応じて全ページを保持するか状態復元の処理を追加してください。
3. デザイン面の考慮: 各ページコンテンツの高さが異なる場合でも、親コンテナの高さは一定に保つのが通常です。親と子のスクロールが両方存在する場合、iOSではステータスバータップでスクロールトップに戻る操作に影響が出ることがあります。UIPageViewController内の複数スクロールビューでは、表示中以外の子スクロールビューのscrollsToTopをfalseに設定する必要がある、といった知見も報告されています。

#### 参考資料
- Stack Overflow – ネストしたスクロールビューのページングに関するQ&A
- Qiita記事『UICollectionViewControllerとUIPageViewControllerでSmartNewsっぽいUIを実現』
- Qiita記事『UIPageViewController内でUITableViewのスワイプ削除を実装する』
- Qiita記事『スワイプ移動できるページUIを50行で実装する』
- Yahoo! JAPAN Tech Blog『CompositionalLayoutによる複雑UI実現』

---

## 追加・変更履歴
- 2024/06/10: 新規作成
- 2024/06/10: NG例1・3を現状は許容とし、注意書きを追加 