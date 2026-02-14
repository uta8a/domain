remote_state {
  backend = "s3"

  config = {
    bucket         = get_env("TFSTATE_BUCKET")
    key            = "uta8a/domain/terraform.tfstate"
    region         = "ap-northeast-1"
    use_lockfile   = true
    encrypt        = true
  }
}
