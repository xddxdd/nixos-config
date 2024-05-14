_: {
  editorconfig = {
    enable = true;
    settings = {
      "*" = {
        charset = "utf-8";
        end_of_line = "lf";
        indent_size = 4;
        indent_style = "space";
        insert_final_newline = true;
        max_line_length = "off";
        trim_trailing_whitespace = true;
      };
      "*.astro".indent_size = 2;
      "*.js".indent_size = 2;
      "*.jsx".indent_size = 2;
      "*.json".indent_size = 2;
      "*.md".indent_size = 2;
      "*.mdx".indent_size = 2;
      "*.nix".indent_size = 2;
      "*.tf".indent_size = 2;
    };
  };
}
