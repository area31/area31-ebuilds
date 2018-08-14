EAPI="2"

inherit eutils

DESCRIPTION="Admin scripts provided with RescueCD Area31 Hackerspace"
HOMEPAGE="https://www.area31.net.br/wiki/RescueCD_oficial"

LICENSE="BSD"
SLOT="0"
KEYWORDS="alpha amd64 hppa mips ppc ppc64 sparc x86"
IUSE=""

DEPEND=">=dev-lang/python-2.4.0
		dev-util/dialog
		dev-libs/libisoburn
		sys-fs/squashfs-tools
		sys-apps/hwsetup
		sys-apps/sysresccd-scripts
		sys-apps/sysresccd-custom
		app-backup/fsarchiver
		sys-apps/util-linux
		app-admin/pwgen
        >=app-shells/bash-3.1"
RDEPEND="${DEPEND}"

src_compile() {
	einfo "Nothing to compile, install scripts only"
}

src_install()
{
	insinto /etc/area31
	doins "${FILESDIR}"/area31-logo-menu-lxqt.png
	doins "${FILESDIR}"/Bg-blur-area31_1920_x_1200.png
	doins "${FILESDIR}"/Bg-blur-area31-2017_1920_x_1200.png
	doins "${FILESDIR}"/logo_linux_clut224.ppm
	insinto /usr/share/"${PN}"
	doins "${FILESDIR}"/sysresccd-area31-umount
	doins "${FILESDIR}"/sysresccd-area31-mount
	doins "${FILESDIR}"/sysresccd-area31-swap
	doins "${FILESDIR}"/sysresccd-area31-partition
	doins "${FILESDIR}"/sysresccd-area31-targets
	doins "${FILESDIR}"/sysresccd-area31-help
	doins "${FILESDIR}"/sysresccd-area31-help.txt
	doins "${FILESDIR}"/sysresccd-area31-keymap
	doins "${FILESDIR}"/sysresccd-area31-showmount
	doins "${FILESDIR}"/sysresccd-area31-format
	insinto /etc/init.d
	newinitd "${FILESDIR}"/autorun autorun
	newinitd "${FILESDIR}"/dostartx dostartx
	newinitd "${FILESDIR}"/load-fonts-keymaps load-fonts-keymaps
	newinitd "${FILESDIR}"/sysresccd sysresccd
	newinitd "${FILESDIR}"/netconfig2 netconfig2
	dosbin "${FILESDIR}"/sysresccd-area31 || die
}
