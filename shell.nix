let
  pkgs = import <nixpkgs> {};

  opensslPinned = pkgs.openssl_3;

  ruby = pkgs.ruby_3_4.override {
    openssl = opensslPinned;
  };
  
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

  rubyEnv = pkgs.symlinkJoin {
    name = "clean-ruby-env";
    paths = [ ruby bundler opensslPinned ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/ruby --set GEM_PATH "${bundler}/lib/ruby/gems/3.4.0:${ruby}/lib/ruby/gems/3.4.0"
      wrapProgram $out/bin/bundle --set GEM_PATH "${bundler}/lib/ruby/gems/3.4.0:${ruby}/lib/ruby/gems/3.4.0"
    '';
  };

in pkgs.mkShell {
  buildInputs = [
    rubyEnv

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

    if [ -d "/home/ha2itats/$project_name/shared/" ]; then
      export GEM_HOME="/home/ha2itats/$project_name/shared/bundle/ruby/$ruby_api_version"
      export BUNDLE_PATH="/home/ha2itats/$project_name/shared/bundle"
    else
      export GEM_HOME="$PWD/.bundle/gems-$ruby_api_version"
      export BUNDLE_PATH="$PWD/.bundle/bundle-$ruby_api_version"
    fi

    export GEM_PATH="$GEM_HOME:${bundler}/lib/ruby/gems/$ruby_api_version:${ruby}/lib/ruby/gems/$ruby_api_version"
    export PATH="$GEM_HOME/bin:$PATH"

    export SSH_AUTH_SOCK=${builtins.getEnv "SSH_AUTH_SOCK"}
    export HOME=${builtins.getEnv "HOME"}

    echo "[base: $project_name] Ruby version: $(ruby --version) $(bundle --version || true)"
  '';

}
