#!/usr/bin/env bash

# Valid video files to scan for.
export MUX_EXT=(flv avi mkv 3gp ogv m4v f4v mov mpeg mpg ts m2ts vob mp4)
# Video output container.
export MUX_TO="mp4"
# Video finder string
export MUX_FIND_STR="$(printf " -or -iname '*.%s'" ${MUX_EXT[@]})"
export MUX_FIND="find . -type f ! -iname '.*'"
# Find command string
export MUX_FIND="$MUX_FIND ${MUX_FIND_STR:4}"

# Colorize things
echo_bold_red="\033[31;1m"
echo_bold_blue="\033[34;1m"
echo_bold_cyan="\033[36;1m"
echo_bold_yellow="\033[33;1m"
echo_bold_green="\033[32;1m"
echo_underline_yellow="\033[33;4m"
echo_underline_white="\033[37;4m"
echo_reset_color="\033[39m"
echo_normal="\033[0m"


function muxvideo_usage() {
  echo
  echo -e " ${echo_bold_blue}Bash FFMPEG Batcher Usage${echo_reset_color}${echo_normal}"
  echo
  echo -e " A simple bash script for batch muxing a directory of video files "
  echo -e " of various formats to a single output format such as MP4."
  echo
  echo -e " The destination container must support the audio and video formats"
  echo -e " or FFMPEG will fail."
  echo
  echo -e " By default the first audio and video tracks are demuxed from the"
  echo -e " originating container and remuxed into the destination container."
  echo
  echo -e " ${echo_bold_yellow}${echo_underline_yellow}Args${echo_reset_color}${echo_normal}:"
  echo -e "  -h  Help"
  echo -e "  -a  Audio track(s); Accepts a 0-based track index number or"
  echo -e "      specific range from 0-N in the form of 0:a:N"
  echo -e "  -v  Video track(s); accepts a 0-based track index number or"
  echo -e "      specific range from 0-N in the form of 0:v:N"
  echo -e "  -l  Log the output to a file."
  echo -e "  -c  Log the output to the console."
  echo
  echo -e " ${echo_underline_white}Note${echo_normal}: Copying subtitles is not supported at this time."
  echo
  echo -e " ${echo_bold_yellow}${echo_underline_yellow}Usage:${echo_reset_color}${echo_normal}"
  echo -e "  # Copies All audio and video tracks logs output to a file and to the console."
  echo -e "  muxvideos -a 0:a -v 0:v -lc"
  echo -e "  # Copies the third audio track and first video track"
  echo -e "  muxvideos -a 2 -v 0"
  echo -e "  # Copies the second audio track and first video track"
  echo -e "  muxvideos -a 1"
  echo -e "  # Copies the first audio and video tracks."
  echo -e "  muxvideos"
  echo
}

