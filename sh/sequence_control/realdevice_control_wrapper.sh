#!/bin/bash
set -u

. "${ME_HARDTOOL_DIR}/controller/logging.sh"

. '../realdevice_control/flash_image.sh'
. '../realdevice_control/power_on_board.sh'
. '../realdevice_control/boot_process.sh'
. '../realdevice_control/serial.sh'
. '../realdevice_control/adb.sh'
