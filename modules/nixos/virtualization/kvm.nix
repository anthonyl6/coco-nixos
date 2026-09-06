{
  pkgs-fresh,
  username,
  ...
}: {
  # Load KVM modules dynamically
  boot.kernelModules = [
    "kvm"
    "kvm-amd"
  ];

  # Virtualization stack
  virtualisation.libvirtd = {
    enable = true;

    qemu = {
      package = pkgs-fresh.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
    };
  };

  # Enable virt-manager GUI
  programs.virt-manager.enable = true;

  virtualisation.spiceUSBRedirection.enable = true;

  users.users.${username}.extraGroups = [
    "libvirtd"
    "kvm"
  ];

  environment.systemPackages = with pkgs-fresh; [
    virt-viewer
    spice
    spice-gtk
  ];

  # Workaround: systemd-creds crashes (assertion bug in 259.3) when TPM2 sealing
  # fails, causing virt-secret-init-encryption.service to fail and block libvirtd.
  systemd.services."virt-secret-init-encryption".enable = false;
  systemd.services.libvirtd.serviceConfig.LoadCredentialEncrypted = "";
}
