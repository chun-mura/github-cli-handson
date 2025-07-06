# GitHub Actions コーディング規約

## 環境変数の使用について

### ❌ 禁止事項

#### 1. 環境変数の直接参照

環境変数の直接参照は禁止されています：

```yaml
# 禁止: 環境変数の直接参照
- run: echo "${{ env.BRANCH }}"
- uses: actions/checkout@v4
  with:
    ref: "${{ env.BRANCH }}"
```

#### 2. 環境変数のクォーテーションなし定義

環境変数は必ずダブルクォーテーションで囲む必要があります：

```yaml
# 禁止: クォーテーションなし
env:
  BRANCH: main
  NODE_VERSION: 18
  DEPLOY_ENV: production

# 禁止: シングルクォーテーション
env:
  BRANCH: 'main'
  NODE_VERSION: '18'
```

### ✅ 推奨事項

#### 1. 明示的な環境変数定義

環境変数は必ずダブルクォーテーションで囲んでください：

```yaml
jobs:
  run:
    runs-on: ubuntu-latest
    env:
      BRANCH: "main"
      NODE_VERSION: "18"
      DEPLOY_ENV: "production"
    steps:
      - run: echo "${{ env.BRANCH }}"
      - uses: actions/checkout@v4
        with:
          ref: "${{ env.BRANCH }}"
```

#### 2. Secretsの使用

機密情報は必ずsecretsを使用してください：

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to production
        run: |
          echo "Deploying with token: ${{ secrets.DEPLOY_TOKEN }}"
```

#### 3. ワークフロー入力の使用

```yaml
on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'Environment to deploy to'
        required: true
        default: 'staging'

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Deploy
        run: echo "Deploying to ${{ inputs.environment }}"
```

### 検証

このリポジトリでは、PR時に自動的に以下のチェックが実行されます：

1. **YAML構文チェック**: GitHub Actionsの構文が正しいか
2. **環境変数チェック**: 禁止された環境変数の直接参照がないか
3. **セキュリティチェック**: secretsの適切な使用

### 例外

#### 環境変数の直接参照

以下の場合は環境変数の直接参照が許可されます：

- GitHub Actionsの組み込み環境変数（`GITHUB_*`）
- ワークフロー内で明示的に定義された環境変数
- ジョブレベルで定義された環境変数

#### ダブルクォーテーション

以下の場合はダブルクォーテーションが不要です：

- 真偽値（`true`、`false`）
- 数値（`0`、`1`、`18`など）
- ただし、文字列として扱いたい場合はダブルクォーテーションを使用してください

```yaml
# 許可: 真偽値と数値
env:
  ENABLE_FEATURE: true
  MAX_RETRIES: 3
  TIMEOUT: 30

# 推奨: 文字列として明示的に定義
env:
  ENABLE_FEATURE: "true"
  MAX_RETRIES: "3"
  TIMEOUT: "30"
```
