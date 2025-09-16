# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="adafruit-libraries"
PKG_VERSION=""
PKG_REV="0"
PKG_ARCH="any"
PKG_ADDON_PROJECTS="RPi ARM"
PKG_LICENSE="MIT"
PKG_SITE=""
PKG_URL=""
PKG_DEPENDS_TARGET="Adafruit_Python_ADS1x15 Adafruit_Python_ADXL345 Adafruit_Python_BMP Adafruit_Python_CharLCD Adafruit_Python_DHT Adafruit_Python_GPIO Adafruit_Python_LED_Backpack Adafruit_Python_LSM303 Adafruit_Python_MCP3008 Adafruit_Python_MCP4725 Adafruit_Python_PCA9685 Adafruit_Python_PureIO Adafruit_Python_SI1145 Adafruit_Python_SSD1306 Adafruit_Python_TCS34725 Adafruit_Python_VCNL40xx Adafruit_Python_WS2801"
PKG_SECTION="virtual"
PKG_SHORTDESC="A bundle of libraries from Adafruit"
PKG_LONGDESC="This is a bundle of various Adafruit Python libraries. Included are: ADS1x15, ADXL345, BMP, CharLCD, DHT, GPIO, LED_Backpack, LSM303, MCP3008, MCP4725, PCA9685, PureIO, SI1145, SSD1306, TCS34725, VCNL40xx, WS2801"

PKG_IS_ADDON="yes"
PKG_ADDON_NAME="Adafruit Libraries"
PKG_ADDON_TYPE="xbmc.python.module"
PKG_ADDON_REQUIRES="virtual.rpi-tools:8.0.102"

addon() {
  mkdir -p ${ADDON_BUILD}/${PKG_ADDON_ID}/lib
    cp -PR $(get_build_dir Adafruit_Python_ADS1x15)/Adafruit_ADS1x15           ${ADDON_BUILD}/${PKG_ADDON_ID}/lib/
    cp -PR $(get_build_dir Adafruit_Python_ADXL345)/Adafruit_ADXL345           ${ADDON_BUILD}/${PKG_ADDON_ID}/lib/
    cp -PR $(get_build_dir Adafruit_Python_BMP)/Adafruit_BMP                   ${ADDON_BUILD}/${PKG_ADDON_ID}/lib/
    cp -PR $(get_build_dir Adafruit_Python_CharLCD)/Adafruit_CharLCD           ${ADDON_BUILD}/${PKG_ADDON_ID}/lib/
    cp -PR $(get_build_dir Adafruit_Python_DHT)/build/lib/Adafruit_DHT         ${ADDON_BUILD}/${PKG_ADDON_ID}/lib/
    cp -PR $(get_build_dir Adafruit_Python_GPIO)/Adafruit_GPIO                 ${ADDON_BUILD}/${PKG_ADDON_ID}/lib/
    cp -PR $(get_build_dir Adafruit_Python_LED_Backpack)/Adafruit_LED_Backpack ${ADDON_BUILD}/${PKG_ADDON_ID}/lib/
    cp -PR $(get_build_dir Adafruit_Python_LSM303)/Adafruit_LSM303             ${ADDON_BUILD}/${PKG_ADDON_ID}/lib/
    cp -PR $(get_build_dir Adafruit_Python_MCP3008)/Adafruit_MCP3008           ${ADDON_BUILD}/${PKG_ADDON_ID}/lib/
    cp -PR $(get_build_dir Adafruit_Python_MCP4725)/Adafruit_MCP4725           ${ADDON_BUILD}/${PKG_ADDON_ID}/lib/
    cp -PR $(get_build_dir Adafruit_Python_PCA9685)/Adafruit_PCA9685           ${ADDON_BUILD}/${PKG_ADDON_ID}/lib/
    cp -PR $(get_build_dir Adafruit_Python_PureIO)/Adafruit_PureIO             ${ADDON_BUILD}/${PKG_ADDON_ID}/lib/
    cp -PR $(get_build_dir Adafruit_Python_SI1145)/SI1145                      ${ADDON_BUILD}/${PKG_ADDON_ID}/lib/
    cp -PR $(get_build_dir Adafruit_Python_SSD1306)/Adafruit_SSD1306           ${ADDON_BUILD}/${PKG_ADDON_ID}/lib/
    cp -PR $(get_build_dir Adafruit_Python_TCS34725)/Adafruit_TCS34725         ${ADDON_BUILD}/${PKG_ADDON_ID}/lib/
    cp -PR $(get_build_dir Adafruit_Python_VCNL40xx)/Adafruit_VCNL40xx         ${ADDON_BUILD}/${PKG_ADDON_ID}/lib/
    cp -PR $(get_build_dir Adafruit_Python_WS2801)/Adafruit_WS2801             ${ADDON_BUILD}/${PKG_ADDON_ID}/lib/
}
