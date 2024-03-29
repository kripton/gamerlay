# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4
inherit cmake-utils eutils games versionator unpacker

DESCRIPTION="ZDoom is an enhanced port of the official DOOM source code"
HOMEPAGE="http://www.zdoom.org"
SRC_URI="http://www.zdoom.org/files/${PN}/$(get_version_component_range 1-2)/${P}-src.7z"

LICENSE="BSD BUILD DOOM"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="gtk mmx"

RDEPEND="app-arch/bzip2
	media-libs/fmod
	media-libs/libsdl:0
	media-sound/fluidsynth
	sys-libs/zlib
	virtual/jpeg
	x11-libs/libXcursor
	gtk? ( x11-libs/gtk+:2 )"
DEPEND="${RDEPEND}
	mmx? ( || ( dev-lang/nasm dev-lang/yasm ) )"

S="${WORKDIR}"

src_prepare() {
	# Add new versions of FMOD
	sed -i \
		-e "s:\(set( MAJOR_VERSIONS\):\1 \"40\" \"38\":" \
		src/CMakeLists.txt || die
	# Use default game data path
	sed -i \
		-e "s:/usr/local/share/:${GAMES_DATADIR}/doom-data/:" \
		src/sdl/i_system.h || die "sed i_system.h failed"
}

src_configure() {
	mycmakeargs=(
		"-DFMOD_LOCAL_LIB_DIRS=/opt/fmodex/api/lib"
		"-DFMOD_INCLUDE_DIR=/opt/fmodex/api/inc"
#		"-DSHARE_DIR=\"${GAMES_DATADIR}/doom-data\""
		$(cmake-utils_use_no gtk GTK)
		$(cmake-utils_use_no mmx ASM)
	)
	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile
}

src_install() {
	dogamesbin "${CMAKE_BUILD_DIR}/${PN}" || die "dogamesbin failed"
	insinto "${GAMES_DATADIR}/doom-data"
	doins "${CMAKE_BUILD_DIR}/${PN}.pk3" || die "doins failed"
	dodoc docs/commands.txt
	dohtml docs/console.{css,html}
	prepgamesdirs
}

pkg_postinst() {
	games_pkg_postinst
	echo
	elog "Copy or link wad files into ${GAMES_DATADIR}/doom-data/"
	elog "(the files must be readable by the 'games' group)."
	elog
	elog "To play, simply run:"
	elog
	elog "   zdoom"
	echo
}
