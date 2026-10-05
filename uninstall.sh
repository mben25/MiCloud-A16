#!/system/bin/sh
# Clear the apps' data so the Xiaomi account authenticator does not linger in
# AccountManager after the packages disappear. Runs while the module is still
# mounted, before the reboot that removes it.
for PKG in com.xiaomi.account com.miui.cloudservice com.miui.micloudsync com.miui.cloudbackup; do
  pm clear "$PKG" >/dev/null 2>&1
done
