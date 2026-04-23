{
  inputs,
  pkgs-stable,
  ...
}:
let
  formatters = with pkgs-stable; [
    # nix
    alejandra
    # rust
    rustfmt
    dioxus-cli
    # zig
    zig
    # yaml
    yamlfmt
  ];

  languageServers = with pkgs-stable; [
    # rust
    rust-analyzer
    # nix
    nil
    # typescript + javascript + tsx + jsx
    typescript-language-server
    # json + jsonc
    vscode-json-languageserver
    # go
    gopls
    golangci-lint-langserver
    # bash
    bash-language-server
    # astro
    astro-language-server
    # c-sharp
    csharp-ls
    omnisharp-roslyn
    # yaml
    yaml-language-server
    # prisma
    prisma-language-server
    # zig
    zls
    # css
    vscode-css-languageserver
    # toml
    taplo
    tombi
  ];

  debuggers = with pkgs-stable; [
    # go
    delve
    # c-sharp
    netcoredbg
    # zig
    lldb
  ];

  formattersWithLanguageServers = with pkgs-stable; [
    # typescript + javascript + tsx + jsx + json + jsonc
    biome
  ];
in
{
  home.packages =
    with pkgs-stable;
    [
      inputs.helix.packages."${system}".default
    ]
    ++ debuggers
    ++ languageServers
    ++ formatters
    ++ formattersWithLanguageServers;
}
