{
  xdg.configFile."fontconfig/conf.d/99-lantian.conf".text = ''
    <?xml version="1.0"?>
    <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
    <fontconfig>
      <its:rules xmlns:its="http://www.w3.org/2005/11/its" version="1.0">
        <its:translateRule
          translate="no"
          selector="/fontconfig/*[not(self::description)]"
        />
      </its:rules>

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
          <string>Source Han Serif SC</string>
        </edit>
      </match>
      <match target="pattern">
        <test qual="any" name="family">
          <string>sans-serif</string>
        </test>
        <edit name="family" mode="prepend" binding="strong">
          <string>Ubuntu</string>
          <string>Source Han Sans SC</string>
        </edit>
      </match>
      <match target="pattern">
        <test qual="any" name="family">
          <string>monospace</string>
        </test>
        <edit name="family" mode="prepend" binding="strong">
          <string>Ubuntu Mono</string>
          <string>Noto Sans Mono CJK SC</string>
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
    </fontconfig>
  '';
}
