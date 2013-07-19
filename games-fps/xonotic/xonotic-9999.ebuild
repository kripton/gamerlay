# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils games toolchain-funcs flag-o-matic git-2

DESCRIPTION="Fork of Nexuiz, Deathmatch FPS based on DarkPlaces, an advanced Quake 1 engine"
HOMEPAGE="http://www.xonotic.org/"
BASE_URI="git://git.xonotic.org/${PN}/"
EGIT_REPO_URI="${BASE_URI}${PN}.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="alsa experimental +maps ode opengl +s3tc +sdl +server"
REQUIRED_USE="
	|| ( opengl sdl server )
"

UIRDEPEND="
	media-libs/libogg
	media-libs/libtheora[encode]
	media-libs/libvorbis
	media-libs/libmodplug
	x11-libs/libX11
	virtual/opengl
	media-libs/freetype:2
	~games-fps/xonotic-data-9999[client]
	s3tc? ( media-libs/libtxc_dxtn )
"
RDEPEND="
	sys-libs/zlib
	virtual/jpeg
	media-libs/libpng:0=
	net-misc/curl
	~dev-libs/d0_blind_id-${PV}
	~games-fps/xonotic-data-9999
	maps? ( ~games-fps/xonotic-maps-9999 )
	ode? ( dev-games/ode[double-precision] )
	opengl? (
		${UIRDEPEND}
		x11-libs/libXext
		x11-libs/libXpm
		x11-libs/libXxf86vm
		alsa? ( media-libs/alsa-lib )
	)
	sdl? (
		${UIRDEPEND}
		media-libs/libsdl[X,audio,joystick,opengl,video,alsa?]
	)
"
DEPEND="${RDEPEND}
	opengl? (
		x11-proto/xextproto
		x11-proto/xf86vidmodeproto
		x11-proto/xproto
	)
"

src_unpack() {
	git-2_src_unpack

	use experimental || EGIT_BRANCH="div0-stable"
	EGIT_REPO_URI="${BASE_URI}darkplaces.git" \
	EGIT_SOURCEDIR="${S}/darkplaces" \
	git-2_src_unpack
}

src_prepare() {
	tc-export CC
	# Required for DP_PRELOAD_DEPENDENCIES=1
	append-ldflags $(no-as-needed)

	epatch_user

	sed -e 's,Version=2.5,Version=1.0,' -i misc/logos/xonotic-*.desktop || die

	sed -i \
		-e "/^EXE_/s:darkplaces:${PN}:" \
		-e "/^OPTIM_RELEASE=/s:$: ${CFLAGS}:" \
		-e "/^LDFLAGS_RELEASE=/s:$: ${LDFLAGS}:" \
		darkplaces/makefile.inc || die

	if use !alsa; then
		sed -e "/DEFAULT_SNDAPI/s:ALSA:OSS:" \
			-i darkplaces/makefile || die
	fi
}

src_compile() {
	local targets=""
	local i

	use opengl && targets+=" cl-release"
	use sdl && targets+=" sdl-release"
	use server && targets+=" sv-release"

	cd darkplaces || die
	for i in ${targets}; do
		emake STRIP=true \
			DP_FS_BASEDIR="${GAMES_DATADIR}/${PN}" \
			DP_PRELOAD_DEPENDENCIES=1 \
			${i}
	done
}

src_install() {
	if use opengl; then
		dogamesbin darkplaces/${PN}-glx
		domenu misc/logos/xonotic-glx.desktop
	fi
	if use sdl; then
		dogamesbin darkplaces/${PN}-sdl
		domenu misc/logos/xonotic-sdl.desktop
	fi
	if use opengl || use sdl; then
		newicon misc/logos/icons_png/${PN}_512.png ${PN}.png
	fi
	use server && dogamesbin darkplaces/${PN}-dedicated

	dodoc Docs/*.txt
	dohtml -r Docs

	insinto "${GAMES_DATADIR}/${PN}"

	# public key for d0_blind_id
	doins key_0.d0pk

	use server && doins -r server

	prepgamesdirs
}
