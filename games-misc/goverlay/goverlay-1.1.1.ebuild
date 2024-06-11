# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
# goverlay-1.1.1.ebuild
EAPI=8

DESCRIPTION="GOverlay is a graphical overlay for monitoring gaming performance."
HOMEPAGE="https://github.com/benjamimgois/goverlay"
SRC_URI="https://github.com/benjamimgois/goverlay/archive/refs/tags/1.1.1.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="
    dev-qt/qtwidgets:5
    dev-libs/boost
    x11-apps/mesa-progs
    dev-util/vulkan-tools
    games-misc/mangohud
    media-gfx/vkBasalt
    dev-vcs/git
    dev-qt/libqt6pas
    dev-lang/lazarus
    x11-misc/xdg-utils
"
DEPEND="${RDEPEND}
    virtual/pkgconfig
"

S="${WORKDIR}/goverlay-1.1.1"

src_prepare() {
    default
}

src_configure() {
    :
}

src_compile() {
    export LAZARUSDIR="/usr/share/lazarus"
    ${LAZARUSDIR}/lazbuild -B goverlay.lpi --lazarusdir=${LAZARUSDIR} --bm=Release
}

src_install() {
    dobin goverlay
    dodoc README.md

    # Install desktop entry for KDE menu
    insinto /usr/share/applications
    doins "${FILESDIR}/goverlay.desktop"

    # Install icon
    doicon "${FILESDIR}/goverlay-icon.png" -s 128
}

pkg_postinst() {
    # Ensure the QT environment is set to either Qt5 or Qt6
    if [ -x "/usr/bin/qtpaths" ]; then
        QT_BIN_PATH="/usr/bin"
    elif [ -x "/usr/lib64/qt6/bin/qtpaths" ]; then
        QT_BIN_PATH="/usr/lib64/qt6/bin"
        export QT_SELECT=qt6
    else
        echo "qtpaths not found. Ensure Qt5 or Qt6 is installed."
        exit 1
    fi

    export QT_PLUGIN_PATH="${QT_BIN_PATH}/../plugins"
    export PATH="${QT_BIN_PATH}:${PATH}"

    mkdir -p ~/.config

    xdg-icon-resource forceupdate --theme hicolor
    xdg-desktop-menu forceupdate
    xdg-mime default goverlay.desktop application/x-goverlay

    einfo ""
    einfo "GOverlay is a GUI program for configuring MangoHUD and vkBasalt."
    einfo ""
    einfo "MangoHUD can be installed via the package <games-misc/mangohud>."
    einfo "vkBasalt can be installed via the package <media-gfx/vkBasalt>."
    einfo ""
}

pkg_postrm() {
    xdg-icon-resource forceupdate --theme hicolor
    xdg-desktop-menu forceupdate
    xdg-mime default goverlay.desktop application/x-goverlay
}

RESTRICT="strip"
