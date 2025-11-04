PKG_NAME="python-uinput"
PKG_VERSION="master"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/tuomasjjrasanen/python-uinput"
PKG_URL="https://github.com/tuomasjjrasanen/python-uinput/archive/refs/heads/master.tar.gz"
PKG_DEPENDS_TARGET="toolchain systemd Python3"
PKG_SECTION="python"
PKG_LONGDESC="Pythonic API to create virtual input devices via uinput kernel module."
PKG_TOOLCHAIN="manual"


pre_configure_target() {
  export LDSHARED="${CC} -shared"
  export PYTHONPATH="${SYSROOT_PREFIX}/usr/lib/${PKG_PYTHON_VERSION}/site-packages:${PYTHONPATH}"
  export PYTHON_CPPFLAGS="-I${SYSROOT_PREFIX}/usr/include/${PKG_PYTHON_VERSION}"
  export PYTHON_LDFLAGS="-L${SYSROOT_PREFIX}/usr/lib -l${PKG_PYTHON_VERSION}"
  export PYTHON_SITE_PKG="${SYSROOT_PREFIX}/usr/lib/${PKG_PYTHON_VERSION}/site-packages"
  export _python_sysroot="${SYSROOT_PREFIX}"
  export _python_prefix="/usr"
  export _python_exec_prefix="/usr"
}


make_target() {
  python3 setup.py build_ext --include-dirs=${SYSROOT_PREFIX}/usr/include
  python3 setup.py build
}

makeinstall_target() {
  python3 setup.py install \
    --root=${INSTALL} \
    --prefix=/usr

}

post_makeinstall_target() {
  python_compile ${INSTALL}/usr/lib/python*/site-packages/
  python_remove_source ${INSTALL}/usr/lib/python*/site-packages/
}