function muxvideos() {
  command -v ffmpeg >/dev/null 2>&1 || { echo -e "${echo_bold_red}FFMPEG is required. Aborting.${echo_reset_color}" >&2; return; }
  OPTIND=1 # Reset
  mux_logall=""
  mux_console=""
  mux_audio="0:a:0"
  mux_video="0:v:0"

  while getopts "ha:v:lc" opt; do
  case "$opt" in
    h)
      muxvideos_usage
      return
      ;;
    a)
      # Audio track number(s)
      mux_audio=${OPTARG}
      if [[ "${mux_audio}" =~ ^[0-9]+$ ]]; then
        mux_audio="0:a:${mux_audio}"
      fi
      ;;
    v)
      # Video track number(s)
      mux_video=${OPTARG}
      if [[ "${mux_video}" =~ ^[0-9]+$ ]]; then
        mux_video="0:v:${mux_video}"
      fi
      ;;
    l)
      # Log console output to a file
      mux_logall="-l"
      ;;
    c)
      # Show console output
      mux_console="-c"
      ;;
  esac
  done
  shift $((OPTIND-1))
  echo -e "\n${echo_bold_blue}Starting Video Conversion: ${echo_reset_color}\n"

  eval "${MUX_FIND}" | while read mux_file ;
  do
    # Check for invalid characters
    if [[ $mux_file != ${mux_file//[ \%\']/ } ]]; then
      echo -e "  ${echo_bold_red}Error - Filename or path contains invalid character(s)${echo_reset_color}"
      echo -e "  ${mux_file}"
      continue
    fi
    eval "$(printf "muxvideo -a ${mux_audio} -v  ${mux_video} ${mux_console} ${mux_logall} '${mux_file}'")"
  done
  echo -e "\n${echo_bold_green}Video Conversion Finished! ${echo_reset_color}\n"
}

function muxvideo() {
  command -v ffmpeg >/dev/null 2>&1 || { echo -e "${echo_bold_red}FFMPEG is required. Aborting.${echo_reset_color}" >&2; return; }
  FFREPORT=""
  OPTIND=1 # Reset
  mux_log=0
  mux_verbose="-loglevel panic"
  mux_report=""
  mux_audio="0:a:0"
  mux_video="0:v:0"

  while getopts "ha:v:lc" opt; do
  case "$opt" in
    h)
      muxvideo_usage
      return
      ;;
    a)
      # Audio track number(s)
      mux_audio=${OPTARG}
      if [[ "${mux_audio}" =~ ^[0-9]+$ ]]; then
        mux_audio="0:a:${mux_audio}"
      fi
      ;;
    v)
      # Video track number(s)
      mux_video=${OPTARG}
      if [[ "${mux_video}" =~ ^[0-9]+$ ]]; then
        mux_video="0:v:${mux_video}"
      fi
      ;;
    l)
      # Log ffmpeg results to a file.
      mux_log=1
      mux_report="-report"
      ;;
    c)
      # Show console output
      mux_verbose=""
      ;;
    esac
  done
  shift $((OPTIND-1))

  if [[ -z "$@" ]]; then
    echo -e "  ${echo_bold_red}Error - File path not provided${echo_reset_color}"
    return
  fi

  # Get the file path, name, & extension
  mux_filepath=$@

  # Validate that the file exists.
  if [ -z "$mux_filepath" ]; then
    echo -e "  ${echo_bold_red}Error - File does not exist${echo_reset_color}"
    return
  fi

  mux_filename="${mux_filepath%.*}"
  mux_extension="${mux_filepath##*.}"

  # Check for invalid characters
  if [[ $mux_filename != ${mux_filename//[ \%\']/ } ]]; then
    echo -e "  ${echo_bold_red}Error - Filename or path contains invalid character(s)${echo_reset_color}"
    echo -e "  $@"
    return
  fi

  # Track validation. Make sure tracks are in the form of 0:a:1 and 0:v:1
  if ! [[ "${mux_video}" =~ ^[0-9:v]+$ ]] || ! [[ "${mux_audio}" =~ ^[0-9:a]+$ ]]; then
    echo -e "  ${echo_bold_red}Error - Invalid audio or video track(s)${echo_reset_color}"
    return
  fi

  # Check that extensions are different.
  if [ "$mux_extension" == "$MUX_TO" ]; then
    return
  fi

  # If the video format we are converting to already exits, on to the next.
  if [ -f "${PWD}/${mux_filename}.${MUX_TO}" ]; then
    return
  fi

  if [[ "${mux_log}" -eq 1 ]]; then
    FFREPORT=file=./${filename}-$(date +%h.%m.%s).log
  fi
  echo -e "  ${echo_bold_cyan}.${mux_filename}.${mux_extension} ${echo_reset_color}==>${echo_bold_cyan} ${mux_filename}.${MUX_TO}${echo_reset_color}"
  ffmpeg -i "${mux_filename}.${mux_extension}" -acodec copy -vcodec copy -map ${mux_video} -map ${mux_audio} "${mux_filename}.${MUX_TO}" -nostdin ${mux_report} ${mux_verbose}
}
