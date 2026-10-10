_: {
  # RequiresMountsFor 按词去除引号，不解码 C 转义，不能使用 JSON/Exec 转义。
  escapeMountPath =
    path:
    let
      s = toString path;
    in
    assert builtins.replaceStrings [ "\n" "\r" ] [ "" "" ] s == s;
    "\"${builtins.replaceStrings [ "\\" "\"" "%" ] [ "\\\\" "\\\"" "%%" ] s}\"";
}
