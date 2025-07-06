# github-cli-handson

GitHub CLIのハンズオン用リポジトリです。

## 🚀 機能

### GitHub Actions Lint機能

このリポジトリでは、GitHub Actionsワークフローの品質を保つための自動lint機能を実装しています。

#### 自動チェック項目

1. **YAML構文チェック**
   - GitHub Actionsの構文が正しいかチェック
   - yamllintを使用した詳細な構文検証

2. **環境変数使用チェック**
   - 環境変数の直接参照を禁止
   - 環境変数はダブルクォーテーションで囲むことを必須
   - ハードコードされたシークレットの検出
   - 推奨パターン（secrets、明示的定義）の確認

3. **セキュリティチェック**
   - パスワードやトークンのハードコード検出
   - GitHub Secretsの適切な使用を推奨

#### 実行タイミング

- **Pull Request作成時**: ワークフローファイルが変更された場合
- **Push時**: main/developブランチへのプッシュ時
- **手動実行**: ワークフローを手動で実行可能

#### 使用方法

1. **自動実行**: PRを作成すると自動的にlintが実行されます
2. **手動実行**: GitHubのActionsタブから手動で実行可能
3. **ローカル実行**: pre-commitフックを使用してローカルでチェック

```bash
# pre-commitフックのセットアップ
pre-commit install

# 手動でlint実行
pre-commit run --all-files
```

#### コーディング規約

詳細なコーディング規約は [`.github/CONTRIBUTING.md`](.github/CONTRIBUTING.md) を参照してください。

## 📁 ファイル構成

```
.github/
├── workflows/
│   ├── lint.yml              # メインのlintワークフロー
│   └── environment.yml       # サンプルワークフロー
├── CONTRIBUTING.md           # コーディング規約
scripts/
├── check-github-actions.sh   # カスタムチェックスクリプト
.pre-commit-config.yaml       # pre-commit設定
.yamllint                     # yamllint設定
```

## 🔧 セットアップ

1. リポジトリをクローン
2. pre-commitフックをインストール
3. ワークフローファイルを作成・編集
4. PRを作成して自動lintを確認

## 📝 ライセンス

MIT License
