#!/system/bin/sh
MODPATH=${0%/*}

exec 2>"$MODPATH/debug-service.log"
set -x

until [ "$(getprop sys.boot_completed)" = 1 ]; do
  sleep 5
done

# On HyperOS these runtime permissions come pre-granted, so the sync adapters
# never ask for them. Grant them once after install so contacts/calendar sync can
# start; anything the user revokes later stays revoked. SMS, call log and camera
# are left to the apps' own runtime prompts.
MARK="$MODPATH/.granted-v1"
if [ ! -f "$MARK" ]; then
  for PKG in com.xiaomi.account com.miui.cloudservice com.miui.micloudsync com.miui.cloudbackup; do
    for PERM in READ_CONTACTS WRITE_CONTACTS READ_CALENDAR WRITE_CALENDAR READ_PHONE_STATE POST_NOTIFICATIONS; do
      pm grant "$PKG" "android.permission.$PERM" 2>/dev/null
    done
  done
  touch "$MARK"
fi

# The account authenticator and sync services must not be hibernated, or the
# Xiaomi account silently stops syncing after a few unused months.
for PKG in com.xiaomi.account com.miui.cloudservice com.miui.micloudsync com.miui.cloudbackup; do
  appops set "$PKG" AUTO_REVOKE_PERMISSIONS_IF_UNUSED ignore 2>/dev/null
done
