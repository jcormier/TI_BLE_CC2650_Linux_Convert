#!/bin/bash

# Source: https://e2e.ti.com/support/wireless_connectivity/bluetooth_low_energy/f/538/p/412962/1911528#1911528
# Author: Norman Mackenzie
# Author: Jonathan Cormier
# Author: Biagio Montaruli

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

SIMPLELINK_SDK_VERSION=01_11_00_0000
BLE_SDK_VERSION=ble_sdk_2_02_01_18
TIRTOS_VERSION=tirtos_cc13xx_cc26xx_2_20_01_08
XDCTOOLS_VERSION=xdctools_3_32_00_06_core
XDCTOOLS_SOURCE=http://software-dl.ti.com/dsps/dsps_public_sw/sdo_sb/targetcontent/rtsc/3_32_00_06/index_FDS.html

WINE_ROOT=~/.wine/drive_c/ti

SIMPLELINK_SDK_DIRECTORY=${TI_ROOT_DIRECTORY}/simplelink_academy_${SIMPLELINK_SDK_VERSION}
BLE_SDK_DIRECTORY=${TI_ROOT_DIRECTORY}/simplelink/${BLE_SDK_VERSION}
SIMPLELINK_SDK_MODULES_DIRECTORY=${TI_ROOT_DIRECTORY}/simplelink_academy_${SIMPLELINK_SDK_VERSION}/modules
TIRTOS_DIRECTORY=${TI_ROOT_DIRECTORY}/${TIRTOS_VERSION}
XDCTOOLS_DIRECTORY=${TI_ROOT_DIRECTORY}/${XDCTOOLS_VERSION}

function check_for_spaces {
	if [ $# -ne 1 ]; then
		echo -e "\n\nThis script doesn't work for paths including spaces\n\n"
		exit
	fi
}

check_for_spaces ${TI_ROOT_DIRECTORY}

if [ ! -d ${BLE_SDK_DIRECTORY} ]; then
	echo -e "\n\nThe BLE stack was not found at ${BLE_SDK_DIRECTORY}\n\n"
	exit
fi

if [ ! -d ${TIRTOS_DIRECTORY} ]; then
	echo -e "\n\nThe TI-RTOS was not found at ${TIRTOS_DIRECTORY}\n\n"
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

if [ "$2" = "erase_it_all_and_copy_from_wine" ]; then

	if [ ! -d ${TI_ROOT_DIRECTORY} ]; then
		echo -e "\n\nThe ti root directory was not found at ${TI_ROOT_DIRECTORY}\n\n"
		exit
	fi

	if [ ! -d ${WINE_ROOT}/simplelink_academy_${SIMPLELINK_SDK_VERSION} ]; then
		echo -e "\n\nThe wine installation of ${SIMPLELINK_SDK_VERSION} was not found at ${WINE_ROOT}/simplelink_academy_${SIMPLELINK_SDK_VERSION}\n\n"
		exit
	fi
	
	rm -rf ${SIMPLELINK_SDK_DIRECTORY}
	cp -ar ${WINE_ROOT}/simplelink_academy_${SIMPLELINK_SDK_VERSION} ${TI_ROOT_DIRECTORY}/
	
elif [ $# -ne 1 ]; then
	echo -e "\n\nUnexpected second argument, only 'erase_it_all_and_copy_from_wine' is supported."
	echo -e "That will erase any changes you have made!\n\n"
	exit
fi

if [ ! -d ${SIMPLELINK_SDK_DIRECTORY} ]; then
	echo -e "\n\nThe SimpleLink Academy package was not found at ${SIMPLELINK_SDK_DIRECTORY}\n\n"
	exit
fi

function replace_text_in_simplelink_package {
	echo -e "Changing $1 to $2 in all simplelink academy package source files"
	grep --exclude-dir=".git" --exclude=*.a -rl "$1" ${SIMPLELINK_SDK_MODULES_DIRECTORY} | xargs sed -i "s/$1/$2/g"
}

# Use Board.h consistently in the simplelink package instead of a mixture of board.h and Board.h.
# The tirtos uses Board.h consistently so we'll assume that's correct.
replace_text_in_simplelink_package "\\\"board\\.h" "\\\"Board.h"
# We have to rename some files in the simplelink package for this to work.
find ${SIMPLELINK_SDK_MODULES_DIRECTORY} -name "board\.h" | sed -e "p;s/board.h/Board.h/" | xargs -n2 mv

# Fix a few places where the include directives or references don't match the file's case.
replace_text_in_simplelink_package "ICall\\.h" "icall.h"
replace_text_in_simplelink_package "OSAL\\.h" "osal.h"

# Fix absolute Windows paths set for a default wine install by using paths relative to the imported project
replace_text_in_simplelink_package "C:\\/ti" "\\\${TI_PRODUCTS_DIR}"

mv ${SIMPLELINK_SDK_MODULES_DIRECTORY}/projects/tirtos_basic_lab1/CCS ${SIMPLELINK_SDK_MODULES_DIRECTORY}/projects/tirtos_basic_lab1/ccs
grep -l " Lab 1 EMK" ${SIMPLELINK_SDK_MODULES_DIRECTORY}/projects/tirtos_basic_lab1/ccs/01_rtos_basic_em* | xargs sed -i "s/ Lab 1 EMK/_Lab1_CC2650EMK/"
grep -l " Lab 1 LAUNCHXL" ${SIMPLELINK_SDK_MODULES_DIRECTORY}/projects/tirtos_basic_lab1/ccs/01_rtos_basic_lp* | xargs sed -i "s/ Lab 1 LAUNCHXL/_Lab1_CC2650LAUNCHXL/"
grep -l " Lab 1 STK" ${SIMPLELINK_SDK_MODULES_DIRECTORY}/projects/tirtos_basic_lab1/ccs/01_rtos_basic_st* | xargs sed -i "s/ Lab 1 STK/_Lab1_CC2650STK/"
