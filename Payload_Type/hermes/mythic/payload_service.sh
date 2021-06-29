#!/bin/bash

cd /Mythic/mythic
export PYTHONPATH=/Mythic:/Mythic/mythic
nohup python3 mythic_service.py &

set +e

if [ ! -d /sys/module/darling_mach ]; then
	echo "ERROR: The darling-mach kernel module isn't loaded!"
	exit 1
fi

export DYLD_ROOT_PATH=/usr/libexec/darling

exec "${DYLD_ROOT_PATH}/usr/libexec/darling/vchroot" "${DYLD_ROOT_PATH}" /sbin/launchd
