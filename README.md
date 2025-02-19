# letsencrypt-dns-conoha

## Overview
Script to get Let's Encrypt Wildcard SSL Certificate using DNS in ConoHa VPS.

## Requirements
- certbot 0.22.0+
- jq
- DNS to manage your domain with ConoHa VPS.

## Setup
- Place code in your server.
- Create a conoha_id file using the conoha_id_example file as a reference.

## Usage
### Test to get Wildcard SSL Certificate.
```
sudo certbot certonly \
--dry-run \
--manual \
--agree-tos \
--no-eff-email \
--manual-public-ip-logging-ok \
--preferred-challenges dns-01 \
--server https://acme-v02.api.letsencrypt.org/directory \
-d "<base domain name>" \
-d "*.<base domain name>" \
-m "<mail address>" \
--manual-auth-hook /path/to/letsencrypt-dns-conoha/create_conoha_dns_record.sh \
--manual-cleanup-hook /path/to/letsencrypt-dns-conoha/delete_conoha_dns_record.sh
```

or

Create certbot_args file referring to certbot_args_example and run try_get_certificate_dry_run.sh
```
sudo bash try_get_certificate_dry_run.sh
```

### Get Wildcard SSL Certificate.
```
sudo certbot certonly \
--manual \
--agree-tos \
--no-eff-email \
--manual-public-ip-logging-ok \
--preferred-challenges dns-01 \
--server https://acme-v02.api.letsencrypt.org/directory \
-d "<base domain name>" \
-d "*.<base domain name>" \
-m "<mail address>" \
--manual-auth-hook /path/to/letsencrypt-dns-conoha/create_conoha_dns_record.sh \
--manual-cleanup-hook /path/to/letsencrypt-dns-conoha/delete_conoha_dns_record.sh
```

or

Create certbot_args file referring to certbot_args_example and run try_get_certificate_dry_run.sh
```
sudo bash try_get_certificate.sh
```

### Test to renew Wildcard SSL Certificate.
```
sudo certbot renew --force-renewal --dry-run
```

### Renew Wildcard SSL Certificate.
```
sudo certbot renew
```

## cronで自動更新して認証ファイルをnginxサーバーに送る方法
1. "rootユーザーから"nginxサーバーにssh接続できるようにしておく。
2. /etc/cron.d/に拡張子なしのファイル(my_certbot等)を作成し以下を記載。
    権限の関係でrootユーザーで作成する必要がある。
    [参考](https://qiita.com/UNILORN/items/a1a3f62409cdb4256219)
```
# rootユーザーで毎日AM2:00に実行
# (fullchain.pem、privkey.pemの所有権がrootになっているため、rootユーザーで実行することにした)
* 2 * * * root certbot renew && scp /etc/letsencrypt/live/<ドメイン名>/fullchain.pem <送り先フォルダ> && scp /etc/letsencrypt/live/<ドメイン名>/privkey.pem <送り先フォルダ>
```

## References
- [作者ブログ記事](https://www.eastforest.jp/vps/6149)
- [Pre and Post Validation Hooks](https://certbot.eff.org/docs/using.html#pre-and-post-validation-hooks)
- [ACME v2 Production Environment & Wildcards](https://community.letsencrypt.org/t/acme-v2-production-environment-wildcards/55578)
- [ConoHa API Documantation](https://www.conoha.jp/docs/)

## Licence
This software is released under the MIT License.
