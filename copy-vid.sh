#!/usr/bin/env bash

# unmute a device?
# v4l2-ctl -d /dev/video0 --set-ctrl mute=0

vid_device="/dev/video0"
aud_device="hw:2,0"

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
  ! filesink location=vhs.mkv

# gst-launch-1.0 -q v4l2src device="$vid_device" do-timestamp=true norm="PAL" pixel-aspect-ratio=1 \
#   ! video/x-raw,format=YUY2,framerate=25/1,width=720,height=576 \
#   ! queue max-size-buffers=0 max-size-time=0 max-size-bytes=0 \
#   ! mux. \
#     alsasrc device="$aud_device" do-timestamp=true \
#   ! audio/x-raw,format=S16LE,rate=48000,channels=2 \
#   ! queue \
#     max-size-buffers=0 max-size-time=0 max-size-bytes=0 \
#   ! mux. matroskamux name=mux \
#   ! queue max-size-buffers=0 max-size-time=0 max-size-bytes=0 \
#   ! filesink location=vhs.mkv
