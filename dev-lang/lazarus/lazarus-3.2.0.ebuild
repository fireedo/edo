# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
# lazarus-3.2.0.ebuild
EAPI=8

inherit desktop

DESCRIPTION="Feature rich visual programming environment emulating Delphi"
HOMEPAGE="https://www.lazarus-ide.org/"
SRC_URI="https://gitlab.com/freepascal.org/lazarus/lazarus/-/archive/lazarus_3_2/lazarus-lazarus_3_2.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2 LGPL-2.1-with-linking-exception"
SLOT="0/3.2"
KEYWORDS="~amd64 ~x86"
IUSE="gtk2 gtk3 +gui extras"
REQUIRED_USE="gtk2? ( gui ) gtk3? ( gui ) extras? ( gui )"

QA_FLAGS_IGNORED="
/usr/share/lazarus/startlazarus \
/usr/share/lazarus/lazarus \
/usr/share/lazarus/tools/lazres \
/usr/share/lazarus/tools/lrstolfm \
/usr/share/lazarus/tools/updatepofiles \
/usr/share/lazarus/tools/svn2revisioninc \
/usr/share/lazarus/lazbuild \
/usr/share/lazarus/components/chmhelp/lhelp/lhelp"

QA_PRESTRIPPED=${QA_FLAGS_IGNORED}

DEPEND="
    >=dev-lang/fpc-3.2.2[source]
    >=sys-devel/binutils-2.19.1-r1:=
    gui? (
        gtk3? ( x11-libs/gtk+:3 )
        gtk2? ( x11-libs/gtk+:2 )
        !gtk2? ( !gtk3? ( dev-qt/libqt6pas:0/6.2.7 ) )
    )
"
BDEPEND="net-misc/rsync"
RDEPEND="${DEPEND}"

RESTRICT="strip"

S="${WORKDIR}/lazarus-lazarus_3_2"

src_prepare() {
    default
    if ! test ${PPC_CONFIG_PATH+set} ; then
        local FPCVER=$(fpc -iV)
        export PPC_CONFIG_PATH="${WORKDIR}"
        sed -e 's/^FPBIN=/#&/' /usr/lib/fpc/${FPCVER}/samplecfg |
            sh -s /usr/lib/fpc/${FPCVER} "${PPC_CONFIG_PATH}" || die
    fi
}

src_compile() {
    if use gui; then
        if use gtk3; then
            export LCL_PLATFORM=gtk3
        elif use gtk2; then
            export LCL_PLATFORM=gtk2
        else
            export LCL_PLATFORM=qt6
        fi
    fi
    if use gui; then
        emake all $(usex extras "bigide lhelp" "") -j1 || die "make failed!"
    else
        emake lazbuild -j1 || die "make failed!"
    fi
}

src_install() {
    diropts -m0755
    dodir /usr/share/lazarus
    rsync -a \
        --exclude="CVS"     --exclude=".cvsignore" \
        --exclude="*.ppw"   --exclude="*.ppl" \
        --exclude="*.ow"    --exclude="*.a"\
        --exclude="*.rst"   --exclude=".#*" \
        --exclude="*.~*"    --exclude="*.bak" \
        --exclude="*.orig"  --exclude="*.rej" \
        --exclude=".xvpics" --exclude="*.compiled" \
        --exclude="killme*" --exclude=".gdb_hist*" \
        --exclude="debian"  --exclude="COPYING*" \
        --exclude="*.app" \
        "${S}/" "${ED}/usr/share/lazarus/" \
        || die "Unable to copy files!"

    if use gui; then
        dosym ../share/lazarus/startlazarus /usr/bin/startlazarus
        dosym ../share/lazarus/startlazarus /usr/bin/lazarus
    fi
    dosym ../share/lazarus/lazbuild /usr/bin/lazbuild
    if use extras && [ -f "${ED}/usr/share/lazarus/components/chmhelp/lhelp/lhelp" ]; then
        dosym ../share/lazarus/components/chmhelp/lhelp/lhelp /usr/bin/lhelp
    fi
    if [ -f "${ED}/usr/share/lazarus/images/ide_icon48x48.png" ]; then
        doicon "${ED}/usr/share/lazarus/images/ide_icon48x48.png"
        dosym ../share/lazarus/images/ide_icon48x48.png /usr/share/pixmaps/lazarus.png
    fi

    use gui && make_desktop_entry startlazarus "Lazarus IDE" "lazarus"
}

pkg_postinst() {
    xdg-icon-resource forceupdate --theme hicolor
    xdg-desktop-menu forceupdate
}

pkg_postrm() {
    xdg-icon-resource forceupdate --theme hicolor
    xdg-desktop-menu forceupdate
}
