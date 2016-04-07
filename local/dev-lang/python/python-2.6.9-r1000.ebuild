# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
WANT_AUTOMAKE="none"
WANT_LIBTOOL="none"

inherit autotools eutils flag-o-matic multilib pax-utils python toolchain-funcs

if [[ "${PV}" == *_pre* ]]; then
	inherit mercurial

	EHG_REPO_URI="https://hg.python.org/cpython"
	EHG_REVISION=""
else
	MY_PV="${PV%_p*}"
	MY_P="Python-${MY_PV}"
fi

PATCHSET_REVISION="0"

DESCRIPTION="Python is an interpreted, interactive, object-oriented programming language."
HOMEPAGE="https://www.python.org/"
if [[ "${PV}" == *_pre* ]]; then
	SRC_URI=""
else
	SRC_URI="https://www.python.org/ftp/python/${MY_PV}/${MY_P}.tar.xz"
	if [[ "${PR#r}" -lt 1000 ]]; then
		SRC_URI+=" https://people.apache.org/~Arfrever/gentoo/python-gentoo-patches-${MY_PV}$([[ "${PATCHSET_REVISION}" != "0" ]] && echo "-r${PATCHSET_REVISION}").tar.bz2"
	fi
fi

LICENSE="PSF-2"
SLOT="2.6"
PYTHON_ABI="${SLOT}"
KEYWORDS="*"
IUSE="-berkdb build doc elibc_uclibc examples gdbm ipv6 +ncurses +readline sqlite +ssl +threads tk +wide-unicode wininst +xml"
RDEPEND="app-arch/bzip2
        app-arch/xz-utils
        >=sys-libs/zlib-1.1.3
        virtual/libffi
        virtual/libintl
        !build? (
                gdbm? ( sys-libs/gdbm[berkdb] )
                ncurses? (
                        >=sys-libs/ncurses-5.2
                        readline? ( >=sys-libs/readline-4.1 )
                )
                sqlite? ( >=dev-db/sqlite-3.3.8:3 )
                ssl? ( dev-libs/openssl )
                tk? (
                        >=dev-lang/tk-8.0
                        dev-tcltk/blt
                        dev-tcltk/tix
                )
                xml? ( >=dev-libs/expat-2.1 )
        )
        !!<sys-apps/sandbox-2.6-r1"
DEPEND="${RDEPEND}
        virtual/pkgconfig
        >=sys-devel/autoconf-2.65
        !sys-devel/gcc[libffi]"
RDEPEND+=" !build? ( app-misc/mime-types )
        doc? ( dev-python/python-docs:${SLOT} )"
PDEPEND="app-eselect/eselect-python
        app-admin/python-updater"
if [[ "${PV}" != *_pre* ]]; then
	S="${WORKDIR}/${MY_P}"
fi

pkg_setup() {
	python_pkg_setup

	if use berkdb; then
		ewarn "\"bsddb\" module is out-of-date and no longer maintained inside dev-lang/python."
		ewarn "\"bsddb\" and \"dbhash\" modules have been additionally removed in Python 3."
		ewarn "You should use external, still maintained \"bsddb3\" module provided by dev-python/bsddb3,"
		ewarn "which supports both Python 2 and Python 3."
	else
		if has_version "=${CATEGORY}/${PN}-${PV%%.*}*[berkdb]"; then
			ewarn "You are migrating from =${CATEGORY}/${PN}-${PV%%.*}*[berkdb] to =${CATEGORY}/${PN}-${PV%%.*}*[-berkdb]."
			ewarn "You might need to migrate your databases."
		fi
	fi
}

