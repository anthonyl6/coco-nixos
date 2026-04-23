{
  pkgs-fresh,
  username,
  ...
}:

{
  # Load KVM modules dynamically
  boot.kernelModules = [
    "kvm"
    "kvm-intel"
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
}
