#!/bin/sh
# Created by minds developers under AGPL-3 (https://www.gnu.org/licenses/agpl-3.0.en.html) license sometime around 2018
# Refactored by Jacob Hrbek <kreyren@rixotstudio.cz> under AGPL-3 (https://www.gnu.org/licenses/agpl-3.0.en.html) license in 2020

: "
  This file configures and runs elasticsearch plugin for minds

	FIXME-DOCS: init
"

# Change this in case you need to use a different version
elacticVersion="1.7.2"

# Master unset - Used to unset variables after runtime
masterUnset="release commonPath elacticVersion"

# Source common-shell
commonPath="src/common-shell"
[ ! -f "$commonPath" ] && { printf 'FATAL: %s\n' "Unable to find '$commonPath' from current directory" ; exit 1 ;}
. "$commonPath"
sourcecheck || die 1 "Unable to source common-code in '$commonPath'"

# Make sure that chachedir is available
if [ ! -d "$HOME/.cache" ]; then
	mkdir "$HOME/.cache" || die 1 "Unable to create cachedir in '$HOME/.cachedir'"
elif [ -d "$HOME/.cache" ]; then
	true
else
	die 256 "Unexpected happend while checking for cachedir"
fi

# Cache the source
[ ! -d "$HOME/.cache/minds" ] && { mkdir "$HOME/.cache/minds" || die 1 "Unable to make a new directory in '$HOME/.cache/minds'" ;}

downloader "https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-$eclasticVersion.tar.gz" "$HOME/.cache/minds/$eclasticVersion.tar.gz"

# Extract
# FIXME: Sanitization required for targetDir
[ ! -e "$(pwd)/bin/elasticsearch" ] && { tar xpf "$HOME/.cache/minds/$eclasticVersion.tar.gz" || die 1 "Unable to extract '$HOME/.cache/minds/$eclasticVersion.tar.gz'" ;}

# Configure
# FIXME-QA: Optimize the regex to make sure it does not trigger on unwanted string
if ! grep -qF "network.bind_host: 127.0.0.1" elasticsearch/config/elasticsearch.yml; then printf '%s\n' "network.bind_host: 127.0.0.1" >> elasticsearch/config/elasticsearch.yml; fi

# FIXME-QA: Why?
"elacticsearch-$eclasticVersion/bin/elasticsearch" -d || die 1 "Unable to run elasticsearch -d"

# Exec
if command -v php >/dev/null; then php /var/www/Minds/misc/plugins.php || die 1 "Unable to run '/var/www/Minds/misc/plugins.php'"; fi

# NOTICE: Do not double-quote
unset $masterUnset
