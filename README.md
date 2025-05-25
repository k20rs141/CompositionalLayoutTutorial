# CompositionalLayoutTutorial

## モックサーバの環境構築
ローカルでサーバを立てるために今回はjson-serverを導入

モークサーバの構築については以下のNotionに記載

https://link-u.notion.site/json-server-fa3c295aeda94f1692daf5bb6022cabb?pvs=4

## 備考
compositionalLayoutのみで実装できないか試してみたところページングさせるセクションが固定値であれば問題ないが、可変的にするとスワイプ時にコンテンツの高さがうまく反映されず余白ができてしまう

<img src="https://github.com/user-attachments/assets/f9519c50-38d4-427a-b8fe-b71b01deff2a" width = "25%">

## 解決策
Compositional Layoutを使用した実装ではなく横スクロール可能なセクションはUIPageViewControllerを使用し、その下のセクションはCollectionViewて組む実装にする

## 動作確認
### iPad OS 18.0
- iPhone 16
### iOS 18.1
- iPhone 11 実機
