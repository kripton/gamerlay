# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/sfemovie-9999.ebuild,v 1.2 2012/03/24 13:44:53 frostwork Exp $

EAPI=4

inherit cmake-utils eutils git-2 multilib

#MY_P="SFML-${PV}"
DESCRIPTION="ffmpeg based movie library for SFML"
HOMEPAGE="https://github.com/Yalir/sfeMovie"
EGIT_REPO_URI="git://github.com/Yalir/sfeMovie.git"

LICENSE="as-is"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND="media-libs/libsfml
	virtual/ffmpeg"
RDEPEND="${DEPEND}"

src_prepare() {
	epatch ${FILESDIR}/"${PN}-install.patch"
	sed -i -e "s:add_sub:#add_sub:g" -i CMakeLists.txt
}
