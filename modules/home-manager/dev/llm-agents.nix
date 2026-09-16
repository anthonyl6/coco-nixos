{
  pkgs-fresh,
  inputs,
  stdenv,
  config,
  ...
}: let
  caveman = pkgs-fresh.fetchFromGitHub {
    owner = "juliusbrussee";
    repo = "caveman";
    rev = "v1.6.0";
    sha256 = "sha256-m7HhCW4fXU5pIYRWVP6cvSYUkDHt8R90D9UI3tT7euk=";
  };
  llm-agents = inputs.llm-agents.packages.${stdenv.system};
in {
  home.packages = [
    llm-agents.crush
    llm-agents.opencode2
  ];

  home.file.".config/agents/skills/caveman" = {
    source = "${caveman}/skill.md";
  };

  home.sessionVariables = {
    CRUSH_SKILLS_DIR = "${config.home.homeDirectory}/.config/agents/skills";
  };
}
