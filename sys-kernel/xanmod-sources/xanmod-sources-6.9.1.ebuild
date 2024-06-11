# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"

K_WANT_GENPATCHES="base extras"
K_GENPATCHES_VER="2"

XANMOD_VERSION="1"

ETYPE="sources"
K_SECURITY_UNSUPPORTED="1"
K_NOSETEXTRAVERSION="1"

inherit kernel-2
detect_version
detect_arch

DESCRIPTION="Full XanMod sources including the Gentoo patchset with Dracut support"
HOMEPAGE="https://xanmod.org"
SRC_URI="
	${KERNEL_BASE_URI}/linux-${KV_MAJOR}.${KV_MINOR}.tar.xz
	https://downloads.sourceforge.net/xanmod/patch-${OKV}-xanmod${XANMOD_VERSION}.xz
	${GENPATCHES_URI}
"
LICENSE+=" CDDL"
KEYWORDS="~amd64"
DEPEND="sys-kernel/dracut"

src_unpack() {
	UNIPATCH_STRICTORDER=1
	UNIPATCH_LIST_DEFAULT="${DISTDIR}/patch-${OKV}-xanmod${XANMOD_VERSION}.xz "
	UNIPATCH_EXCLUDE="${UNIPATCH_EXCLUDE} 1*_linux-${KV_MAJOR}.${KV_MINOR}.*.patch"
	kernel-2_src_unpack
}

pkg_postinst() {
	elog "MICROCODES"
	elog "Use xanmod-sources with microcodes"
	elog "Read https://wiki.gentoo.org/wiki/Intel_microcode"
	elog "DRACUT"
	elog "Dracut is now a part of this kernel source ebuild."
	elog "An initramfs will be created for the EFI stub."

    # Ensure /usr/src/linux points to the current kernel source
    if [ ! -e /usr/src/linux ]; then
        eselect kernel list
        ewarn "Please select the appropriate kernel source with eselect kernel."
        return 1
    fi

    # Define the kernel version
    local KERNEL_DIR="/usr/src/linux"
    local KV=$(make -sC "${KERNEL_DIR}" kernelrelease)

    # Check if the kernel version was retrieved
    if [ -z "${KV}" ]; then
        ewarn "Failed to determine the kernel version. Initramfs will not be created."
        return 1
    fi

    # Define dracut options
    local _dracut_options=""

    # Ensure the target directory exists
    local target_dir="/boot/efi/${KV}"
    if [ ! -d "${target_dir}" ]; then
        mkdir -p "${target_dir}" || {
            ewarn "Failed to create directory ${target_dir}. Initramfs will not be created."
            return 1
        }
    fi

    # Create initramfs using dracut
    if [ -x "/usr/bin/dracut" ]; then
        ebegin "Generating initramfs with Dracut"
        dracut --force --hostonly ${_dracut_options} --kver "${KV}"
        eend $?
    else
        ewarn "Dracut is not installed or not executable. Initramfs was not created."
    fi
}
