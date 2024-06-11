# HWMio-0.1.0.ebuild

EAPI=8

DESCRIPTION="A hardware monitoring tool based on Qt5 or Qt6"
HOMEPAGE="https://github.com/fireedo/HWMio"
SRC_URI="https://github.com/fireedo/HWMio/releases/download/HWMio/HWMio-0.1.0.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="qt5 qt6"

DEPEND="
    sys-apps/lm-sensors
    sys-apps/util-linux
    sys-apps/dmidecode
    sys-apps/msr-tools
    x11-drivers/nvidia-drivers
    || ( dev-python/pynvml dev-python/nvidia-ml-py )
    qt5? ( dev-qt/qtcore:5 dev-qt/qtgui:5 dev-qt/qtwidgets:5 )
    qt6? ( dev-qt/qtcore:6 dev-qt/qtgui:6 dev-qt/qtwidgets:6 )
"
RDEPEND="${DEPEND}"

S="${WORKDIR}/hwmio-0.1.0"

src_unpack() {
    unpack ${A}
    cd "${S}"
}

src_prepare() {
    default
    mkdir build
    # Remove polkit policy installation to avoid permission issues during build
    sed -i '/install_policy.sh/d' CMakeLists.txt
}

src_configure() {
    cmake -B build -S . \
        $(usex qt5 "-DWITH_QT5=ON" "-DWITH_QT5=OFF") \
        $(usex qt6 "-DWITH_QT6=ON" "-DWITH_QT6=OFF")
}

src_compile() {
    cmake --build build
}

src_install() {
    DESTDIR="${D}" cmake --install build

    # Move the binary to /usr/bin and name it 'hwmio'
    dobin build/HWMio || die "Failed to move binary"

    # Check if README.md exists before trying to install it
    if [[ -f README.md ]]; then
        dodoc README.md
    fi

    # Install KDE menu entry
    insinto /usr/share/applications
    doins "${FILESDIR}/hwmio.desktop"

    # Install application icon
    insinto /usr/share/icons/hicolor/48x48/apps
    doins "${FILESDIR}/HWMio.png"

    # Install polkit policy
    dodir /etc/polkit-1/localauthority/50-local.d
    insinto /etc/polkit-1/localauthority/50-local.d
    newins "${S}/files/com.example.hwminfo.pkla" "com.example.hwminfo.pkla"
}

pkg_postinst() {
    elog "To add HWMio to the KDE menu, a .desktop file and an icon have been installed."
    elog "Polkit policy for HWMio has been installed."
}
