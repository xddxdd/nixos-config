{ lib, ... }:
let
  preferenceOrder = [
    {
      name = "org.kde.dolphin.desktop";
      mimeTypes = "inode/directory";
    }
    {
      name = "org.kde.gwenview.desktop";
      mimeTypes = "inode/directory;image/avif;image/gif;image/heif;image/jpeg;image/jxl;image/png;image/bmp;image/x-eps;image/x-icns;image/x-ico;image/x-portable-bitmap;image/x-portable-graymap;image/x-portable-pixmap;image/x-xbitmap;image/x-xpixmap;image/tiff;image/x-psd;image/x-webp;image/webp;image/x-tga;image/x-xcf;application/x-krita";
    }
    {
      name = "audacious.desktop";
      mimeTypes = "application/ogg;application/x-cue;application/x-ogg;application/xspf+xml;audio/aac;audio/flac;audio/midi;audio/mp3;audio/mp4;audio/mpeg;audio/mpegurl;audio/ogg;audio/prs.sid;audio/wav;audio/x-flac;audio/x-it;audio/x-mod;audio/x-mp3;audio/x-mpeg;audio/x-mpegurl;audio/x-ms-asx;audio/x-ms-wma;audio/x-musepack;audio/x-s3m;audio/x-scpls;audio/x-stm;audio/x-vorbis+ogg;audio/x-wav;audio/x-wavpack;audio/x-xm;x-content/audio-cdda";
    }
    {
      name = "mpv.desktop";
      mimeTypes =
        "application/ogg;application/x-ogg;application/mxf;application/sdp;application/smil;application/x-smil;application/streamingmedia;application/x-streamingmedia;application/vnd.rn-realmedia;application/vnd.rn-realmedia-vbr;audio/aac;audio/x-aac;audio/vnd.dolby.heaac.1;audio/vnd.dolby.heaac.2;audio/aiff;audio/x-aiff;audio/m4a;audio/x-m4a;application/x-extension-m4a;audio/mp1;audio/x-mp1;audio/mp2;audio/x-mp2;audio/mp3;audio/x-mp3;audio/mpeg;audio/mpeg2;audio/mpeg3;audio/mpegurl;audio/x-mpegurl;audio/mpg;audio/x-mpg;audio/rn-mpeg;audio/musepack;audio/x-musepack;audio/ogg;audio/scpls;audio/x-scpls;audio/vnd.rn-realaudio;audio/wav;audio/x-pn-wav;audio/x-pn-windows-pcm;audio/x-realaudio;audio/x-pn-realaudio;audio/x-ms-wma;audio/x-pls;audio/x-wav;video/mpeg;video/x-mpeg2;video/x-mpeg3;video/mp4v-es;video/x-m4v;video/mp4;application/x-extension-mp4;video/divx;video/vnd.divx;video/msvideo;video/x-msvideo;video/ogg;video/quicktime;video/vnd.rn-realvideo;video/x-ms-afs;video/x-ms-asf;audio/x-ms-asf;application/vnd.ms-asf;video/x-ms-wmv;video/x-ms-wmx;video/x-ms-wvxvideo;video/x-avi;video/avi;video/x-flic;video/fli;video/x-flc;video/flv;video/x-flv;video/x-theora;video/x-theora+ogg;video/x-matroska;video/mkv;audio/x-matroska;application/x-matroska;video/webm;audio/webm;audio/vorbis;audio/x-vorbis;audio/x-vorbis+ogg;video/x-ogm;video/x-ogm+ogg;application/x-ogm;application/x-ogm-audio;application/x-ogm-video;application/x-shorten;audio/x-shorten;audio/x-ape;audio/x-wavpack;audio/x-tta;audio/AMR;audio/ac3;audio/eac3;audio/amr-wb;video/mp2t;audio/flac;audio/mp4;application/x-mpegurl;video/vnd.mpegurl;application/vnd.apple.mpegurl;audio/x-pn-au;video/3gp;video/3gpp;video/3gpp2;audio/3gpp;audio/3gpp2;video/dv;audio/dv;audio/opus;audio/vnd.dts;audio/vnd.dts.hd;audio/x-adpcm;application/x-cue;audio/m3u;audio/vnd.wave;video/vnd.avi"
        # Custom additions
        + ";video/x-ts";
    }
    {
      name = "firefox.desktop";
      mimeTypes =
        "text/html;text/xml;application/xhtml+xml;application/vnd.mozilla.xul+xml;x-scheme-handler/http;x-scheme-handler/https"
        # Use Firefox for PDF as well
        + ";application/pdf";
    }
    {
      name = "wps-office-wps.desktop";
      mimeTypes = "application/wps-office.wps;application/wps-office.wpt;application/wps-office.wpso;application/wps-office.wpss;application/wps-office.doc;application/wps-office.dot;application/vnd.ms-word;application/msword;application/x-msword;application/msword-template;application/wps-office.docx;application/wps-office.dotx;application/rtf;application/vnd.ms-word.document.macroEnabled.12;application/vnd.openxmlformats-officedocument.wordprocessingml.document;x-scheme-handler/ksoqing;x-scheme-handler/ksowps;x-scheme-handler/ksowpp;x-scheme-handler/ksoet;x-scheme-handler/ksowpscloudsvr;x-scheme-handler/ksowebstartupwps;x-scheme-handler/ksowebstartupet;x-scheme-handler/ksowebstartupwpp;application/wps-office.uot";
    }
    {
      name = "wps-office-et.desktop";
      mimeTypes = "application/wps-office.et;application/wps-office.ett;application/wps-office.ets;application/wps-office.eto;application/wps-office.xls;application/wps-office.xlt;application/vnd.ms-excel;application/msexcel;application/x-msexcel;application/wps-office.xlsx;application/wps-office.xltx;application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;application/wps-office.uos";
    }
    {
      name = "wps-office-wpp.desktop";
      mimeTypes = "application/wps-office.dps;application/wps-office.dpt;application/wps-office.dpss;application/wps-office.dpso;application/wps-office.ppt;application/wps-office.pot;application/vnd.ms-powerpoint;application/vnd.mspowerpoint;application/mspowerpoint;application/powerpoint;application/x-mspowerpoint;application/wps-office.pptx;application/wps-office.potx;application/vnd.openxmlformats-officedocument.presentationml.presentation;application/vnd.openxmlformats-officedocument.presentationml.slideshow;application/wps-office.uop";
    }
    {
      name = "linphone.desktop";
      mimeTypes = "x-scheme-handler/sip-linphone;x-scheme-handler/sip;x-scheme-handler/sips-linphone;x-scheme-handler/sips;x-scheme-handler/tel;x-scheme-handler/callto;x-scheme-handler/linphone-config";
    }
    {
      name = "wine.desktop";
      mimeTypes = "application/x-ms-dos-executable;application/x-msi;application/x-ms-shortcut;application/x-bat;application/x-mswinurl";
    }
  ];
in
{
  xdg.configFile."mimeapps.list".force = true;

  xdg.mimeApps = {
    enable = true;
    defaultApplications =
      let
        mergePreference =
          a: b:
          let
            bTypes = builtins.filter (v: v != "") (lib.splitString ";" b.mimeTypes);
            bAttrs = lib.genAttrs bTypes (_: [ b.name ]);
            allAttrs = a // bAttrs;
          in
          lib.mapAttrs (
            mime: _:
            let
              existingList = if builtins.hasAttr mime a then a.${mime} else [ ];
              newList = if builtins.hasAttr mime bAttrs then bAttrs.${mime} else [ ];
            in
            existingList ++ newList
          ) allAttrs;

        result = builtins.foldl' mergePreference { } preferenceOrder;
      in
      result;
  };
}
