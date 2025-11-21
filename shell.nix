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
    project_name=$(echo "$PWD" | cut -d/ -f4)

    export GEM_HOME="$PWD/.bundle/gems-$ruby_api_version"
    export BUNDLE_PATH="$PWD/.bundle/bundle-$ruby_api_version"
    export GEM_PATH="$GEM_HOME:${bundler}/lib/ruby/gems/$ruby_api_version:${ruby}/lib/ruby/gems/$ruby_api_version"
    export PATH="$GEM_HOME/bin:$PATH"

    export SSH_AUTH_SOCK=${builtins.getEnv "SSH_AUTH_SOCK"}
    export HOME=${builtins.getEnv "HOME"}

    echo "[base: $project_name] Ruby version: $(ruby --version) $(bundle --version || true)"
  '';

}
