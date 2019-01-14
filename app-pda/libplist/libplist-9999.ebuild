# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: app-pda/libplist/libplist-9999.ebuild,v 1.0 2014/01/13 17:21:55 srcs Exp $

EAPI=5
PYTHON_COMPAT=( python2_7 )
inherit autotools git-2 python-r1

DESCRIPTION="A library to handle Apple Property List format in binary or XML"
HOMEPAGE="http://www.libimobiledevice.org/"
#SRC_URI=""
EGIT_REPO_URI="https://github.com/libimobiledevice/libplist.git"
#EGIT_MASTER="master"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="amd64 ~arm ~ppc ~ppc64 x86"
IUSE="python"

RDEPEND="dev-libs/libxml2"
DEPEND="${RDEPEND}
	python? (
		${PYTHON_DEPS}
		>=dev-python/cython-0.14.1-r1[${PYTHON_USEDEP}]
	)"

DOCS=( README )

MAKEOPTS+=" -j1" #406365

src_prepare() {
	eautoreconf
}

src_configure() {
	use python && python_export_best

	myconf=$(use_with python cython)
	econf $myconf
}

#src_install() {
#	default
#
#	prune_libtool_files --all
#}
