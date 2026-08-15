#!/usr/bin/env bash
set -euo pipefail

pause() {
  echo
  read -rp "Press Enter to continue..."
}

echo "Insert exactly ONE YubiKey."
pause

echo
echo "Detected YubiKeys:"
ykman list

echo
echo "Current configuration:"
ykman info
ykman openpgp info

echo
read -rp "Configure this YubiKey for USB+NFC passkeys and OpenPGP? [y/N] " ok
[[ "$ok" == "y" || "$ok" == "Y" ]] || exit 1

echo
echo "Configuring USB apps..."
ykman config usb \
  --enable u2f \
  --enable fido2 \
  --enable openpgp \
  --disable otp \
  --disable oath \
  --disable piv \
  --disable hsmauth \
  --force

echo
echo "Configuring NFC apps..."
ykman config nfc \
  --enable u2f \
  --enable fido2 \
  --enable openpgp \
  --disable otp \
  --disable oath \
  --disable piv \
  --disable hsmauth \
  --force

echo
echo "Set or change FIDO2 PIN."
ykman fido access change-pin || true

echo
echo "Change OpenPGP user PIN."
ykman openpgp access change-pin

echo
echo "Change OpenPGP admin PIN."
ykman openpgp access change-admin-pin

echo
echo "Final configuration:"
ykman info
ykman openpgp info
