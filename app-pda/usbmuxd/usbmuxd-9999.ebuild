# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: app-pda/usbmuxd/usbmuxd-9999.ebuild,v 1.0 2013/10/31 17:05:12 srcs Exp $

EAPI=4
inherit autotools git-2 udev user

DESCRIPTION="USB multiplex daemon for use with Apple iPhone/iPod Touch devices"
HOMEPAGE="http://www.libimobiledevice.org/"
EGIT_REPO_URI="https://github.com/libimobiledevice/usbmuxd.git"

LICENSE="GPL-2 GPL-3"
SLOT="0"
KEYWORDS="amd64 ~arm ~ppc ~ppc64 x86"
IUSE="udev +worker systemd"

RDEPEND=">=app-pda/libplist-1.9
	virtual/libusb:1"
DEPEND="${RDEPEND}
	worker? ( >=app-pda/libusbmuxd-1.0.9 )
	>=app-pda/libimobiledevice-1.1.6
	virtual/pkgconfig"

DOCS=( AUTHORS README )

pkg_setup() {
	enewgroup plugdev
	enewuser usbmux -1 -1 -1 "usb,plugdev"
}

src_prepare() {
	eautoreconf
}

src_configure() {
	local myconf
	use worker || myconf='--without-preflight'
	use systemd || myconf='--without-systemd'

	econf ${myconf}
}

src_install() {
	default

	if ! use udev; then
		# There appears to be some disagreement as to where rules live :(
		if [[ -e "${ED}"/$(get_udevdir)/rules.d/39-usbmuxd.rules ]]; then
			rm "${ED}"/$(get_udevdir)/rules.d/39-usbmuxd.rules
			rmdir -p "${ED}"/$(get_udevdir)/rules.d
		elif [[ -e "${ED}"/usr/lib/udev/rules.d/39-usbmuxd.rules ]]; then
			rm "${ED}"/usr/lib/udev/rules.d/39-usbmuxd.rules
			rmdir -p "${ED}"/usr/lib/udev/rules.d
		fi
	fi
}
