# jellyfin-dvr-comskip

This is a script that is called after a video is recorded in Jellyfin Live TV. It attempts to mark or remove the commercials using Comcut & Comskip and then converts the video using Jellyfin ffmpeg.

The script also attempts to extract closed captions as SRT subtitles.

You can find where to put this script by going to the Server Dashboard in the Jellyfin web interface, then DVR under Live TV, then "Post-processing application:" field.

ComChap - A script that marks commericals as chapters that can be skipped.<br>
ComCut - A script that removes marked commericals.

If you have updates for this script please submit a PR so everyone can benefit.

You will need to have Comskip already installed from here:
https://github.com/erikkaashoek/Comskip
