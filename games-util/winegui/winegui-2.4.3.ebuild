# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="WineGUI is a graphical user interface for Wine."
HOMEPAGE="https://gitlab.melroy.org/melroy/winegui"
SRC_URI="https://winegui.melroy.org/downloads/WineGUI-Source-v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="proton"

RDEPEND="
    proton? ( app-emulation/wine-proton )
    !proton? ( app-emulation/wine )
    dev-qt/qtcore
    dev-qt/qtgui
    dev-qt/qtnetwork
    dev-qt/qtwidgets
    dev-cpp/gtkmm:3.0
"
DEPEND="${RDEPEND}
    dev-build/cmake
"

S="${WORKDIR}"

inherit xdg

src_prepare() {
    default

    # Remove the glib-compile-schemas command from CMakeLists.txt
    sed -i '/glib-compile-schemas/d' "${S}/CMakeLists.txt"
}

src_configure() {
    cmake -B build -S "${S}" \
        -DCMAKE_INSTALL_PREFIX=/usr \
        -DCMAKE_BUILD_TYPE=Release
}

src_compile() {
    cmake --build build
}

src_install() {
    # Allow write access to the glib-2.0 schemas directory
    addpredict /usr/share/glib-2.0/schemas

    DESTDIR="${D}" cmake --install build

    # Install the binary
    dobin build/bin/winegui

    # Install desktop file and icons
    insinto /usr/share/applications
    doins "${S}/misc/winegui.desktop"

    insinto /usr/share/icons/hicolor/48x48/apps
    doins "${S}/misc/winegui.png"

    insinto /usr/share/icons/hicolor/scalable/apps
    doins "${S}/misc/winegui.svg"

    # Install additional resources if necessary
    insinto /usr/share/${PN}
    doins -r "${S}/images"
    doins -r "${S}/misc"

    # Install schema file without compiling
    insinto /usr/share/glib-2.0/schemas
    doins "${S}/src/schema/org.melroy.winegui.gschema.xml"
}

pkg_postinst() {
    xdg_icon_cache_update
    xdg_desktop_database_update
    elog "WineGUI has been installed. You can start it by running 'winegui' from the terminal."
}

pkg_postrm() {
    xdg_icon_cache_update
    xdg_desktop_database_update
    elog "WineGUI has been removed."
}
