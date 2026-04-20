{ pkgs, ... }:
{
  environment.systemPackages = [
    (pkgs.llama-cpp.override { cudaSupport = true; })
  ];

  lantian.preservation.directories = [ "/root/.cache/huggingface" ];
}
