# VCR Copy

A script intended to make it a little easier to capture a video and audio stream from
a USB capture device.

## Capture Device Options

The video capture card I'm using a Roxio Video Capture USB, UB315-E ver3. It has the RCA
connections as well as an S-Video connection. I needed to use `v4l2-ctl` to choose the input
device that the capture card could use; in my case 0 was the composite video, and 1 was the
S-Video. So, capturing from a camcorder that connected via S-Video would require:

```bash
v4l2-ctl --set-input 1
```

## Resources

 - https://www.linux-magazine.com/Issues/2019/219/File-Conversion
 - https://medium.com/@bionazgul/the-adventures-of-converting-vhs-tapes-to-mp4-using-easycap-and-ffmpeg-to-create-a-christmas-f12364bfefe1

## Problems

The created MKV file does not seem to have any time information in it. It plays OK,
but there is no progress bar. There also seem to be problems loading it in to the couple
video editing programs I've tried. They either hang, or complain about un-readable
attributes or some such. I've ended up running the output files through Handbrake
to both reduce the size, and make them readable.
