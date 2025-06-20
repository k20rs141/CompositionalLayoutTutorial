# CompositionalLayoutTutorial - プロジェクト概要 / Project Overview

## プロジェクトの目的 / Project Purpose

このプロジェクトは、iOS の `UICollectionView` の `CompositionalLayout` を使用して複雑なレイアウトを実装するチュートリアルです。特に**横スクロール可能なセクションでのページング実装の課題**を解決することに焦点を当てています。

This project is a tutorial for implementing complex layouts using iOS `UICollectionView`'s `CompositionalLayout`, with a specific focus on solving **pagination challenges in horizontally scrollable sections**.

## アーキテクチャ / Architecture

### メインストラクチャ / Main Structure
```
CompositionalLayoutTutorial/
├── Update/                    # 初期実装 (MVC パターン)
├── UpdateV2/                  # 改良版実装 (MVVM + UIPageViewController)
├── API/                       # ネットワーク層
├── Extensions/                # ユーティリティ拡張
└── mock_server/              # ローカルモックサーバー
```

### 実装パターン比較 / Implementation Pattern Comparison

#### 1. Update フォルダー (初期実装 / Initial Implementation)
- **パターン**: MVC (Model-View-Controller)
- **構成**: `UpdateViewController.swift` + `UpdateViewModel.swift` + Models
- **課題**: CompositionalLayout のみでの実装では、可変高さのページングセクションで余白が発生

#### 2. UpdateV2 フォルダー (改良版 / Improved Implementation) 
- **パターン**: MVVM + UIPageViewController
- **構成**: `UpdateV2ViewController.swift` + `WeeklyPageViewController.swift` + ViewModels
- **解決策**: 横スクロールセクションに `UIPageViewController` を使用し、その他のセクションは `CompositionalLayout` で実装

## 主要コンポーネント / Key Components

### 1. タブバー構造 / Tab Bar Structure
```swift
// MainTabBarController.swift で定義
enum TabBarItem: Int, CaseIterable {
    case update    // UpdateV2ViewController (改良版)
    case hot       // UpdateViewController (初期版)
    case browse    // プレースホルダー
    case create    // プレースホルダー  
    case profile   // プレースホルダー
}
```

### 2. データモデル / Data Models
**主要な構造体**:
- `HomeSection`: メインのホームセクションデータ
- `WeeklySection`: 週間コンテンツ（曜日別）
- `RankingSection`: ランキングデータ
- `PreviewSection`: プレビュータブ
- `TitleListSection`: タイトルリスト
- `BannerSection`: バナー広告

### 3. セクションタイプ / Section Types
```swift
// UpdateV2で使用される主要セクション
enum Section: Int, CaseIterable, Hashable {
    case ranking      // ランキング
    case preview      // プレビュー
    case titleList    // タイトルリスト  
    case banner       // バナー
}
```

## API とデータ管理 / API and Data Management

### ネットワーク層 / Network Layer
- **フレームワーク**: Moya + Promises
- **エンドポイント**: `http://localhost:3000/api/mock/v1/home`
- **実装**: `APIProvider.swift` でシングルトンパターン

### モックサーバー / Mock Server
- **技術**: json-server (Node.js)
- **ポート**: 3000
- **データ**: `mock_server/datasource/db.json` (推測)

## 解決した技術的課題 / Technical Challenges Solved

### 問題 / Problem
CompositionalLayout のみでの実装では、ページングセクションが**固定値**であれば問題ないが、**可変的**にすると:
- スワイプ時にコンテンツの高さが正しく反映されない
- 不要な余白が発生する

### 解決策 / Solution
1. **横スクロールセクション**: `UIPageViewController` を使用
2. **その他のセクション**: `CompositionalLayout` を継続使用
3. **MVVM パターン**: データバインディングの改善

## 拡張機能 / Extensions

### カスタム拡張 / Custom Extensions
- `CGFloat+AspectRatio.swift`: アスペクト比計算
- `UIColor+Extension.swift`: カラーユーティリティ
- `UIImageView+Extension.swift`: 画像読み込み拡張
- `UILabel+Extension.swift`: ラベルスタイリング

## 動作確認環境 / Tested Environments
- **iPad OS 18.0**: iPhone 16
- **iOS 18.1**: iPhone 11 実機

## 主要な学習ポイント / Key Learning Points

1. **CompositionalLayout の限界と対処法**
2. **UIPageViewController との組み合わせ使用**
3. **MVVM パターンでのデータバインディング**
4. **Combine フレームワークの活用**
5. **モックサーバーを使ったローカル開発環境構築**

## プロジェクトの価値 / Project Value

このチュートリアルは、現実的なiOSアプリ開発で遭遇する**レイアウト実装の複雑さ**を解決する実践的なアプローチを提供しています。特に、単一の技術（CompositionalLayout）だけでは解決できない問題に対して、**複数技術の組み合わせ**による解決策を示している点が valuable です。