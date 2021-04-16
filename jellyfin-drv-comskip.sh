#!/usr/bin/env bash

#
# This is for Jellyfin docker. 
# The comskip.ini file used is stored in /config for easy access, editing and to survive upgrades.
#

set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace

# Set ffmpeg path to Jellyfin ffmpeg
__ffmpeg="$(which ffmpeg || echo '/usr/lib/jellyfin-ffmpeg/ffmpeg')"

# Set video codec for ffmpeg
__videocodec="libvpx-vp9"

# Set audio codec for ffmpeg
__audiocodec="libopus"

# Set bitrate for audio codec for ffmpeg
__bitrate="128000"

# Set video container
___container="mkv"

# Set CRF
__crf="20"

# Set Preset
__preset="slow"

# Green Color
GREEN='\033[0;32m'

# No Color
NC='\033[0m'

# Path
__path="${1:-}"


PWD="$(pwd)"

die () {
	echo >&2 "$@"
	cd "${PWD}"
	exit 1
}

# verify a path was provided
[ -n "$__path" ] || die "path is required"
# verify the path exists
[ -f "$__path" ] || die "path ($__path) is not a file"

__dir="$(dirname "${__path}")"
__file="$(basename "${__path}")"
__base="$(basename "${__path}" ".ts")"

# Debbuging path variables
# printf "${GREEN}path:${NC} ${__path}\ndir: ${__dir}\nbase: ${__base}\n"

# Change to the directory containing the recording
cd "${__dir}"

# Extract closed captions to external SRT file
printf "[post-process.sh] %bExtracting subtitles...%b\n" "$GREEN" "$NC"
$__ffmpeg -f lavfi -i movie="${__file}[out+subcc]" -map 0:1 "${__base}.srt"

#comcut/comskip - currently using jellyfin ffmpeg in docker
/usr/local/bin/comcut --ffmpeg=$__ffmpeg --comskip=/usr/local/bin/comskip --lockfile=/tmp/comchap.lock --comskip-ini=/config/comskip.ini "${__file}"


# Transcode to mkv, crf parameter can be adjusted to change output quality
printf "[post-process.sh] %bTranscoding file..%b\n" "$GREEN" "$NC"
$__ffmpeg -i "${__file}" -acodec "${__audiocodec}" -b:a "${__bitrate}" -vcodec "${__videocodec}" -vf yadif=parity=auto -crf "${__crf}" -preset "$__preset}" "${__base}.${__container}"

# Remove the original recording file
printf "[post-process.sh] %bRemoving originial file...%b\n" "$GREEN" "$NC"
rm "${__file}"

# Return to the starting directory
cd "${PWD}"
