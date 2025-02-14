#!/bin/bash

# -------- #
# VARIABLE #
# -------- #
SCRIPT_PATH=$(dirname $(readlink -f $0))
if [ ! -f "${SCRIPT_PATH}/conoha_id" ]; then
  echo "Error: conoha_id file not found. Please create a conoha_id file using the conoha_id_sample file as a reference."
  exit 1
fi
source ${SCRIPT_PATH}/conoha_id

# -------- #
# FUNCTION #
# -------- #
get_conoha_token(){
    RESPONSE=$(curl -i -sS \
    -X POST \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -d '{"auth": {"identity": {"methods": ["password"],"password": {"user": {"id": "'${CNH_NAME}'","password": "'${CNH_PASS}'"}}},"scope": {"project": {"id": "'${CNH_TENANTID}'"}}}}' \
    https://identity.c3j1.conoha.io/v3/auth/tokens)

    # `x-subject-token:` の後のトークン情報を抽出
    TOKEN=$(echo "$RESPONSE" | grep -i "x-subject-token:" | awk '{print $2}')

    if [ -n "$TOKEN" ]; then
        echo $TOKEN
    else
        echo "Token not found." >&2
        exit 1
    fi
}

get_conoha_domain_id(){
    curl -sS \
    -X GET \
    -H "Accept: application/json" \
    -H "X-Auth-Token: ${CNH_TOKEN}" \
    https://dns-service.c3j1.conoha.io/v1/domains \
    | jq -r '.domains[] | select(.name == "'${CNH_DNS_DOMAIN}'") | .uuid'
}

create_conoha_dns_record(){
    curl -sS \
    -X POST \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -H "X-Auth-Token: ${CNH_TOKEN}" \
    -d '{"name": "'${CNH_DNS_NAME}'","type": "'${CNH_DNS_TYPE}'","data": "'${CNH_DNS_DATA}'"}' \
    https://dns-service.c3j1.conoha.io/v1/domains/${CNH_DOMAIN_ID}/records
}

get_conoha_dns_record_id(){
    curl -sS \
    -X GET \
    -H "Accept: application/json" \
    -H "X-Auth-Token: ${CNH_TOKEN}" \
    https://dns-service.c3j1.conoha.io/v1/domains/${CNH_DOMAIN_ID}/records \
    | jq -r '.records[] | select(.name == "'${CNH_DNS_NAME}'" and .data == "'${CNH_DNS_DATA}'") | .uuid'
}

delete_conoha_dns_record(){
    local delete_id=$1
    curl -sS \
    -X DELETE \
    -H "Accept: application/json" \
    -H "X-Auth-Token: ${CNH_TOKEN}" \
    https://dns-service.c3j1.conoha.io/v1/domains/${CNH_DOMAIN_ID}/records/${delete_id}
}

# ----------- #
# GET A TOKEN #
# ----------- #
CNH_TOKEN=$(get_conoha_token | tr -d '\r\n')

# ----------------- #
# GET THE DOMAIN ID #
# ----------------- #
CNH_DOMAIN_ID=$(get_conoha_domain_id)
