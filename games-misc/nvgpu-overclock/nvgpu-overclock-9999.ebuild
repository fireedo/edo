# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="NVIDIA GPU Overclocking Tool"
HOMEPAGE="https://github.com/fireedo/nvgpu-overclock"
SRC_URI="https://github.com/fireedo/nvgpu-overclock/archive/refs/heads/main.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

RDEPEND="dev-python/nvidia-ml-py
         dev-python/PyQt5
         x11-misc/xdg-utils"

S="${WORKDIR}/${PN}-main"

src_install() {
    insinto /usr/share/nvgpu-overclock
    doins -r *

    # Ensure the /usr/bin directory exists
    dodir /usr/bin

    # Install the executable wrapper
    echo -e "#!/bin/sh\nexec python3 /usr/share/nvgpu-overclock/overclock_gui.py" > "${D}/usr/bin/nvgpu-overclock"
    fperms +x /usr/bin/nvgpu-overclock

    # Install desktop entry and icon
    insinto /usr/share/applications
    doins "${S}/nvgpu-overclock.desktop"
    newicon "${S}/nvidia.png" "nvidia.png"
}

pkg_postinst() {
    xdg-desktop-menu forceupdate
    xdg-icon-resource forceupdate
}

pkg_postrm() {
    xdg-desktop-menu forceupdate
    xdg-icon-resource forceupdate
}
