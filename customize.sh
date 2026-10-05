#!/system/bin/sh
# MiCloud-A16 installer

SKIPUNZIP=0

ui_print " "
ui_print "- MiCloud-A16"
ui_print "  source: garnet HyperOS OS3.0.306.0.WNRCNXM (CN, Android 16, SDK 36)"
ui_print " "

# --- architecture ---------------------------------------------------------
ABILIST=$(getprop ro.product.cpu.abilist)
[ -z "$ABILIST" ] && ABILIST=$(getprop ro.system.product.cpu.abilist)
case "$ABILIST" in
  *arm64-v8a*) ;;
  *)
    ui_print "! This module ships arm64-v8a apps only."
    ui_print "  Detected ABI list: $ABILIST"
    abort
    ;;
esac
ui_print "- arm64-v8a OK"

# --- sdk ------------------------------------------------------------------
if [ "$API" -lt 34 ]; then
  ui_print "! SDK $API is too old. SDK 34+ required."
  abort
fi
if [ "$API" -lt 36 ]; then
  ui_print "! SDK $API detected, but these apps came from SDK 36."
  ui_print "  Installing anyway; expect missing-API crashes."
fi
ui_print "- SDK $API"

# --- dependency: HyperCore-A16 -------------------------------------------
# All four apps declare micloud-sdk as a required <uses-library>; PackageManager
# refuses to install them without it. HyperCore-A16 provides it (RtMiCloudSDK)
# along with com.miui.system, which defines miui.permission.USE_INTERNAL_GENERAL_API.
HC=
for D in /data/adb/modules/HyperCoreA16 /data/adb/modules_update/HyperCoreA16; do
  if [ -d "$D" ] && [ ! -f "$D/disable" ] && [ ! -f "$D/remove" ]; then
    HC=$D
  fi
done
if [ -z "$HC" ]; then
  ui_print "! HyperCore-A16 is missing or disabled."
  ui_print "  Install it first: https://github.com/mben25/HyperCore-A16/releases"
  abort
fi
ui_print "- HyperCore-A16 found"

# --- conflicts ------------------------------------------------------------
# HyperOS-Gallery ships the same packages (one of them unsigned) and spoofs
# ro.product.device for the whole device.
if [ -d /data/adb/modules/HyperOS-Gallery ] && [ ! -f /data/adb/modules/HyperOS-Gallery/remove ]; then
  ui_print "- Disabling conflicting module: HyperOS-Gallery"
  touch /data/adb/modules/HyperOS-Gallery/remove
fi

# A user-installed copy in /data/app shadows the system copy we ship.
for PKG in com.xiaomi.account com.miui.cloudservice com.miui.micloudsync com.miui.cloudbackup; do
  P=$(pm path "$PKG" 2>/dev/null | head -n1)
  case "$P" in
    *"/data/app/"*)
      ui_print "! $PKG is installed as a user app and will shadow this module."
      ui_print "  Remove it after reboot: pm uninstall $PKG"
      ;;
  esac
done

# --- permissions ----------------------------------------------------------
set_perm_recursive "$MODPATH" 0 0 0755 0644
set_perm_recursive "$MODPATH/system" 0 0 0755 0644 u:object_r:system_file:s0

ui_print " "
ui_print "- Installed. Reboot, then add the account in"
ui_print "  Settings > Passwords & accounts > Add account > Xiaomi account"
ui_print " "
