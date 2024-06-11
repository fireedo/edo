# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

QT5MIN="5.15.0"
QT6MIN="6.2.0"
KF5MIN="5.82.0"

inherit cmake xdg

DESCRIPTION="SVG-based theme engine for Qt5, Qt6, KDE Plasma and LXQt"
HOMEPAGE="https://github.com/tsujan/Kvantum"
SRC_URI="https://github.com/tsujan/Kvantum/releases/download/V${PV}/Kvantum-${PV}.tar.xz"
S="${WORKDIR}/Kvantum-${PV}/Kvantum"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~ppc64 ~x86"
IUSE="qt6"

RESTRICT="test" # no tests

CDEPEND="
	>=dev-qt/qtcore-${QT5MIN}:5
	>=dev-qt/qtgui-${QT5MIN}:5
	>=dev-qt/qtsvg-${QT5MIN}:5
	>=dev-qt/qtwidgets-${QT5MIN}:5
	>=dev-qt/qtx11extras-${QT5MIN}:5
	>=kde-frameworks/kwindowsystem-${KF5MIN}:5
	x11-libs/libX11
	qt6? (
		>=dev-qt/qtbase-${QT6MIN}:6[gui,widgets]
		>=dev-qt/qtsvg-${QT6MIN}:6
	)
"
DEPEND="
	${CDEPEND}
	x11-base/xorg-proto
"
RDEPEND="
	${CDEPEND}
"
BDEPEND="
	dev-qt/linguist-tools:5
	qt6? ( dev-qt/qttools:6[linguist] )
"

BUILD_DIR_QT6="${S}_qt6"

src_configure() {
	local mycmakeargs=(
		-DENABLE_QT4=OFF
		-DENABLE_QT5=ON
		-DWITHOUT_KF=OFF
	)
	cmake_src_configure

	if use qt6; then
		local mycmakeargs=(
			-DENABLE_QT4=OFF
			-DENABLE_QT5=OFF
			-DWITHOUT_KF=ON
		)
		BUILD_DIR="${BUILD_DIR_QT6}" cmake_src_configure
	fi
}

src_compile() {
	cmake_src_compile
	if use qt6; then
		BUILD_DIR="${BUILD_DIR_QT6}" cmake_src_compile
	fi
}

src_install() {
	cmake_src_install
	if use qt6; then
		BUILD_DIR="${BUILD_DIR_QT6}" cmake_src_install
	fi

	einstalldocs
}
