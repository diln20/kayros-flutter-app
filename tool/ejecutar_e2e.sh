#!/usr/bin/env bash
set -euo pipefail

# Cada prueba se ejecuta por separado para aislar Android y Firebase.
# No se utilizan credenciales, cuentas ni datos de producción.
if [[ "$#" -ne 1 ]]; then
  echo "Uso: bash tool/ejecutar_e2e.sh auth_e2e_test.dart|paquetes_e2e_test.dart" >&2
  exit 2
fi

case "$1" in
  auth_e2e_test.dart|paquetes_e2e_test.dart)
    ;;
  *)
    echo "Prueba de integración no permitida: $1" >&2
    exit 2
    ;;
esac

flutter test "integration_test/$1" \
  -d emulator-5554 \
  --dart-define=KAYROS_USE_FIREBASE_EMULATORS=true
