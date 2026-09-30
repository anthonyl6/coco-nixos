#!/usr/bin/env bash
# Shrink the gabagool root filesystem/partition (nvme0n1p2) to free space
# for a Windows partition, to be done from the NixOS installer USB.
#
#   nvme0n1p1 EFI 1GiB | nvme0n1p2 ext4 root (big) | nvme0n1p3 swap 68GiB
#
# After the run there is a ~WIN_GIB gap between the end of root and the
# swap partition; the Windows installer formats/partitions that gap.
#
# Usage (from the installer, script copied onto the USB or fetched from git):
#   bash shrink-root.sh [WIN_GIB]      # default 200 GiB
#
# Safety:
#   - resize2fs cannot shrink a mounted ext4; this must run offline
#     (root is NOT mounted from the installer environment).
#   - Asks for explicit confirmation, e2fsck before/after, and lets
#     resize2fs grow back to fill the shrunk partition (reclaiming slack).
set -euo pipefail

DEV=/dev/nvme0n1
ROOT=${DEV}p2
SWAP=${DEV}p3
WIN_GIB=${1:-200}
SLACK_GIB=4 # safety margin between the new filesystem end and the partition end

[[ -b $ROOT ]] || { echo "ERROR: $ROOT not found"; exit 1; }
[[ $DEV == $(lsblk -no PKNAME "${ROOT}" | tail -1 | sed 's|^|/dev/|') ]] || {
    echo "ERROR: partition-over-device check failed"; exit 1; }

echo "== current state =="
lsblk -o NAME,SIZE,FSTYPE,LABEL,FSUSE%,MOUNTPOINT "$DEV"
fsz_gib=$(( $(lsblk -bno SIZE "$ROOT") / 1073741824 ))
p2_start_gib=$(parted "$DEV" unit GiB print | awk -F'[:[:space:]]+' '$1+0==2 {print $2+0}')
swap_start_gib=$(parted "$DEV" unit GiB print | awk -F'[:[:space:]]+' '$1+0==3 {print $2+0}')
echo "root: ${ROOT}  size=${fsz_gib}GiB  starts at ${p2_start_gib}GiB"
echo "swap: $swap_start_gib GiB onward (untouched)"
[[ $swap_start_gib -ge $(bc -l <<< "$p2_start_gib + $fsz_gib") ]] || {
    echo "ERROR: layout unexpected (gap between p2 and p3?)"; exit 1; }

new_gib=$(( fsz_gib - WIN_GIB - SLACK_GIB ))
(( new_gib > 0 )) || { echo "ERROR: not enough free space"; exit 1; }
echo
echo "== plan =="
echo "shrink ext4 to ~${new_gib}GiB, then partition to exactly that end,"
echo "leaving ~${WIN_GIB}GiB (+<=${SLACK_GIB}GiB rounding) for Windows,"
echo "then grow the filesystem back to fill the shrunk partition."
read -rn 1 -p "Shrink ${ROOT} now? [y/N] " a; echo
[[ $a == y ]] || exit 0

echo "== 1/4 fsck =="
e2fsck -f "$ROOT"

echo "== 2/4 resize filesystem =="
resize2fs "$ROOT" "${new_gib}G"
# Read back the real result; if resize2fs rounded, keep partition aligned past it.
real_gib=$(dumpe2fs -h "$ROOT" | awk '/^Block count/{b=$3}/^Block size/{s=$3}END{int_ret=int(b*s/1073741824)+0; print int_ret}')
(( real_gib <= new_gib )) || { echo "ERROR: fs larger than planned"; exit 1; }

echo "== 3/4 shrink partition =="
parted "$DEV" resizepart 2 "$(( p2_start_gib + real_gib ))GiB"

echo "== 4/4 fill partition & final fsck =="
resize2fs "$ROOT"   # grow back, filling the partition exactly
e2fsck -f "$ROOT"

echo "== done — verify gap for Windows =="
parted "$DEV" unit GiB print free
echo "Boot the Windows installer and create the partition in the unallocated space."
