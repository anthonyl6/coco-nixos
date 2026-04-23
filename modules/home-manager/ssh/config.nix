{ username, ... }:
{
  home.file.".ssh/config" = {
    text = ''
      Host github.com
        HostName github.com
        User git
        IdentityFile ~/.ssh/id_ed25519_${username}
    '';
    force = true;
  };
}