src_prepare() {
	# Ensure that internal copies of expat, libffi and zlib are not used.
	rm -fr Modules/expat
	rm -fr Modules/_ctypes/libffi*
	rm -fr Modules/zlib

	if [[ "${PV}" =~ ^[[:digit:]]+\.[[:digit:]]+_pre ]]; then
		if [[ "$(hg branch)" != "default" ]]; then
			die "Invalid EHG_REVISION"
		fi
	fi

	if [[ "${PV}" =~ ^[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+_pre ]]; then
		if [[ "$(hg branch)" != "${SLOT}" ]]; then
			die "Invalid EHG_REVISION"
		fi

		if grep -Eq '#define PY_RELEASE_LEVEL[[:space:]]+PY_RELEASE_LEVEL_FINAL' Include/patchlevel.h; then
			# Update micro version, release level and version string.
			local micro_version="${PV%_pre*}"
			micro_version="${micro_version##*.}"
			local version_string="${PV%.*}.$((${micro_version} - 1))+"
			sed \
				-e "s/\(#define PY_MICRO_VERSION[[:space:]]\+\)[^[:space:]]\+/\1${micro_version}/" \
				-e "s/\(#define PY_RELEASE_LEVEL[[:space:]]\+\)[^[:space:]]\+/\1PY_RELEASE_LEVEL_ALPHA/" \
				-e "s/\(#define PY_VERSION[[:space:]]\+\"\)[^\"]\+\(\"\)/\1${version_string}\2/" \
				-i Include/patchlevel.h || die "sed failed"
		fi
	fi

	local excluded_patches
	if ! tc-is-cross-compiler; then
		excluded_patches="*_all_crosscompile.patch"
	fi

	local patchset_dir
	if [[ "${PV}" == *_pre* ]]; then
		patchset_dir="${FILESDIR}/${SLOT}-${PATCHSET_REVISION}"
	elif [[ "${PR#r}" -ge 1000 ]]; then
		patchset_dir="${FILESDIR}/${PV}-${PATCHSET_REVISION}"
	else
		patchset_dir="${WORKDIR}/${MY_PV}"
	fi

	EPATCH_EXCLUDE="${excluded_patches}" EPATCH_SUFFIX="patch" epatch "${patchset_dir}"

	sed -i -e "s:@@GENTOO_LIBDIR@@:$(get_libdir):g" \
		Lib/distutils/command/install.py \
		Lib/distutils/sysconfig.py \
		Lib/site.py \
		Makefile.pre.in \
		Modules/getpath.c \
		Modules/Setup.dist \
		setup.py || die "sed failed to replace @@GENTOO_LIBDIR@@"

	eautoconf
	eautoheader
}

src_configure() {
	if use build; then
		# Disable extraneous modules with extra dependencies.
		export PYTHON_DISABLE_MODULES="dbm _bsddb gdbm _curses _curses_panel readline _sqlite3 _tkinter _elementtree pyexpat"
		export PYTHON_DISABLE_SSL="1"
	else
		# dbm module can be linked against berkdb or gdbm.
		# Defaults to gdbm when both are enabled, #204343.
		local disable
		use berkdb   || use gdbm || disable+=" dbm"
		use berkdb   || disable+=" _bsddb"
		use gdbm     || disable+=" gdbm"
		use ncurses  || disable+=" _curses _curses_panel"
		use readline || disable+=" readline"
		use sqlite   || disable+=" _sqlite3"
		use ssl      || export PYTHON_DISABLE_SSL="1"
		use tk       || disable+=" _tkinter"
		use xml      || disable+=" _elementtree pyexpat" # _elementtree uses pyexpat.
		export PYTHON_DISABLE_MODULES="${disable}"

		if ! use xml; then
			ewarn "You have configured Python without XML support."
			ewarn "This is NOT a recommended configuration as you"
			ewarn "may face problems parsing any XML documents."
		fi
	fi

	if [[ -n "${PYTHON_DISABLE_MODULES}" ]]; then
		einfo "Disabled modules: ${PYTHON_DISABLE_MODULES}"
	fi

	if [[ "$(gcc-major-version)" -ge 4 ]]; then
		append-flags -fwrapv
	fi

	filter-flags -malign-double

	[[ "${ARCH}" == "alpha" ]] && append-flags -fPIC

	# https://bugs.gentoo.org/show_bug.cgi?id=50309
	if is-flagq -O3; then
		is-flagq -fstack-protector-all && replace-flags -O3 -O2
		use hardened && replace-flags -O3 -O2
	fi

	if tc-is-cross-compiler; then
		OPT="-O1" CFLAGS="" LDFLAGS="" CC="" \
		./configure --{build,host}=${CBUILD} || die "cross-configure failed"
		emake python Parser/pgen || die "cross-make failed"
		mv python hostpython
		mv Parser/pgen Parser/hostpgen
		make distclean
		sed -i \
			-e "/^HOSTPYTHON/s:=.*:=./hostpython:" \
			-e "/^HOSTPGEN/s:=.*:=./Parser/hostpgen:" \
			Makefile.pre.in || die "sed failed"
	fi

	# Export CXX so it ends up in /usr/lib/python2.X/config/Makefile.
	tc-export CXX

	ac_cv_path_PKG_CONFIG="$(tc-getPKG_CONFIG)" OPT="" econf \
		--with-fpectl \
		--enable-shared \
		$(use_enable ipv6) \
		$(use_with threads) \
		$(use wide-unicode && echo "--enable-unicode=ucs4" || echo "--enable-unicode=ucs2") \
		--infodir='${prefix}/share/info' \
		--mandir='${prefix}/share/man' \
		--with-libc="" \
		--with-system-ffi
}

src_compile() {
	emake EPYTHON="python${PV%%.*}" || die "emake failed"

	if has_version dev-libs/libffi[pax_kernel]; then
		pax-mark E python
	else
		pax-mark m python
	fi
}

src_test() {
	# Tests will not work when cross compiling.
	if tc-is-cross-compiler; then
		elog "Disabling tests due to crosscompiling."
		return
	fi

	# Byte-compilation should be enabled here.
	# Otherwise test_import fails.
	python_enable_byte-compilation

	# Skip failing tests.
	local skipped_tests="distutils tcl"

	for test in ${skipped_tests}; do
		mv Lib/test/test_${test}.py "${T}"
	done

	emake test EXTRATESTOPTS="-w" < /dev/tty
	local result="$?"

	for test in ${skipped_tests}; do
		mv "${T}/test_${test}.py" Lib/test
	done

	elog "The following tests have been skipped:"
	for test in ${skipped_tests}; do
		elog "test_${test}.py"
	done

	elog "If you would like to run them, you may:"
	elog "cd '${EPREFIX}$(python_get_libdir)/test'"
	elog "and run the tests separately."

	python_disable_byte-compilation

	if [[ "${result}" -ne 0 ]]; then
		die "emake test failed"
	fi
}

src_install() {
	emake DESTDIR="${D}" altinstall maninstall || die "emake altinstall maninstall failed"
	python_clean_installation_image -q

	dosym python${SLOT}-config /usr/bin/python-config-${SLOT}

	# Fix collisions between different slots of Python.
	mv "${ED}usr/bin/2to3" "${ED}usr/bin/2to3-${SLOT}"
	mv "${ED}usr/bin/pydoc" "${ED}usr/bin/pydoc${SLOT}"
	mv "${ED}usr/bin/idle" "${ED}usr/bin/idle${SLOT}"
	mv "${ED}usr/share/man/man1/python.1" "${ED}usr/share/man/man1/python${SLOT}.1"
	rm -f "${ED}usr/bin/smtpd.py"

	if use build; then
		rm -fr "${ED}usr/bin/idle${SLOT}" "${ED}$(python_get_libdir)/"{bsddb,dbhash.py,idlelib,lib-tk,sqlite3,test}
	else
		use elibc_uclibc && rm -fr "${ED}$(python_get_libdir)/"{bsddb/test,test}
		use berkdb || rm -fr "${ED}$(python_get_libdir)/"{bsddb,dbhash.py,test/test_bsddb*}
		use sqlite || rm -fr "${ED}$(python_get_libdir)/"{sqlite3,test/test_sqlite*}
		use tk || rm -fr "${ED}usr/bin/idle${SLOT}" "${ED}$(python_get_libdir)/"{idlelib,lib-tk}
	fi

	use threads || rm -fr "${ED}$(python_get_libdir)/multiprocessing"
	use wininst || rm -f "${ED}$(python_get_libdir)/distutils/command/"wininst-*.exe

	dodoc Misc/{ACKS,HISTORY,NEWS} || die "dodoc failed"

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins -r Tools || die "doins failed"
	fi

	newconfd "${FILESDIR}/pydoc.conf" pydoc-${SLOT} || die "newconfd failed"
	newinitd "${FILESDIR}/pydoc.init" pydoc-${SLOT} || die "newinitd failed"
	sed \
		-e "s:@PYDOC_PORT_VARIABLE@:PYDOC${SLOT/./_}_PORT:" \
		-e "s:@PYDOC@:pydoc${SLOT}:" \
		-i "${ED}etc/conf.d/pydoc-${SLOT}" "${ED}etc/init.d/pydoc-${SLOT}" || die "sed failed"
}

pkg_preinst() {
	if has_version "<${CATEGORY}/${PN}-${SLOT}" && ! has_version "${CATEGORY}/${PN}:2.6" && ! has_version "${CATEGORY}/${PN}:2.7"; then
		python_updater_warning="1"
	fi
}

eselect_python_update() {
	if [[ -z "$(eselect python show)" || ! -f "${EROOT}usr/bin/$(eselect python show)" ]]; then
		eselect python update
	fi

	if [[ -z "$(eselect python show --python${PV%%.*})" || ! -f "${EROOT}usr/bin/$(eselect python show --python${PV%%.*})" ]]; then
		eselect python update --python${PV%%.*}
	fi
}

pkg_postinst() {
	eselect_python_update

	python_byte-compile_modules -f -x "/(site-packages|test|tests)/" $(python_get_libdir)

	if [[ "${python_updater_warning}" == "1" ]]; then
		ewarn
		ewarn "\e[1;31m************************************************************************\e[0m"
		ewarn
		ewarn "You have just upgraded from an older version of Python. You should:"
		ewarn "1. Run 'emerge --oneshot sys-apps/portage'"
		ewarn "2. Update potential PYTHON_* variables in make.conf and package.use"
		ewarn "3. Run 'emerge --nodeps --oneshot sys-apps/portage'"
		ewarn "4. Switch active version of Python ${PV%%.*} using 'eselect python'"
		ewarn "5. Run 'emerge --update --deep --newuse @world'"
		ewarn
		ewarn "\e[1;31m************************************************************************\e[0m"
		ewarn
		echo -ne "\a"
	fi
}

pkg_postrm() {
	eselect_python_update

	python_clean_byte-compiled_modules $(python_get_libdir)
}
