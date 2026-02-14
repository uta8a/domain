terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

data "cloudflare_zone" "this" {
  filter = {
    name = var.cloudflare_zone_name
  }
}

locals {
  dns_records = {
    "infra_wildcard_a" = {
      id      = "4172988986a638b094eabaa76f1717d4"
      name    = "*.infra"
      type    = "A"
      content = "153.127.46.14"
      ttl     = 1
      proxied = false
      comment = "coolifyのアプリ用"
    }
    "infra_a" = {
      id      = "c8fb2035174d636d3701688a757e7a11"
      name    = "infra"
      type    = "A"
      content = "153.127.46.14"
      ttl     = 1
      proxied = false
      comment = "sakura vps"
    }
    "blog_cname" = {
      id      = "25ee5d10986b03512f7400e7f4df3e4f"
      name    = "blog"
      type    = "CNAME"
      content = "blog-q62.pages.dev"
      ttl     = 1
      proxied = true
      comment = null
    }
    "daily_rust_cname" = {
      id      = "1f742407d2e46310da3c2a5a734276b4"
      name    = "daily-rust"
      type    = "CNAME"
      content = "uta8a.github.io"
      ttl     = 1
      proxied = false
      comment = "https://github.com/uta8a/daily-rust.uta8a.net"
    }
    "docs_turkey_cname" = {
      id      = "39007164b6afc085897041def9b313c6"
      name    = "docs.turkey"
      type    = "CNAME"
      content = "docs-6wl.pages.dev"
      ttl     = 1
      proxied = true
      comment = "https://github.com/alltheturkey/docs"
    }
    "event_cname" = {
      id      = "d2aea989d2b273baee2a42167304b998"
      name    = "event"
      type    = "CNAME"
      content = "event-uta8a-net.pages.dev"
      ttl     = 1
      proxied = true
      comment = null
    }
    "infinite_cname" = {
      id      = "d82206f304c94ad6eeac65738adf1767"
      name    = "infinite"
      type    = "CNAME"
      content = "infinite-uta8a-net.pages.dev"
      ttl     = 1
      proxied = true
      comment = null
    }
    "knowledge_cname" = {
      id      = "33104481c33ee478248af9542edcb9ca"
      name    = "knowledge"
      type    = "CNAME"
      content = "knowledge-uta8a-net.pages.dev"
      ttl     = 1
      proxied = true
      comment = null
    }
    "lottery_cname" = {
      id      = "a75b636e48a85171635001f8c526db4f"
      name    = "lottery"
      type    = "CNAME"
      content = "2023-lottery-uta8a-net.pages.dev"
      ttl     = 1
      proxied = true
      comment = null
    }
    "math_docs_cname" = {
      id      = "f912dcc2dc32617b8c88dbbcc2cd8224"
      name    = "math.docs"
      type    = "CNAME"
      content = "uta8a.github.io"
      ttl     = 1
      proxied = false
      comment = null
    }
    "scrap_docs_cname" = {
      id      = "f45b4e99b21c4ed391b791bd06fec764"
      name    = "scrap.docs"
      type    = "CNAME"
      content = "uta8a.github.io"
      ttl     = 1
      proxied = false
      comment = null
    }
    "atproto_bskyfeed_txt" = {
      id      = "5f414967deb274938ed6328d8ccb6759"
      name    = "_atproto.bskyfeed"
      type    = "TXT"
      content = "did=did:plc:665nhwoghahlvwaoed6uepmc"
      ttl     = 1
      proxied = false
      comment = "https://github.com/uta8a/bskyfeed"
    }
    "github_pages_challenge_txt" = {
      id      = "7fcce21c64f057224b30fdbc6998351f"
      name    = "_github-pages-challenge-uta8a.blog"
      type    = "TXT"
      content = "d686cf03506fd4a93ac7bc37c01d5e"
      ttl     = 3600
      proxied = false
      comment = null
    }
  }
}

resource "cloudflare_dns_record" "records" {
  for_each = local.dns_records

  zone_id = data.cloudflare_zone.this.id
  name    = each.value.name
  type    = each.value.type
  content = each.value.content
  ttl     = each.value.ttl
  proxied = each.value.proxied
  comment = each.value.comment
}

## 既存のDNSレコードをインポートした時のコード
# import {
#   for_each = local.dns_records
#   to       = cloudflare_dns_record.records[each.key]
#   id       = "${data.cloudflare_zone.this.id}/${each.value.id}"
# }
