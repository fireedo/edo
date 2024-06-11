# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
# libqt6pas-6.2.7.ebuild
EAPI=8

inherit qmake-utils

DESCRIPTION="Free Pascal Qt6 bindings library updated by Lazarus IDE."
HOMEPAGE="https://gitlab.com/freepascal.org/lazarus/lazarus"
SRC_URI="https://gitlab.com/freepascal.org/lazarus/lazarus/-/archive/lazarus_3_2.tar.gz -> ${P}.tar.gz"
KEYWORDS="~amd64 ~x86"

LICENSE="LGPL-3"
SLOT="0/6.2.7"

DEPEND="
    dev-qt/qtbase:6[gui,network]
"
RDEPEND="${DEPEND}"

# Initial S value to work around the directory naming issue
S="${WORKDIR}"

src_unpack() {
    default
    # Find the actual directory name and set S accordingly
    local actual_dir
    actual_dir=$(find "${WORKDIR}" -mindepth 1 -maxdepth 1 -type d -name "lazarus-lazarus_3_2*" | head -n 1)
    if [[ -n "${actual_dir}" ]]; then
        S="${actual_dir}/lcl/interfaces/qt6/cbindings"
    else
        die "Failed to find the source directory"
    fi
}

src_prepare() {
    default
    # Workaround to comment out the problematic line
    sed -i 's/->isSimpleText();/->isEmpty();/' src/qstring_c.cpp
}

src_configure() {
    eqmake6 Qt6Pas.pro
}

src_compile() {
    emake
}

src_install() {
    emake INSTALL_ROOT="${D}" install
}
