# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="rclone"
PKG_VERSION="71a784cfa22cd4753950999b356c16231e4f6888"
PKG_SHA256="e47d769185971d3d414d4ca5f9532e5b476e4fc5b1d4da89a8437ed3049bf908"
PKG_ARCH="any"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/rclone/rclone"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain go:host"
PKG_LONGDESC="rsync for cloud storage - Google Drive, S3, Dropbox, Backblaze B2, One Drive, Swift, Hubic, Wasabi, Google Cloud Storage, Yandex Files"
PKG_TOOLCHAIN="manual"

configure_target() {

  case ${TARGET_ARCH} in
    arm)
      export GOARCH=arm

      case ${TARGET_CPU} in
        arm1176jzf-s)
          export GOARM=6
          ;;
        *)
          export GOARM=7
          ;;
      esac
      ;;
    aarch64)
      export GOARCH=arm64
      ;;
  esac

  export GOOS=linux
  export GOLANG=${TOOLCHAIN}/lib/golang/bin/go
  export LDFLAGS="-w -extldflags -static -X main.gitCommit=${PKG_VERSION} -X main.versionStr=${PKG_VERSION:0:7} -extld ${CC}"
}

make_target() {
  mkdir -p bin
  cd ${PKG_BUILD}
  ${GOLANG} get $(echo ${PKG_SITE} | sed s/'http[s]\?:\/\/'//)
  ${GOLANG} build -ldflags "${LDFLAGS}" $(echo ${PKG_SITE} | sed s/'http[s]\?:\/\/'//)
}

makeinstall_target() {
	mkdir -p ${INSTALL}/usr/bin/
	mkdir -p ${INSTALL}/usr/config/emuelec/configs/rclone
	cp ${PKG_BUILD}/rclone ${INSTALL}/usr/bin/
	cp ${PKG_DIR}/bin/ra_rclone.sh ${INSTALL}/usr/bin
	cp ${PKG_DIR}/config/emuelec-cloud-filter.cfg ${INSTALL}/usr/config/emuelec/configs/rclone/
	ln -sf /emuelec/configs/rclone ${INSTALL}/usr/config/rclone
}
