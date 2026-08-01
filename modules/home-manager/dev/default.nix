{
  username,
  fullName,
  email,
  pkgs-stable,
  ...
}:

let
  # ← PASTE YOUR ACTUAL FULL PUBKEY HERE (one line)
  myPubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJuRaAYUVatZWTRlp6wDlRtJoC40FHeFPKvumBcViCVg";

  allowedSignersFile = pkgs-stable.writeText "git-allowed-signers" ''
    ${email} namespaces="git" ${myPubKey}
  '';
in
{
  imports = [
    ./crush.nix
  ];

  home.packages = with pkgs-stable; [
    android-tools
    nixfmt
    gcc
    gnumake
    cargo
    nodejs
    bun
    jdk
    minio-client
  ];

  programs.git = {
    enable = true;
    lfs.enable = true;
    settings = {
      user = {
        name = fullName;
        email = email;
      };
      gpg = {
        format = "ssh";
        ssh.allowedSignersFile = "~/.config/git/allowed_signers";
      };
      tag.gpgsign = true;
      core.autocrlf = "input";
    };

    signing = {
      key = "~/.ssh/id_ed25519_${username}.pub";
      signByDefault = true;
      format = null;
    };
  };

  # This symlinks the generated file from the store → ~/.config/git/allowed_signers
  xdg.configFile."git/allowed_signers".source = allowedSignersFile;

  programs.direnv.enable = true;
}
