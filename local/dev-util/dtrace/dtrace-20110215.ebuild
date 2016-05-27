# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit eutils linux-info

DESCRIPTION="Dynamic tracing framework created (ported to Linux)"
HOMEPAGE="http://www.crisp.demon.co.uk/blog/"
SRC_URI="ftp://crispeditor.co.uk/pub/release/website/${PN}/2011/${P}.tar.bz2"


LICENSE="CDDL"
SLOT="0"
KEYWORDS=""
IUSE=""

RDEPEND="
	dev-libs/elfutils
	dev-libs/libdwarf"
DEPEND="${RDEPEND}
	dev-lang/perl
	sys-devel/flex
	sys-devel/bison
	virtual/linux-sources"

src_prepare() {
	rm build || die

	epatch \
		"${FILESDIR}"/${P}-destdir.patch \
		"${FILESDIR}"/${P}-build.patch
}

src_compile() {
	set_arch_to_kernel
	emake all
}

src_install() {
	dodoc Bugs CONTRIB Changes README Status.txt

	local KV_FULL=$(uname -r)
	local modulename=dtracedrv
	einfo "Installing ${modulename} module"
	insinto /lib/modules/${KV_FULL}/extra
	doins build-${KV_FULL}/driver/${modulename}.ko

	default
}
