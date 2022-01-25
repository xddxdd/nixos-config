{
  xdg.configFile."fontconfig/fonts.conf".text = ''
    <?xml version="1.0"?>
    <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
    <fontconfig>
      <its:rules xmlns:its="http://www.w3.org/2005/11/its" version="1.0">
        <its:translateRule
          translate="no"
          selector="/fontconfig/*[not(self::description)]"
        />
      </its:rules>

      <description>Android Font Config</description>

      <!-- Font directory list -->
      <dir>/usr/share/fonts</dir>
      <dir>/usr/local/share/fonts</dir>
      <dir prefix="xdg">fonts</dir>

      <!-- 关闭内嵌点阵字体 -->
      <match target="font">
        <edit name="embeddedbitmap" mode="assign">
          <bool>false</bool>
        </edit>
      </match>

      <!-- 英文默认字体 -->
      <match>
        <test qual="any" name="family">
          <string>serif</string>
        </test>
        <edit name="family" mode="prepend" binding="strong">
          <string>Noto Serif</string>
        </edit>
      </match>
      <match target="pattern">
        <test qual="any" name="family">
          <string>sans-serif</string>
        </test>
        <edit name="family" mode="prepend" binding="strong">
          <string>Ubuntu</string>
        </edit>
      </match>
      <match target="pattern">
        <test qual="any" name="family">
          <string>monospace</string>
        </test>
        <edit name="family" mode="prepend" binding="strong">
          <string>Ubuntu Mono</string>
        </edit>
      </match>

      <!-- Emoji -->
      <match target="pattern">
        <test qual="any" name="family">
          <string>emoji</string>
        </test>
        <edit name="family" mode="prepend" binding="strong">
          <string>Blobmoji</string>
        </edit>
      </match>

      <!-- 中文默认字体使用思源黑体和思源宋体,不使用 Noto Sans CJK SC 是因为这个字体会在特定情况下显示片假字. -->
      <match>
        <test name="lang" compare="contains">
          <string>zh</string>
        </test>
        <test name="family">
          <string>serif</string>
        </test>
        <edit name="family" mode="prepend">
          <string>Source Han Serif SC</string>
        </edit>
      </match>
      <match>
        <test name="lang" compare="contains">
          <string>zh</string>
        </test>
        <test name="family">
          <string>sans-serif</string>
        </test>
        <edit name="family" mode="prepend">
          <string>Source Han Sans SC</string>
        </edit>
      </match>
      <match>
        <test name="lang" compare="contains">
          <string>zh</string>
        </test>
        <test name="family">
          <string>monospace</string>
        </test>
        <edit name="family" mode="prepend">
          <string>Noto Sans Mono CJK SC</string>
        </edit>
      </match>

      <!-- Windows & Linux Chinese fonts. -->
      <!--
        把所有常见的中文字体映射到思源黑体和思源宋体，这样当这些字体未安装时会使用思源黑体和思源宋体.
        解决特定程序指定使用某字体，并且在字体不存在情况下不会使用fallback字体导致中文显示不正常的情况.
      -->
      <match target="pattern">
        <test qual="any" name="family">
          <string>Microsoft YaHei</string>
        </test>
        <edit name="family" mode="assign" binding="same">
          <string>Source Han Sans SC</string>
        </edit>
      </match>
      <match target="pattern">
        <test qual="any" name="family">
          <string>SimHei</string>
        </test>
        <edit name="family" mode="assign" binding="same">
          <string>Source Han Sans SC</string>
        </edit>
      </match>
      <match target="pattern">
        <test qual="any" name="family">
          <string>SimSun</string>
        </test>
        <edit name="family" mode="assign" binding="same">
          <string>Source Han Serif SC</string>
        </edit>
      </match>
      <match target="pattern">
        <test qual="any" name="family">
          <string>SimSun-18030</string>
        </test>
        <edit name="family" mode="assign" binding="same">
          <string>Source Han Serif SC</string>
        </edit>
      </match>

      <!-- Load local system customization file -->
      <include ignore_missing="yes">conf.d</include>

      <!-- Font cache directory list -->
      <cachedir>/var/cache/fontconfig</cachedir>
      <cachedir prefix="xdg">fontconfig</cachedir>

      <config>
        <!-- Rescan configuration every 30 seconds when FcFontSetList is called -->
        <rescan>
          <int>30</int>
        </rescan>
      </config>
    </fontconfig>
  '';
}
