# domain

`uta8a.net` の Cloudflare DNS Records を Terraform/Terragrunt で管理するリポジトリです。

## 構成
- `main.tf`: Cloudflare provider と DNS レコード定義
- `variables.tf`: 入力変数 (`cloudflare_api_token`, `cloudflare_zone_name`)
- `terragrunt.hcl` / `backend.tf`: S3 リモートステート設定
- `mise.toml`: ツールバージョンと運用タスク
- `scripts/environments.sh`: `.env.age` を復号して環境変数を読み込み

## 必要ツール

このリポジトリは `mise` 前提です。

```bash
mise install
```

`mise` により以下が導入されます: `terraform`, `terragrunt`, `gcloud`, `age`, `aws-cli`。

## 環境変数とシークレット

実行時に以下が必要です。
- `TF_VAR_cloudflare_api_token`: Cloudflare API token
- `TFSTATE_BUCKET`: Terraform state 保存先 S3 バケット
- `GCP_PROJECT_ID`: `age` 秘密鍵を取得する GCP プロジェクト

`mise run` 実行時は `scripts/environments.sh` が自動で:

1. GCP Secret Manager から `AGE_SECRET_NAME` (`age-master-secret`) を取得
2. `.env.age` を復号
3. 必要な環境変数を export

## 基本操作

初回または backend 更新後:

```bash
mise run init
```

変更確認:

```bash
mise run plan
```

適用:

```bash
mise run apply
```

> 注意: `apply` は `-auto-approve` 付きです。必ず先に `plan` を確認してください。

## DNS レコードを追加・変更する

`main.tf` の `locals.dns_records` を編集します。
- キー名は `blog_cname` / `infra_a` のように用途 + レコード種別
- `ttl`, `proxied`, `comment` を明示する
- 変更後は `mise run plan` で差分を確認

## よく使う補助コマンド

```bash
terraform fmt -check
terraform validate
mise run force-unlock <LOCK_ID>
```

## トラブルシュート

- `environments.sh: encrypted env file not found`: `.env.age` の配置を確認
- `GCP_PROJECT_ID is required`: `gcloud config set project <PROJECT_ID>` または環境変数設定
- state lock が解除できない: `mise run force-unlock <LOCK_ID>` を実行
- 事前にADCを構成する必要があります。
  - https://docs.cloud.google.com/docs/authentication/provide-credentials-adc?hl=ja#how-to

```sh
gcloud auth application-default login
# ADCが構成される
```
