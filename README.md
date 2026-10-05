# MiCloud-A16

Author: mbenanaya

Mi Account, Xiaomi Cloud, MiCloud Sync and Cloud Backup for AOSP-based ROMs,
taken unmodified from the `garnet` HyperOS CN fastboot ROM `OS3.0.306.0.WNRCNXM`
(Android 16, SDK 36).

Built for AlphaDroid on Redmi Note 13 Pro 5G (garnet), arm64-v8a only.
**Requires [HyperCore-A16](https://github.com/mben25/HyperCore-A16) v1.1 or newer.**

## What it ships

| Package | Version | Installed at |
|---|---|---|
| `com.xiaomi.account` | R-25.10.23.03 | `/product/priv-app/MIUIXiaomiAccount/` |
| `com.miui.cloudservice` | 1.12.0.8.46 | `/product/priv-app/MIUICloudService/` |
| `com.miui.micloudsync` | 1.12.0.1.40 | `/product/priv-app/MIUIMiCloudSync/` |
| `com.miui.cloudbackup` | 1.12.1.6.42.6 | `/product/priv-app/MIUICloudBackup/` |

Plus `/product/etc/permissions/privapp-permissions-micloud-a16.xml`.

All four APKs are byte-identical to the ROM and keep Xiaomi's v3 signature
(cert SHA-256 `c9009d01ebf9f5d0…`). No `system.prop`, no sepolicy, no prop spoofing.

## Why priv-app when stock uses product/app

On HyperOS only Cloud Backup is a priv-app. Account, Cloud and Sync sit in
`product/app` and receive framework permissions such as `GET_ACCOUNTS_PRIVILEGED`
and `MANAGE_USERS` because HyperOS's platform key *is* `c9009d01…`. AlphaDroid's
platform key is different, so this module installs them as priv-apps and
allowlists exactly the `signature|privileged` framework permissions each one
requests. Cloud Backup keeps its stock allowlist block verbatim.

Permissions defined by `com.miui.system` (HyperCore's `miuisystem.apk`, also signed
`c9009d01…`), such as `miui.permission.USE_INTERNAL_GENERAL_API`, are granted by
signature match. That covers the one cross-app guard between these packages
(Cloud Backup's services). The full per-permission audit is in
`notes/permissions-audit.tsv`.

## Entry points

AOSP Settings has no Mi Account row, and none of the apps has a launcher icon.

- Sign in: Settings → Passwords & accounts → Add account → **Xiaomi account**, or
  `am start -n com.xiaomi.account/.ui.AccountSettingsActivity`
- Xiaomi Cloud: `am start -n com.miui.cloudservice/.ui.MiCloudMainActivity`

On first boot after install, `service.sh` grants contacts, calendar, phone state and
notifications once, so sync can start. SMS, call log and camera are left to the apps'
own prompts.

## Known limitations

- Find Device is not included: it needs `android.uid.finddevice` and a MIUI
  lock-screen hook that AOSP lacks.
- Mi Push (`com.xiaomi.xmsf`) is not included yet. Push-driven features such as
  remote sync triggers may be delayed.
- CN build: tested target is a CN-region Xiaomi account. Whether international
  accounts are accepted is still to be confirmed.

## Updates

Releases are published at <https://github.com/mben25/MiCloud-A16/releases>.
To ship an update, bump `version` and `versionCode` in `module.prop`, add a
`CHANGELOG.md` entry and push to `main`.
