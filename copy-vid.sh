#!/usr/bin/env bash

print_help () {
  echo "A script to start GStreamer to stream from a USB video device and output"
  echo "to a MKV file and stop after a specified period of time. Intended for"
  echo "use with a VCR or similar."
  echo "Example:"
  echo "./copy-vid.sh [--duration=120m] [--outpath=/home/user/video] [--outfile=trash_panda] [--videodevice=/dev/video0] [--audiodevice=\"hw:2,0\"]"
  echo "Options:"
  echo " -d | --duration: The duration to let the stream run in 'timeout' command format; default 125 minutes"
  echo " -p | --outpath: The folder to place the output file; default is script directory"
  echo " -o | --outfile: The name of the output file; default is 'vhs_copy'"
  echo " -v | --videodevice: The video device to stream from; default is '/dev/video0'"
  echo " -i | --inputdevice: The input of the video to read; deafult is 'composite' other option is 'svideo'"
  echo " -a | --audiodevice: The audio device to stream from; default is 'hw:2,0'"
  echo " -h | --help: Print this message and exit"
  exit 1
}

get_timestamp () {
  date --iso-8601=seconds
}

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

duration="125m"
outpath="${script_dir}"
file_ext=".mkv"
file_name="vhs_copy"
vid_device="/dev/video0"
aud_device="hw:2,0"
inp_device="composite"

for arg in "$@"; do
  case $arg in
    -d=*|--duration=*)
    duration="${arg#*=}"
    shift
    ;;
    -p=*|--outpath=*)
    outpath="${arg#*=}"
    shift
    ;;
    -o=*|--outfile=*)
    file_name="${arg#*=}"
    shift
    ;;
    -v=*|--videodevice=*)
    vid_device="${arg#*=}"
    shift
    ;;
    -a=*|--audiodevice=*)
    aud_device="${arg#*=}"
    shift
    ;;
    -i=*|--inputdevice=*)
    inp_device="${arg#*=}"
    shift
    ;;
    -h|--help)
    print_help
    ;;
    *)
    echo "Unrecognized option: ${arg}"
    print_help
    ;;
  esac
done

output_file="${outpath}/${file_name}${file_ext}"

if [ "$inp_device" = "composite" ]; then
  v4l2-ctl --set-input 0
elif [ "$inp_device" = "svideo" ]; then
  v4l2-ctl --set-input 1
else
  echo "Unrecognized input device: ${inp_device}"
  print_help
fi

# Unmute the device; may not always be necessary, but this seems to work...
v4l2-ctl -d /dev/video0 --set-ctrl mute=0

echo "$(get_timestamp) - Starting stream to file: ${output_file}"
timeout --preserve-status --signal=SIGTERM $duration \
  gst-launch-1.0 -q v4l2src device="$vid_device" do-timestamp=true norm="NTSC" pixel-aspect-ratio=1 \
    ! video/x-raw,format=YUY2,framerate=30/1,width=720,height=480 \
    ! queue max-size-buffers=0 max-size-time=0 max-size-bytes=0 \
    ! mux. \
      alsasrc device="$aud_device" do-timestamp=true \
    ! audio/x-raw,format=S16LE,rate=48000,channels=2 \
    ! queue \
      max-size-buffers=0 max-size-time=0 max-size-bytes=0 \
    ! mux. matroskamux name=mux \
    ! queue max-size-buffers=0 max-size-time=0 max-size-bytes=0 \
    ! filesink location="$output_file"
echo "$(get_timestamp) - Completed stream to file: ${output_file}"
