{ pkgs, lib, config, utils, inputs, ... }@args:

let
  lantian_nginx = pkgs.writeText "lantian_nginx.lua" ''
    local ffi       = require "ffi"
    local ltnginx   = ffi.load("${pkgs.lantianPersonal.libltnginx}/lib/libltnginx.so")

    ffi.cdef[[
      char* whois_ip_lookup(char* cidr);
      const char* whois_nic_handle_lookup(char* name);
      const char* whois_domain_lookup(char* name);
      const char* whois_asn_lookup(uint32_t asn);
    ]]

    local lantian_nginx = {}

    function lantian_nginx.whois_ip_lookup(target)
      local c_str = ffi.new("char[?]", #target)
      ffi.copy(c_str, target)
      return ffi.string(ltnginx.whois_ip_lookup(c_str))
    end

    function lantian_nginx.whois_nic_handle_lookup(target)
      local c_str = ffi.new("char[?]", #target)
      ffi.copy(c_str, target)
      return ffi.string(ltnginx.whois_nic_handle_lookup(c_str))
    end

    function lantian_nginx.whois_domain_lookup(target)
      local c_str = ffi.new("char[?]", #target)
      ffi.copy(c_str, target)
      return ffi.string(ltnginx.whois_domain_lookup(c_str))
    end

    function lantian_nginx.whois_asn_lookup(target)
      return ffi.string(ltnginx.whois_asn_lookup(tonumber(target)))
    end

    return lantian_nginx
  '';

  lantian_whois = pkgs.writeText "lantian_whois.lua" ''
    local bit       = require("bit")
    local ffi       = require "ffi"
    local ffi_cdef  = ffi.cdef
    local ffi_copy  = ffi.copy
    local ffi_new   = ffi.new
    local C         = ffi.C

    local AF_INET   = 2
    local AF_INET6  = 10

    ffi_cdef[[
      int inet_pton(int af, const char * restrict src, void * restrict dst);
      const char *inet_ntop(int af, const void *restrict src, char *restrict dst, uint32_t size);
      uint32_t ntohl(uint32_t netlong);
    ]]


    local lantian_whois = {}

    function lantian_whois.file_path(subdir, target)
      if target == nil then return nil end
      return "/" .. subdir .. "/" .. string.gsub(target, "/", "_")
    end

    function lantian_whois.file_exists(path)
      if path == nil then return false end
      local f = io.open(ngx.var.document_root .. path, "rb")
      if f == nil then return false end
      f:close()
      return true
    end

    function lantian_whois.file_read(path)
      if path == nil then return nil end
      local f = io.open(ngx.var.document_root .. path, "rb")
      if f == nil then return nil end
      local content = f:read("*all")
      f:close()
      return content
    end

    function lantian_whois.ipv4_parse(ip)
      local ip_bin = ffi_new("unsigned int [1]")
      if C.inet_pton(AF_INET, ip, ip_bin) ~= 1 then return nil end
      return C.ntohl(ip_bin[0])
    end

    function lantian_whois.ipv4_find(subdir, ip, mask)
      local b = lantian_whois.ipv4_parse(ip)
      mask = tonumber(mask)

      for i = mask, 1, -1 do
        local num = 0
        if i > 0 then num = bit.band(b, bit.lshift(4294967295, 32 - i)) end

        local new_ip = bit.band(bit.rshift(num, 24), 255) .. '.'
        new_ip = new_ip .. bit.band(bit.rshift(num, 16), 255) .. '.'
        new_ip = new_ip .. bit.band(bit.rshift(num, 8), 255) .. '.'
        new_ip = new_ip .. bit.band(bit.rshift(num, 0), 255)
        new_ip = new_ip .. '/' .. i

        local path = lantian_whois.file_path(subdir, new_ip)
        if lantian_whois.file_exists(path) then return path end
      end

      return nil
    end

    function lantian_whois.ipv6_parse(ip)
      local ip_bin = ffi_new("unsigned char [16]")
      if C.inet_pton(AF_INET6, ip, ip_bin) ~= 1 then return nil end
      return ip_bin
    end

    function lantian_whois.ipv6_recompose(ipbits)
      local ip = ffi_new("unsigned char [46]")
      if C.inet_ntop(AF_INET6, ipbits, ip, 46) == 0 then return nil end
      return ffi.string(ip)
    end

    function lantian_whois.ipv6_find(subdir, ip, mask)
      mask = tonumber(mask)
      local ipbits = lantian_whois.ipv6_parse(ip)
      for i = 128, 1, -1 do
        if i < 128 then
          local idx = math.floor(i / 8)
          ipbits[idx] = bit.band(ipbits[idx], bit.lshift(255, 8 - i % 8))
        end
        if i <= mask then
          local new_ip = lantian_whois.ipv6_recompose(ipbits) .. "/" .. i
          local path = lantian_whois.file_path(subdir, new_ip)
          if lantian_whois.file_exists(path) then return path end
        end
      end
      return nil
    end

    return lantian_whois
  '';
in
pkgs.stdenv.mkDerivation {
  pname = "nginx-lua";
  version = "1.0.0";
  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out
    ln -s ${lantian_nginx} $out/lantian_nginx.lua
    ln -s ${lantian_whois} $out/lantian_whois.lua
  '';
}
