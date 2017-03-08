# TI_BLE_CC2650_Linux_Convert
Conversion script to allow building CC2650 code on linux with Code Composer v6.2+ (CCS)

Source: [E2E - Is there a BLE-stack installer for linux?](https://e2e.ti.com/support/wireless_connectivity/bluetooth_low_energy/f/538/p/412962/1911528#1911528)

Original Author: Norman Mackenzie

Note: TI has a wiki on trying to build on Linux but as of this writing (02/08/2017) it is out of date.  Describes building version v2.1 of the SDK.  http://processors.wiki.ti.com/index.php/Building_BLE_Projects_on_Linux

The wiki states "building the BLE-Stack SDK is not officially supported on Linux host platforms"

Please if you find problems with this project, fork it and create a pull request.

Tested:
* simple_peripheral_cc2650lp

## Running script:

```bash
$ git clone https://github.com/jcormier/TI_BLE_CC2650_Linux_Convert.git
$ cd TI_BLE_CC2650_Linux_Convert
$ ./convert_ti_ble_sdk_2_02_01_18_to_linux.sh ~/ti/
```

## Installing CCS and SDK (Linux)

Note: TI's guide is out of date. Covers v2.1 SDK instead of v2.2.
http://processors.wiki.ti.com/index.php/Building_BLE_Projects_on_Linux

* SDK Version: v2.2.1 [Release Notes"](ttp://focus.ti.com/download/freetools/release_notes_BLE_Stack_2_2_1.html#Installation)
* CCS Version: v6.2+ [Download](http://processors.wiki.ti.com/index.php/Download_CCS#Code_Composer_Studio_Version_6_Downloads)
* TI ARM Compiler: TI ARM Compiler v5.2.6
* TI-RTOS version: 2.20.01.08 [Download](http://software-dl.ti.com/dsps/dsps_public_sw/sdo_sb/targetcontent/tirtos/index.html)
* XDC Tools: 3.32.00.06

```bash
tar xzf CCS6.2.0.00050_linux-x64.tar.gz
./CCS6.2.0.00050_linux-x64/ccs_setup_linux64_6.2.0.00050.bin
rm -rf CCS6.2.0.00050_linux-x64
# Update Code Composer. Help -> Check For Updates
# Install "ARM Compiler Tools v5.2.6". Help -> Install , Select Work with "--All...", search "ARM Compiler Tools", uncheck "Show only the latest.."
# Install tirtos
./tirtos_cc13xx_cc26xx_setuplinux_2_20_01_08.bin mode unattended --prefix $HOME/ti
# Install sdk via wine
wine ble_sdk_2_02_01_18_setup.exe
# Fix various case-sensitive issues.  Script based on post here: https://e2e.ti.com/support/wireless_connectivity/bluetooth_low_energy/f/538/p/412962/1911528#1911528
./convert_ti_ble_sdk_2_02_01_18_to_linux.sh ~/ti/ erase_it_all_and_copy_from_wine
```

Download location for sdk: http://www.ti.com/tool/ble-stack?DCMP=wbu-blestack&HQS=ble-stack

Building Project with Code Composer Studio [2.6.3 Code Composer Studio](http://www.ti.com/lit/ug/swru393d/swru393d.pdf)

[2.6.3.3.1 Import an Existing Project](http://www.ti.com/lit/ug/swru393d/swru393d.pdf)

When creating a new project based on the SDK, I suspect the recommended approach is to copy one of the existing examples and rename it. 

The links to the SDK are found in the "Link Resources" section of the project properties.  The example projects provided by the SDK all assume the SDK is located relative to their location, which is not ideal.  However if you look at the project_zero example which is provided separate of the SDK (see below), they created a TI_BLE_SDK_BASE variable which the other variables use to find the SDK instead of expecting it to be relative to the project directory.

Note: This relative path problem seems to be resolved by CCS when you mark "copy projects into workspace" by creating a ORG_PROJ_DIR variable and using that to resolve all the paths.

## Updated simplelink academy

Expects you've already installed the SDK above

```bash
wget http://software-dl.ti.com/lprf/simplelink_academy/setup_simplelink_academy_01_11_00_0000.exe
wine setup_simplelink_academy_01_11_00_0000.exe
./convert_ti_simplelink_academy_01_11_00_0000_to_linux.sh ~/ti/ erase_it_all_and_copy_from_wine
```
## CCS7.1

Success report
https://e2e.ti.com/support/wireless_connectivity/bluetooth_low_energy/f/538/p/579411/2127950#2127950
