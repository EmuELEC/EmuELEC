#!/bin/sh
# Copyright (C) 2022-present Team CoreELEC (https://coreelec.org)

[ -z "${TMATE_CONF}" ] && exit 1

for arg in $(cat /proc/cmdline); do
  case $arg in
    tmate)
      TMATE_INVITE=true
      ;;
  esac
done

MACHINE_ID=$(cat /storage/.cache/systemd-machine-id)
[ -z "${MACHINE_ID}" ] && MACHINE_ID="$(openssl rand -hex 16)"
[ -z "${TMATE_USERNAME}" ] && TMATE_USERNAME="${MACHINE_ID}"

TMATE_PUBLIC_KEY_CE="/var/run/tmate_id_ed25519_ce.pub"
TMATE_PUBLIC_KEY_USER="/storage/.config/tmate_id_ed25519_user"

if [ ! -f ${TMATE_PUBLIC_KEY_USER}.pub ]; then
  ssh-keygen -t ed25519 -N "" -f ${TMATE_PUBLIC_KEY_USER}
  mv ${TMATE_PUBLIC_KEY_USER} ${TMATE_PUBLIC_KEY_USER}.priv
fi

if [ "${TMATE_INVITE}" = "true" ]; then
  curl --max-time 5 -o ${TMATE_PUBLIC_KEY_CE} \
    https://coreelec.org/tmate_id_ed25519_ce.pub

  cat << EOF > "${TMATE_CONF}"
set tmate-webhook-url "https://tmate-webhook.coreelec.org"
set tmate-webhook-userdata "${TMATE_USERNAME}"
set tmate-session-name "${MACHINE_ID}"
set tmate-api-key "tmk-GBXefJkTxSAW60efR5u6Z0cxrM"
set tmate-authorized-keys "${TMATE_PUBLIC_KEY_CE}"
EOF
elif [ "${TMATE_SSH_KEY}" = "User key" ]; then
  cat << EOF > "${TMATE_CONF}"
set tmate-session-name "${MACHINE_ID}"
set tmate-api-key "tmk-GBXefJkTxSAW60efR5u6Z0cxrM"
set tmate-authorized-keys "${TMATE_PUBLIC_KEY_USER}.pub"
EOF
else
  echo "" > "${TMATE_CONF}"
fi
