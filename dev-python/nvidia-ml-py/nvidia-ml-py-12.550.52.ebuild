# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{8..12} )

inherit distutils-r1

DESCRIPTION="Python bindings to the NVIDIA Management Library"
HOMEPAGE="https://pypi.org/project/nvidia-ml-py/"
SRC_URI="https://files.pythonhosted.org/packages/source/n/nvidia-ml-py/nvidia-ml-py-${PV}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="dev-python/setuptools[${PYTHON_USEDEP}]"
RDEPEND="${DEPEND}
         x11-drivers/nvidia-drivers"

src_prepare() {
    distutils-r1_src_prepare
}

src_install() {
    distutils-r1_src_install
    if [[ -f README.md ]]; then
        dodoc README.md
    fi
}
