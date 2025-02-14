#!/bin/bash

SCRIPT_PATH=$(dirname $(readlink -f $0))
if [ ! -f "${SCRIPT_PATH}/certbot_args" ]; then
    echo "Error: certbot_args file not found. Please create a certbot_args file using the certbot_args_example file as a reference."
  exit 1
fi
source ${SCRIPT_PATH}/certbot_args

WILD_DOMAIN_NAME='*.'${BASE_DOMAIN_NAME}


certbot certonly \
--manual \
--agree-tos \
--no-eff-email \
--manual-public-ip-logging-ok \
--preferred-challenges dns-01 \
--server https://acme-v02.api.letsencrypt.org/directory \
-d "${BASE_DOMAIN_NAME}" \
-d "${WILD_DOMAIN_NAME}" \
-m "${MAIL_ADDRESS}" \
--manual-auth-hook ${SCRIPT_PATH}/create_conoha_dns_record.sh \
--manual-cleanup-hook ${SCRIPT_PATH}/delete_conoha_dns_record.sh
