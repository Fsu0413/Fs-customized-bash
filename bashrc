#!/usr/bin/env bash

if [ "x${BASH_VERSION}" = "x" ]; then
	echo "ERROR: BASH_VERSION not defined." >&2
	echo "Please use BASH for using this script." >&2
	return 1 2> /dev/null || exit 1
fi

FS_CUSTOMIZED_BASH_VERSION_SUPPORTED=false

if [ ${BASH_VERSINFO[0]} -eq 4 ]; then
	if [ ${BASH_VERSINFO[0]} -ge 3 ]; then
		FS_CUSTOMIZED_BASH_VERSION_SUPPORTED=true
	fi
elif [ ${BASH_VERSINFO[0]} -ge 5 ]; then
	FS_CUSTOMIZED_BASH_VERSION_SUPPORTED=true
fi

if ! $FS_CUSTOMIZED_BASH_VERSION_SUPPORTED; then
	echo "WARNING: Bash version not supported." >&2
	echo "Please use BASH >= 4.3 to use this script." >&2
fi

# The recommended way for judging if our script is being sourced according to StackOverflow, since Bash 4.3
# if ! [ "x${FUNCNAME[0]}" = "xsource" ]; then

# MSYS2 way
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
	echo "ERROR: Directly running this script is not supported." >&2
	echo "Please use \". $0\" for SOURCE-ing this script file." >&2
	unset FS_CUSTOMIZED_BASH_VERSION_SUPPORTED
	return 1 2> /dev/null || exit 1
fi

if ! $FS_CUSTOMIZED_BASH_VERSION_SUPPORTED; then
	unset FS_CUSTOMIZED_BASH_VERSION_SUPPORTED
	return 1 2> /dev/null || exit 1
fi

# Since here, we can confirm that our script is being sourced.
unset FS_CUSTOMIZED_BASH_VERSION_SUPPORTED

if ! ( realpath --help > /dev/null 2> /dev/null ); then
	echo "realpath is needed for executing this script. Please install realpath from your package manager." >&2
	return 1
fi

if ! ( which ${SHELL} > /dev/null 2> /dev/null ); then
	echo "which is needed for executing this script. Please install which from your package manager." >&2
	return 1
fi

FS_CUSTOMIZED_BASH_ROOT=$(dirname `realpath "${BASH_SOURCE[0]}"`)

if [ -r "${FS_CUSTOMIZED_BASH_ROOT}/conf.fsbash" ]; then
	. "${FS_CUSTOMIZED_BASH_ROOT}/conf.fsbash"
else
	echo "${FS_CUSTOMIZED_BASH_ROOT}/conf.fsbash doesn't exist. This is the core configuration file of FsBash. Exiting." >&2
	return 1
fi

# utility logs

Fs_Customized_Bash_log()
{
	local color="$FS_CUSTOMIZED_BASH_COLOR_LOG"
	local tostderr=false
	case "$1" in
		"warn")
			color="$FS_CUSTOMIZED_BASH_COLOR_WARN"
			tostderr=true
			shift
			;;
		"error")
			color="$FS_CUSTOMIZED_BASH_COLOR_ERROR"
			tostderr=true
			shift
			;;
		*)
			;;
	esac

	local contents=`echo $@`
	if $tostderr; then
		echo -e "$color""$contents""$FS_CUSTOMIZED_BASH_COLOR_CLEAR" >&2
	else
		echo -e "$color""$contents""$FS_CUSTOMIZED_BASH_COLOR_CLEAR"
	fi
}

Fs_Customized_Bash_log ${FS_CUSTOMIZED_BASH_MAGIC} ${FS_CUSTOMIZED_BASH_VERSION}

if [ -d "${FS_CUSTOMIZED_BASH_ROOT}/public" ]; then
	for FS_CUSTOMIZED_BASH_PUBLIC in `ls -1 "${FS_CUSTOMIZED_BASH_ROOT}/public" | sort`; do
		Fs_Customized_Bash_log Sourcing public file "${FS_CUSTOMIZED_BASH_PUBLIC}"
		. "${FS_CUSTOMIZED_BASH_ROOT}/public/${FS_CUSTOMIZED_BASH_PUBLIC}"
	done
	unset FS_CUSTOMIZED_BASH_PUBLIC
fi

if [ -d "${FS_CUSTOMIZED_BASH_ROOT}/private" ]; then
	for FS_CUSTOMIZED_BASH_PRIVATE in `ls -1 "${FS_CUSTOMIZED_BASH_ROOT}/private" | sort`; do
		Fs_Customized_Bash_log Sourcing private file "${FS_CUSTOMIZED_BASH_PRIVATE}"
		. "${FS_CUSTOMIZED_BASH_ROOT}/private/${FS_CUSTOMIZED_BASH_PRIVATE}"
	done
	unset FS_CUSTOMIZED_BASH_PRIVATE
fi

Fs_Customized_Bash_log ${FS_CUSTOMIZED_BASH_MAGIC} ${FS_CUSTOMIZED_BASH_VERSION} load complete'!'

unset Fs_Customized_Bash_log
unset FS_CUSTOMIZED_BASH_ROOT

return 0

