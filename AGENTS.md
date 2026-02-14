# Repository Guidelines

## Project Structure & Module Organization
This repository manages Cloudflare DNS for `uta8a.net` using Terraform and Terragrunt.
- `main.tf`: provider setup and `cloudflare_dns_record` resources.
- `variables.tf`: input variables (`cloudflare_api_token`, `cloudflare_zone_name`).
- `terragrunt.hcl` + `backend.tf`: remote state configuration (S3 backend).
- `scripts/environments.sh`: decrypts `.env.age` and exports runtime environment variables.
- `scripts/publickey/`: key material reference files.

Keep Terraform definitions in root unless splitting into reusable modules becomes necessary.

## Build, Test, and Development Commands
Use `mise` tasks to ensure consistent tooling and environment loading:
- `mise run init`: initialize Terragrunt/Terraform backend and providers.
- `mise run plan`: preview infrastructure changes.
- `mise run apply`: apply changes (currently auto-approved).
- `mise run force-unlock <LOCK_ID>`: unlock a stuck Terraform state lock.

Useful local checks:
- `terraform fmt -check`: verify formatting.
- `terraform validate`: static validation of Terraform config.

## Coding Style & Naming Conventions
- Use standard Terraform formatting (`terraform fmt`), 2-space indentation.
- Name DNS entries in `locals.dns_records` with clear suffixes by record type (for example, `blog_cname`, `infra_a`, `atproto_bskyfeed_txt`).
- Keep resource keys stable to avoid unnecessary resource recreation.
- Prefer explicit fields (`ttl`, `proxied`, `comment`) for every record.

## Testing Guidelines
There is no separate unit test suite in this repository.
Treat these as required checks before merge:
1. `terraform fmt -check`
2. `terraform validate`
3. `mise run plan` and manual review of the diff

For behavior changes, include the relevant `plan` output summary in the PR.

## Commit & Pull Request Guidelines
Commit history follows Conventional Commits (for example, `feat: import from cloudflare dns records`).
- Use prefixes like `feat:`, `fix:`, `chore:`, `docs:`.
- Keep commits focused and atomic.

PRs should include:
- Purpose and scope.
- Any secret/state/backend impact.
- A short `mise run plan` summary (resources added/changed/destroyed).
- Linked issue/ticket if available.

## Security & Configuration Tips
- Never commit decrypted secrets or plain `.env` files.
- Keep `.env.age` encrypted; `scripts/environments.sh` handles decryption via GCP Secret Manager.
- Confirm `GCP_PROJECT_ID` and backend bucket settings before running `apply`.
