{ pkgs, lib, config, utils, inputs, ... }@args:

let
  LT = import ../../helpers args;
in
{
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
      "*.js".indent_size = 2;
      "*.json".indent_size = 2;
      "*.md".indent_size = 2;
      "*.nix".indent_size = 2;
    };
  };
}
