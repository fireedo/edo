# libqt6pas-3.2.0.ebuild
EAPI=8

inherit qmake-utils

DESCRIPTION="Free Pascal Qt6 bindings library updated by Lazarus IDE."
HOMEPAGE="https://gitlab.com/freepascal.org/lazarus/lazarus"
SRC_URI="https://gitlab.com/freepascal.org/lazarus/lazarus/-/archive/lazarus_3_2.tar.gz -> ${P}.tar.gz"
KEYWORDS="~amd64 ~x86"

LICENSE="LGPL-3"
SLOT="0/3.2"

DEPEND="
    dev-qt/qtbase:6[gui,network]
"
RDEPEND="${DEPEND}"

S="${WORKDIR}/lazarus-lazarus_3_2/lcl/interfaces/qt6/cbindings"

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
