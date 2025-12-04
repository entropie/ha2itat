let
  # pkgs = import <nixpkgs> {};

  pkgs = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/nixos-24.05.tar.gz";
  }) {};
  
  ruby = pkgs.ruby_3_2;
  
  bundler = pkgs.buildRubyGem {
    inherit ruby;
    gemName = "bundler";
    version = "2.7.2";
    source = {
      type = "gem";
      url = "https://rubygems.org/downloads/bundler-2.7.2.gem";
      sha256 = "sha256-Heyvni4ay5G2WGopJcjz9tojNKgnMaYv8t7RuDwoOHE=";
    };
  };

in pkgs.mkShell {
  buildInputs = [
    ruby
    bundler

    pkgs.gcc
    pkgs.gnumake
    pkgs.pkg-config
    pkgs.zlib
    pkgs.libyaml
    pkgs.libffi

    pkgs.rustc
    pkgs.cargo
    pkgs.rustPackages.clippy
    pkgs.rustPlatform.bindgenHook
    pkgs.libclang
    pkgs.llvmPackages.libclang

    pkgs.autoconf
    pkgs.automake
    pkgs.libtool
    pkgs.imagemagick

    pkgs.nodejs_22
    pkgs.nodePackages.node-gyp

    pkgs.ffmpeg
    pkgs.yt-dlp

    pkgs.git
    pkgs.overmind
  ];
  shellHook = ''

    ruby_api_version=$(ruby -e 'puts RbConfig::CONFIG["ruby_version"]')
    project_dir=$(readlink -f "$PWD")
    project_name=$(basename $project_dir)

    export GEM_HOME="$PWD/.bundle/gems-$ruby_api_version"
    export BUNDLE_PATH="$PWD/.bundle/bundle-$ruby_api_version"
    export GEM_PATH="$GEM_HOME:${bundler}/lib/ruby/gems/$ruby_api_version:${ruby}/lib/ruby/gems/$ruby_api_version"
    export PATH="$GEM_HOME/bin:$PATH"

    export SSH_AUTH_SOCK=${builtins.getEnv "SSH_AUTH_SOCK"}
    export HOME=${builtins.getEnv "HOME"}

    echo "[base: $project_name] Ruby version: $(ruby --version) $(bundle --version || true)"


    nix_roots="$HOME/.nix-roots"
    mkdir -p "$nix_roots"

    out_link="$nix_roots/$project_name-shell"

    hash_file="$out_link.hash"
    current_hash=$(sha256sum "$project_dir/shell.nix" | cut -d' ' -f1)

    if [ ! -f "$hash_file" ] || [ "$(cat "$hash_file")" != "$current_hash" ]; then
      echo "pinning dev shell for $project_name -> $out_link..."
      nix-build "$project_dir/shell.nix" --out-link "$out_link"
      echo "$current_hash" > "$hash_file"
      echo "updated pinned shell $out_link"
    fi
  '';

}
