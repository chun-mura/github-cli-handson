#!/bin/bash

# GitHub Actions 環境変数チェックスクリプト
# このスクリプトは、GitHub Actionsワークフローでの環境変数の使用をチェックします

set -e

# 色付き出力のための関数
print_error() {
    echo -e "\033[31m❌ $1\033[0m"
}

print_warning() {
    echo -e "\033[33m⚠️  $1\033[0m"
}

print_success() {
    echo -e "\033[32m✅ $1\033[0m"
}

print_info() {
    echo -e "\033[34mℹ️  $1\033[0m"
}

# メイン処理
main() {
    echo "🔍 GitHub Actions 環境変数チェックを開始します..."
    echo ""

    local violations=0
    local warnings=0
    local checked_files=0

    # .github/workflows/ディレクトリ内のYAMLファイルをチェック
    for file in .github/workflows/*.yml .github/workflows/*.yaml; do
        if [ -f "$file" ]; then
            echo "📄 チェック中: $file"
            checked_files=$((checked_files + 1))

            # 1. 環境変数の直接参照チェック
            if grep -q "env\." "$file"; then
                print_error "環境変数の直接参照が検出されました: $file"
                echo "   禁止されたパターン: env\."
                echo "   推奨: 明示的な環境変数定義またはsecretsの使用"
                violations=$((violations + 1))
            fi

            # 2. 環境変数のダブルクォーテーション使用チェック
            echo "   環境変数のダブルクォーテーション使用をチェック中..."
            unquoted_vars=0

            # 環境変数定義でダブルクォーテーションが使用されていないものを検出
            while IFS= read -r line; do
                # 環境変数定義の行を検出（例: BRANCH: main）
                if echo "$line" | grep -q "^[[:space:]]*[A-Z_][A-Z0-9_]*:[[:space:]]*[^\"']"; then
                    # 値がダブルクォーテーションで囲まれていない場合
                    if ! echo "$line" | grep -q "^[[:space:]]*[A-Z_][A-Z0-9_]*:[[:space:]]*\""; then
                        print_error "環境変数がダブルクォーテーションで囲まれていません: $file"
                        echo "   問題のある行: $line"
                        echo "   推奨: ダブルクォーテーションで囲む (例: BRANCH: \"main\")"
                        unquoted_vars=$((unquoted_vars + 1))
                    fi
                fi
            done < "$file"

            if [ $unquoted_vars -gt 0 ]; then
                violations=$((violations + unquoted_vars))
            fi

            # 3. ハードコードされたシークレットチェック
            if grep -i -E "(password|token|secret|key|api_key).*:.*['\"][^'\"]{8,}['\"]" "$file"; then
                print_error "ハードコードされたシークレットが検出されました: $file"
                echo "   推奨: GitHub Secretsの使用"
                violations=$((violations + 1))
            fi

            # 4. 推奨パターンのチェック
            if grep -q "secrets\." "$file"; then
                print_success "secretsの使用が検出されました: $file"
            fi

            # 5. 明示的な環境変数定義のチェック
            if grep -A 10 "env:" "$file" | grep -q "^\s*[A-Z_][A-Z0-9_]*:"; then
                print_success "明示的な環境変数定義が検出されました: $file"
            fi

            # 6. ワークフロー入力の使用チェック
            if grep -q "inputs\." "$file"; then
                print_success "ワークフロー入力の使用が検出されました: $file"
            fi

            # 7. 許可された環境変数のチェック
            if grep -q "GITHUB_" "$file"; then
                print_info "GitHub組み込み環境変数の使用が検出されました: $file"
            fi

            echo ""
        fi
    done

    # 結果の報告
    echo "📊 チェック結果:"
    echo "   チェックしたファイル数: $checked_files"
    echo "   違反件数: $violations"
    echo "   警告件数: $warnings"
    echo ""

    if [ $violations -gt 0 ]; then
        print_error "合計 $violations 件の違反が検出されました"
        echo "📖 コーディング規約を確認してください: .github/CONTRIBUTING.md"
        exit 1
    else
        print_success "環境変数の使用に関する違反は検出されませんでした"
    fi

    if [ $checked_files -eq 0 ]; then
        print_warning "チェック対象のワークフローファイルが見つかりませんでした"
    fi
}

# スクリプトの実行
main "$@"
