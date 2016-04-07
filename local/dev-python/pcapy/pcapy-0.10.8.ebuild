# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

PYTHON_DEPEND="2"
SUPPORT_PYTHON_ABIS="1"
RESTRICT_PYTHON_ABIS="3.*"

RDEPEND="${DEPEND}
	 net-libs/libpcap"

inherit distutils

DESCRIPTION="Python pcap extension"
HOMEPAGE="http://www.coresecurity.com/corelabs-research/open-source-tools/pcapy"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz
	http://oss.coresecurity.com/repo/${P}.tar.gz"

LICENSE="Apache-1.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
