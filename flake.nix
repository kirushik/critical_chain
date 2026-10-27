{
  # The development shell: the pinned Ruby, the libraries the native gems
  # build against, and Node for the Playwright driver the specs drive.
  # It builds nothing itself: the app is still `bundle install` and
  # `npm install`, the same as on CI (.circleci/config.yml).
  description = "Critical Chain development shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  };

  outputs =
    { nixpkgs, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      devShells = forAllSystems (
        pkgs:
        let
          inherit (pkgs) lib;
          # The Gemfile pins an exact patch release and Bundler refuses any
          # other, so .ruby-version, the Gemfile, Gemfile.lock and CI's image
          # follow nixpkgs' 3.3.x: after a nixpkgs bump moves it, bump them
          # together. The assert says so instead of Bundler, at load time.
          ruby = pkgs.ruby_3_3;
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
