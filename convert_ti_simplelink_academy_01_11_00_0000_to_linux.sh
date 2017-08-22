#!/bin/bash

# Source: https://e2e.ti.com/support/wireless_connectivity/bluetooth_low_energy/f/538/p/412962/1911528#1911528
# Author: Norman Mackenzie
# Author: Jonathan Cormier

# Pass this script the path to the ti directory.  It tries to modify the ble stack sources
# to run under Linux.

# By default it assumes that the ble_sdk and tirtos directories have already been copied
# from a wine installation of the ble stack.

# If erase_it_all_and_copy_from_wine is passed as a second argument, then the script will
# erase the current BLE stack and TI RTOS directories, REMOVING AND CHANGES YOU HAVE MADE,
# and get fresh copies from the default wine installation path.  Be careful with this.


if [ $# -lt 1 ]; then
	echo -e "\n\nGive the path to the root of the ti CCS installation as an argument\n\n"
	exit
elif [ $# -gt 2 ]; then
	echo -e "\n\nToo many arguments\n\n"
	exit
fi

TI_ROOT_DIRECTORY=$1

BLE_SDK_VERSION=01_11_00_0000
TIRTOS_VERSION=tirtos_cc13xx_cc26xx_2_20_01_08
XDCTOOLS_VERSION=xdctools_3_32_00_06_core
XDCTOOLS_SOURCE=http://software-dl.ti.com/dsps/dsps_public_sw/sdo_sb/targetcontent/rtsc/3_32_00_06/index_FDS.html

WINE_ROOT=~/.wine/drive_c/ti

BLE_SDK_DIRECTORY=${TI_ROOT_DIRECTORY}/simplelink_academy_${BLE_SDK_VERSION}/modules
TIRTOS_DIRECTORY=${TI_ROOT_DIRECTORY}/${TIRTOS_VERSION}
XDCTOOLS_DIRECTORY=${TI_ROOT_DIRECTORY}/${XDCTOOLS_VERSION}

function check_for_spaces {
	if [ $# -ne 1 ]; then
		echo -e "\n\nThis script doesn't work for paths including spaces\n\n"
		exit
	fi
}

check_for_spaces ${TI_ROOT_DIRECTORY}

if [ "$2" = "erase_it_all_and_copy_from_wine" ]; then

	if [ ! -d ${TI_ROOT_DIRECTORY} ]; then
		echo -e "\n\nThe ti root directory was not found at ${TI_ROOT_DIRECTORY}\n\n"
		exit
	fi

	if [ ! -d ${WINE_ROOT}/simplelink_academy_${BLE_SDK_VERSION} ]; then
		echo -e "\n\nThe wine installation of ${BLE_SDK_VERSION} was not found at ${WINE_ROOT}/simplelink/${BLE_SDK_VERSION}\n\n"
		exit
	fi

	if [ ! -d ${WINE_ROOT}/${TIRTOS_VERSION} ]; then
		echo -e "\n\nThe wine installation of ${TIRTOS_VERSION} was not found at ${WINE_ROOT}/${TIRTOS_VERSION}\n\n"
		exit
	fi

	mkdir -p ${TI_ROOT_DIRECTORY}/

	rm -rf ${BLE_SDK_DIRECTORY}
	cp -ar ${WINE_ROOT}/simplelink_academy_${BLE_SDK_VERSION} ${TI_ROOT_DIRECTORY}/

	#rm -rf ${TIRTOS_DIRECTORY}
	#cp -ar ${WINE_ROOT}/${TIRTOS_VERSION} ${TIRTOS_DIRECTORY}

elif [ $# -ne 1 ]; then
	echo -e "\n\nUnexpected second argument, only 'erase_it_all_and_copy_from_wine' is supported."
	echo -e "That will erase any changes you have made!\n\n"
	exit
fi

if [ ! -d ${BLE_SDK_DIRECTORY} ]; then
	echo -e "\n\nThe BLE stack was not found at ${BLE_SDK_DIRECTORY}\n\n"
	exit
fi

if [ ! -d ${TIRTOS_DIRECTORY} ]; then
	echo -e "\n\nThe tirtos was not found at ${TIRTOS_DIRECTORY}\n\n"
	exit
fi

if [ ! -d ${XDCTOOLS_DIRECTORY} ]; then
	echo -e "\n\nThe xdctools were not found at ${XDCTOOLS_DIRECTORY}.  The Linux version is available at ${XDCTOOLS_SOURCE}\n\n"
elif [ -f ${XDCTOOLS_DIRECTORY}/xs.exe ]; then
	echo -e "\n\nThe windows version of xdctools is installed.  Replace this with the Linux version from ${XDCTOOLS_SOURCE}\n\n"
	exit
elif [ ! -f ${XDCTOOLS_DIRECTORY}/xs ]; then
	echo -e "\n\nPlease check the installation of the xdctools.  The Linux version is available at ${XDCTOOLS_SOURCE}\n\n"
fi

function replace_text_in_ble_sdk {
	echo -e "Changing $1 to $2 in all ble_sdk source files"
	grep --exclude-dir=".git" --exclude=*.a -rl "$1" ${BLE_SDK_DIRECTORY} | xargs sed -i "s/$1/$2/g"
}

function replace_text_in_tirtos {
	echo -e "Changing $1 to $2 in all tirtos source files"
	grep --exclude-dir=".git" --exclude=*.a -rl "$1" ${TIRTOS_DIRECTORY} | xargs sed -i "s/$1/$2/g"
}

# There's an invalid linked location in ${BLE_SDK_DIRECTORY}/examples/cc2650stk/sensortag_lcd/ccs/app/.project
# This is a best guess at what's intended.
replace_text_in_ble_sdk "SRC_COMMON\\/hal\\/src\\/target\\/_common\\/board.h" "SRC_EX\\/target\\/Board.h"

# Use Board.h consistently in the ble stack instead of a mixture of board.h and Board.h.
# The tirtos uses Board.h consistently so we'll assume that's correct.
replace_text_in_ble_sdk "\\\"board\\.h" "\\\"Board.h"
replace_text_in_ble_sdk "\\/board\\.h" "\\/Board.h"
replace_text_in_ble_sdk "<board\\.h" "<Board.h"
# We have to rename some files in the ble stack for this to work.
find ${BLE_SDK_DIRECTORY} -name "board\.h" | sed -e "p;s/board.h/Board.h/" | xargs -n2 mv

# Fix a few places where the include directives or references don't match the file's case.
replace_text_in_ble_sdk "DisplayUART\\.h" "DisplayUart.h"
replace_text_in_ble_sdk "DisplayUART\\.c" "DisplayUart.c"
replace_text_in_ble_sdk "hal_UART\\.h" "hal_uart.h"
replace_text_in_ble_sdk "ICall\\.h" "icall.h"
replace_text_in_ble_sdk "OSAL\\.h" "osal.h"
replace_text_in_ble_sdk "OSAL_Tasks\\.h" "osal_tasks.h"
replace_text_in_ble_sdk "OSAL_Memory\\.h" "osal_memory.h"
replace_text_in_ble_sdk "OSAL_Timers\\.h" "osal_timers.h"
replace_text_in_ble_sdk "ti\\/drivers\\/rf\\/rf.h" "ti\\/drivers\\/rf\\/RF.h"
replace_text_in_ble_sdk "sensorTag\\.h" "sensortag.h"
replace_text_in_ble_sdk "sensortag_Display\\.h" "sensortag_display.h"
replace_text_in_ble_sdk "npi_tl_SPI\\.c" "npi_tl_spi.c"
replace_text_in_ble_sdk "npi_tl_SPI\\.h" "npi_tl_spi.h"
replace_text_in_ble_sdk "npi_tl_UART\\.c" "npi_tl_uart.c"
replace_text_in_ble_sdk "npi_tl_UART\\.h" "npi_tl_uart.h"
replace_text_in_ble_sdk "bsp_SPI\\.c" "bsp_spi.c"
replace_text_in_ble_sdk "bsp_SPI\\.h" "bsp_spi.h"

# The case of driverlib needs to be fixed in both the BLE SDK and the TIRTOS sources
replace_text_in_ble_sdk "driverLib\\/timer.h" "driverlib\\/timer.h"
replace_text_in_tirtos "driverLib\\/timer.h" "driverlib\\/timer.h"

# Fix absolute Windows paths set for a default wine install by using paths relative to the imported project
replace_text_in_ble_sdk "file:\\/C:\\/ti" "\$\{PARENT-7-ORG_PROJ_DIR\}"

# Some references are broken.  This might be caused by copying to the workspace when importing the projects.
replace_text_in_ble_sdk "PARENT-5-PROJECT_LOC\\/src\\/examples\\/sensortag" "SRC_EX\\/examples\\/sensortag"
replace_text_in_ble_sdk "PARENT-5-PROJECT_LOC\\/src\\/profiles\\/sensor_profile" "SRC_EX\\/profiles\\/sensor_profile"
replace_text_in_ble_sdk "PARENT-1-PROJECT_LOC\\/config\\/" "PARENT-2-ORG_PROJ_DIR\\/ccs\\/config\\/"

# Need forward slashes rather than backslashes in library paths.  One is wrong, all the others look OK.
replace_text_in_ble_sdk "\\\\rom\\\\\enc_lib\\\\cc26xx_ecc_rom_api.a" "\\/rom\\/enc_lib\\/cc26xx_ecc_rom_api.a"

# Running the Windows lib_search executable under wine generates absolute paths with a Z: prefix, so run the python
# source directly.  Also change backslashes to forward slashes in the searchpath elements that this application uses.
replace_text_in_ble_sdk "&quot;\\\${TOOLS_BLE}\\/lib_search\\/lib_search.exe" "python \\&quot;\\\${TOOLS_BLE}\\/lib_search\\/src\\/lib_search.py"
replace_text_in_ble_sdk "&quot;\\\${TI_BLE_SDK_BASE}\\/tools\\/lib_search\\/lib_search.exe" "python \\&quot;\\\${TI_BLE_SDK_BASE}\\/tools\\/lib_search\\/src\\/lib_search.py"
sed -i "/searchpath/s/\\\\/\\//g"  ${BLE_SDK_DIRECTORY}/tools/lib_search/params_split_cc2640.xml
sed -i "/searchpath/s/\\\\/\\//g"  ${BLE_SDK_DIRECTORY}/tools/lib_search/params_split_cc1350.xml


