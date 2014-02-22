bash-ffmpeg-batcher
===================

A simple bash script for batch muxing a directory of video files
of various formats to a single output format such as MP4.

Works great for converting .avi, mkv, .ts, .m2ts, .vob (to name a few) to MP4.

The primary purpose for creating this script was to convert all of my video
files to a single industry standard container, MP4. Instead of hand-coding
a command to convert every single video file, I created this script to automate
this process.

Although MP4 is the default output container, if you prefer to use another container,
change the $MUX_TO variable to the extension of your choice. I have not thoroughly
tested this script with other containers, so do so at your own risk. And be aware
of what types of audio and video are supported for that container. Unsupported
audio or video tracks will lead to errors.

NOTE:

I recently added an option to transcode WMV files since these files aren't mux
friendly.


Usage
-----
    source ffmpeg-batcher.sh
    cd /path/to/videos/dir/
    muxvideos

    # For additional usage commands
    muxvideos -h

Other Considerations
--------------------
- This script recurrsively finds videos within a directory. So it might not be a good
  idea to mux from / or other base directory where you might not want to convert videos.
- FFMPEG is picky about filenames with special characters. Mainly files with
  single quotes in the filename or path.
- Although the MP4 spec declares support for TrueHD and LPCM/PCM, FFMPEG does
  not support encoding of these audio formats into the MP4 container at this time.
