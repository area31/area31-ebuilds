EAPI="7"

DESCRIPTION="A simple treesize shell script for Linux"
HOMEPAGE="https://blog.aclarke.eu/2011/09/21/a-simple-treesize-shell-script-for-linux/"

LICENSE="BSD"
SLOT="0"
KEYWORDS="alpha amd64 hppa mips ppc ppc64 sparc x86"
IUSE=""

src_compile() {
	einfo "Nothing to compile, install scripts only"
}

S="${WORKDIR}"

src_install() {
	dobin "${FILESDIR}/treesize-script" || die
}
