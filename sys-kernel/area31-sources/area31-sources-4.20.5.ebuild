# Distributed under the terms of the BSD License

EAPI="7"

inherit eutils mount-boot

DESCRIPTION="Kernel binary provided by Area31 Hackerspace + sys-kernel/gentoo-sources"
HOMEPAGE="https://area31.net.br/wiki/LiveCD_oficial"
SRC_URI="https://area31.net.br/downloads/ebuilds/releases/${P}.tar.bz2"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64"
IUSE="kernel-source"

RDEPEND="app-arch/tar
		kernel-source? ( =sys-kernel/gentoo-sources-${PV}[symlink] )
"
DEPEND="${RDEPEND}
	app-arch/tar
"
src_compile() {
	einfo ""
	einfo "Nothing to compile, only install kernel files."
	einfo ""
}

S="${WORKDIR}/"

src_install()
{
	insinto /boot
	doins "${S}"/boot/config-${PV}-gentoo-area31-hackerspace
	doins "${S}"/boot/System.map-${PV}-gentoo-area31-hackerspace
	doins "${S}"/boot/vmlinuz-${PV}-gentoo-area31-hackerspace
	insinto /opt/area31/initramfs/area31-initram-livecd
	doins "${S}"/opt/area31/initramfs/area31-initram-livecd/initram.igz
	insinto /opt/area31/initramfs/better-initramfs
	doins "${S}"/opt/area31/initramfs/better-initramfs/initramfs.cpio.gz
	dodir /lib/modules
	cp -R "${S}"/lib/modules/${PV}-gentoo-area31-hackerspace "${D}"/lib/modules || die "Install files on /lib/modules failed!"
}

pkg_postinst() {
	depmod -a
	einfo ""
	einfo "app-admin/ego (ego boot update) is installed by default, but GRUB is not."
	einfo "As it is not required for all Funtoo Linux systems (such as containers, for example)."
	einfo "But for booting on bare metal, it is the recommended and best-supported boot loader, so you will need to emerge it:"
	einfo ""
	einfo ""
	einfo "Run: emerge -av grub"
	einfo ""
	einfo ""
	einfo "Kernel ${P} is now installed. Please run ego boot update to adjust your grub (boot-loader)."
	einfo ""
}
