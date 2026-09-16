{ pkgs-stable, ... }:
{
  # Local model server for the agentic-soc work (openai_compat provider).
  # Listens on 127.0.0.1:11434 — project config points at:
  #   base_url: http://localhost:11434/v1
  #
  # Acceleration: the NVIDIA eGPU (hardware/nvidia-egpu.nix) is picked up
  # when it is plugged in; without it the service runs pure CPU, which is
  # fine for the small schemas this project gives local models (see
  # docs/modularity.md, "Job selection").
  #
  # Note: services.ollama.acceleration was removed in 26.11 — the CUDA build
  # is selected via `package` instead.
  #
  # Pull a model after the first switch, e.g.:
  #   ollama pull llama3.1:8b
  services.ollama = {
    enable = true;
    package = pkgs-stable.ollama-cuda;
  };
}
