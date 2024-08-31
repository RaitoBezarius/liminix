{ config, lib, pkgs, ... }:
# Inspired from nixpkgs/NixOS.

with lib;

let
  inherit (pkgs.pseudofile) dir symlink;
  cfg = config.security.pki;

  cacertPackage = pkgs.cacert.override {
    blacklist = [ ];
    extraCertificateFiles = cfg.certificateFiles;
    extraCertificateStrings = cfg.certificates;
  };
  caBundleName = "ca-bundle.crt";
  caBundle = "${cacertPackage}/etc/ssl/certs/${caBundleName}";

in

{

  options = {
    security.pki.installCACerts = mkEnableOption "installing CA certificates to the system" // {
      default = false;
    };

    security.pki.certificateFiles = mkOption {
      type = types.listOf types.path;
      default = [];
      example = literalExpression ''[ "''${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt" ]'';
      description = ''
        A list of files containing trusted root certificates in PEM
        format. These are concatenated to form
        {file}`/etc/ssl/certs/ca-certificates.crt`, which is
        used by many programs that use OpenSSL, such as
        {command}`curl` and {command}`git`.
      '';
    };

    security.pki.certificates = mkOption {
      type = types.listOf types.str;
      default = [];
      example = literalExpression ''
        [ '''
            NixOS.org
            =========
            -----BEGIN CERTIFICATE-----
            MIIGUDCCBTigAwIBAgIDD8KWMA0GCSqGSIb3DQEBBQUAMIGMMQswCQYDVQQGEwJJ
            TDEWMBQGA1UEChMNU3RhcnRDb20gTHRkLjErMCkGA1UECxMiU2VjdXJlIERpZ2l0
            ...
            -----END CERTIFICATE-----
          '''
        ]
      '';
      description = ''
        A list of trusted root certificates in PEM format.
      '';
    };
  };

  config = mkIf cfg.installCACerts {
    # NixOS canonical location + Debian/Ubuntu/Arch/Gentoo compatibility.
    filesystem = dir {
      etc = dir {
        ssl = dir {
          certs = dir {
            "ca-certificates.crt" = symlink caBundle;
            "ca-bundle.crt" = symlink caBundle;
          };
        };

        # CentOS/Fedora compatibility.
        pki = dir {
          certs = dir {
            "ca-bundle.crt" = symlink caBundle;
          };
        };
      };
    };
  };

}

