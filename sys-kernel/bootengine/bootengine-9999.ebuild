# Copyright (c) 2013 CoreOS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_PROJECT="coreos/bootengine"
CROS_WORKON_LOCALNAME="bootengine"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_REPO="git://github.com"

if [[ "${PV}" == 9999 ]]; then
	KEYWORDS="~amd64 ~arm ~x86"
else
	CROS_WORKON_COMMIT="f95c568766e4fc61858f164398a866aa9c8f37df"
	KEYWORDS="amd64 arm x86"
fi

inherit cros-workon cros-debug cros-au

DESCRIPTION="CoreOS Bootengine"
SRC_URI=""

LICENSE="BSD"
SLOT="0/${PVR}"

DEPEND="
	app-arch/gzip
	app-shells/bash
	sys-apps/coreutils
	sys-apps/findutils
	sys-apps/grep
	sys-apps/less
	sys-apps/sed
	sys-apps/systemd
	sys-apps/systemd-sysv-utils
	sys-apps/util-linux
	sys-fs/btrfs-progs
	sys-fs/mdadm
	sys-kernel/dracut
	virtual/udev
	"
RDEPEND="${DEPEND}"

src_install() {
	insinto /usr/lib/dracut/modules.d/
	doins -r dracut/.
	dosbin update-bootengine

	# must be executable since dracut's install scripts just
	# re-use existing filesystem permissions during initrd creation.
	chmod +x "${D}"/usr/lib/dracut/modules.d/10*-generator/*-generator \
		"${D}"/usr/lib/dracut/modules.d/10diskless-generator/diskless-btrfs \
		|| die chmod
}

# We are bad, we want to get around the sandbox.  So do the creation of the
# cpio image in pkg_postinst() where we are free to mount filesystems, chroot,
# and other fun stuff.
pkg_postinst() {
	if [[ "${ROOT:-/}" != / ]]; then
		${ROOT}/usr/sbin/update-bootengine -m -c ${ROOT} || die
	else
		update-bootengine || die
	fi
}
