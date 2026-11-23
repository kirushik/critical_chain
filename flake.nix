{
  # The development shell: the pinned Ruby, the libraries the native gems
  # build against, and Node for the Playwright driver the specs drive.
  # It builds nothing itself: the app is still `bundle install` and
  # `npm install`, the same as on CI (.circleci/config.yml).
  description = "Critical Chain development shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    # The Railway CLI only: 26.05 carries 4.x, Railway's docs assume 5.x.
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { nixpkgs, nixpkgs-unstable, ... }:
    let
      # Gemfile.lock carries only x86_64-linux gems (as CI and Railway run);
      # another system would re-resolve and rewrite it on `bundle install`.
      # Add one together with `bundle lock --add-platform`.
      systems = [
        "x86_64-linux"
      ];
      forAllSystems =
        f:
        nixpkgs.lib.genAttrs systems (
          system: f nixpkgs.legacyPackages.${system} nixpkgs-unstable.legacyPackages.${system}
        );
    in
    {
      devShells = forAllSystems (
        pkgs: unstable:
        let
          inherit (pkgs) lib;
          # The Gemfile pins an exact patch release and Bundler refuses any
          # other, so .ruby-version, the Gemfile, Gemfile.lock, CI's image and
          # this Ruby move together. nixpkgs lags upstream patch releases, so
          # the pinned one is built here with nixpkgs' own recipe; the hash is
          # the release tarball's sha256 from ruby-lang.org. Once nixpkgs'
          # ruby_3_4 catches up, `ruby = pkgs.ruby_3_4;` is enough again. The
          # assert says what to bump instead of Bundler, at load time.
          ruby = pkgs.mkRuby {
            version = pkgs.mkRubyVersion "3" "4" "13" "";
            hash = "sha256-0NO/PdjCJKPDt+zYFqDxssvPT4e1r8vb6R0/7xd/NRo=";
            # YJIT's vendored crates; unchanged across 3.4.x so far.
            cargoHash = "sha256-5Tp8Kth0yO89/LIcU8K01z6DdZRr8MAA0DPKqDEjIt0=";
          };
          pinned = lib.fileContents ./.ruby-version;
        in
        assert lib.assertMsg (toString ruby.version == pinned)
          "nixpkgs has Ruby ${ruby.version}, .ruby-version says ${pinned}: bump .ruby-version, Gemfile, Gemfile.lock and .circleci/config.yml";
        {
          default = pkgs.mkShell {
            name = "critical-chain";

            nativeBuildInputs = with pkgs; [
              pkg-config
            ];

            # For gems without a prebuilt x86_64-linux-gnu binary in the
            # lockfile: psych, pg (the production group is installed too),
            # openssl, nokogiri's fallback build.
            buildInputs = with pkgs; [
              libyaml
              libffi
              openssl
              zlib
              libpq
              sqlite
            ];

            packages = with pkgs; [
              ruby
              nodejs_24
              # A browser that runs on NixOS: Playwright's own downloads
              # expect an FHS loader. spec/support/playwright.rb launches it
              # when PLAYWRIGHT_CHROMIUM_EXECUTABLE is set.
              chromium
              sqlite-interactive
              # Production runs there (railway.toml); `railway link` once per
              # checkout.
              unstable.railway
            ];

            # Gems next to the checkout, as on CI, so they are built against
            # this Ruby and never mix with another project's.
            BUNDLE_PATH = "vendor/bundle";
            PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";
            PLAYWRIGHT_CHROMIUM_EXECUTABLE = "${pkgs.chromium}/bin/chromium";
          };
        }
      );
    };
}
