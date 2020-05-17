# Created by Jacob Hrbek <kreyren@rixotstudio.cz> under AGPL-3 (https://www.gnu.org/licenses/agpl-3.0.en.html) in 2020

# Assertion wrapper
## This is a wrapper to terminate the program with a message and specified exit code, use `die 1 "hello"` to exit the program with message "FATAL: Hello" and exit code of "1"
die() {
	printf 'FATAL: %s\n' "$2"
	# NOTICE: Do not double-quote since we expect spaces
	# shellcheck disable=SC2154 # Sourced outside of this file
	[ -b "$masterUnset" ] && unset $masterUnset
	exit "$1"
}

# Wrapper used to inform the end-user about runtime
einfo() {
	printf 'INFO: %s\n' "$1"
}

# Wrapper used to inform about non-fatal errors
eerorr() {
	printf 'ERROR: %s\n' "$1"
}

# Wrapper to output annoying fixme messages for imperfect code
fixme() {
	[ -z "$IGNORE_FIXME" ] && printf 'FIXME: %s\n' "$1"
}


# Check for lsb_release
[ ! -x lsb_release ] && die 1 "Command 'lsb_release' is not executable on this system which is required to identify target system to configure package repositories"

# Strip unwanted string from lsb_release
distro="$(lsb_release -i)"
	distro="${distro##Distributor ID:	}"
distroCodename="$(lsb_release -c)"
	distroCodename="${release##Codename:	}"
release="$distro/$distroCodename"
unset distro distroCodename

# Wrapper used to download file in location based on resources available on the system
downloader() {
	downloaderUrl="$1"
	downloaderTarget="$2"

	# Shell compatibility - FUNCNAME
	# shellcheck disable=SC2039 # FUNCNAME is undefined is irelevant since we are overwriting it.
	# shellcheck disable=SC2128 # invalid since we are using this for bash compatibility on shell
	if [ -z "$FUNCNAME" ]; then
		MYFUNCNAME="downloader"
	elif [ -n "$FUNCNAME" ]; then
		MYFUNCNAME="${FUNCNAME[0]}"
	else
		die 255 "shellcompat - FUNCNAME"
	fi

	if [ -z "$downloaderUrl" ]; then
		die 2 "Function '$MYFUNCNAME' expects first argument with a hyperlink"
	elif [ -z "$downloaderTarget" ]; then
		die 2 "Function '$MYFUNCNAME' expects second argument pointing to a target to which we will export content of '$downloaderUrl'"
	elif [ -n "$downloaderUrl" ] && [ -n "$downloaderTarget" ]; then
		if [ ! -e "$downloaderTarget" ]; then
			case "$downloaderUrl" in
				http://*|https://*)
					if command -v wget >/dev/null; then
						fixme "If this is killed by the user it saves incomplete file which is unexpected"
						wget "$downloaderUrl" -O "$downloaderTarget" || die 1 "Unable to download '$downloaderUrl' in '$downloaderTarget' using wget"
					elif command -v curl >/dev/null; then
						curl -o "$downloaderTarget" "$downloaderUrl" || die 1 "Unable to download '$downloaderUrl' in '$downloaderTarget' using curl"
					else
						die 255 "Unable to download hyperlink '$downloaderUrl' in '$downloaderTarget', unsupported downloader?"
					fi ;;
				*) die 2 "hyperlink '$downloaderUrl' is not supported, fixme"
			esac
		elif [ -e "$downloaderTarget" ]; then
			debug "Pathname '$downloaderTarget' already exists, skipping download"
		else
			die 255 "downloader cheking for target '$downloaderTarget'"
		fi
	fi

	unset target url 	downloaderUrl downloaderTarget
}

# Used to make sure that library is sourced on runtime
sorucecheck() { return 0 ;}
