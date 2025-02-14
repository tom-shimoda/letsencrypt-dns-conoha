#!/bin/bash

# -------- #
# VARIABLE #
# -------- #
# ----- certbot ----- #
# CERTBOT_DOMAIN
# CERTBOT_VALIDATION

# ----- script ----- # 
SCRIPT_NAME=$(basename $0)
SCRIPT_PATH=$(dirname $(readlink -f $0))

# ----- conoha_dns_api.sh  ----- #
CNH_DNS_DOMAIN=${CERTBOT_DOMAIN}'.'
CNH_DNS_NAME='_acme-challenge.'${CNH_DNS_DOMAIN}
CNH_DNS_TYPE="TXT"
CNH_DNS_DATA=${CERTBOT_VALIDATION}

# -------- #
# FUNCTION #
# -------- #
source ${SCRIPT_PATH}/conoha_dns_api.sh

# ----------------- #
# CREATE DNS RECORD # 
# ----------------- #
create_conoha_dns_record


# ----------------------------------------- #
# Wait until txt record is reflected in dns # 
# ----------------------------------------- #
DNS_SERVER="8.8.8.8"
RETRY_INTERVAL=10  # 10秒ごとに再試行
MAX_RETRIES=90  # 最大90回(約15分)試行

echo "Waiting for TXT record propagation for $CNH_DNS_DOMAIN..."

for ((i=1; i<=MAX_RETRIES; i++)); do
  TXT_VALUE=$(dig -t TXT "$CNH_DNS_NAME" @"$DNS_SERVER" +short | tr -d '"' | grep "$CNH_DNS_DATA")

  if [ -n "$TXT_VALUE" ]; then
    echo "TXT record found: $TXT_VALUE"
    sleep 15 # digチェック通過後、念の為もう少し待機
    exit 0
  fi

  echo "Attempt $i/$MAX_RETRIES: TXT record not found yet. Retrying in $RETRY_INTERVAL seconds..."
  sleep $RETRY_INTERVAL
done

echo "Error: TXT record did not propagate within the given time."
exit 1

