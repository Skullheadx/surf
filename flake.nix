{
  description = "flake for surf";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      lib = pkgs.lib;

    in
    {
      packages.${system}.default = pkgs.stdenv.mkDerivation {
        pname = "surf";
        version = "2.1";
        src = ./.;

        nativeBuildInputs = with pkgs; [
          pkg-config
          wrapGAppsHook3
        ];
        buildInputs = with pkgs; [
          glib
          gcr
          glib-networking
          gsettings-desktop-schemas
          gtk3
          libsoup_3
          webkitgtk_4_1
        ]
        ++ (with pkgs.gst_all_1; [
          # Audio & video support for webkitgtk WebView
          gstreamer
          gst-plugins-base
          gst-plugins-good
          gst-plugins-bad
        ]);

        makeFlags = [ "PREFIX=$(out)" ];

        # Add run-time dependencies to PATH. Append them to PATH so the user can
        # override the dependencies with their own PATH.
        preFixup =
          let
            depsPath = lib.makeBinPath  (with pkgs; [
              xprop
              dmenu
              findutils
              gnused
              coreutils
            ]);
          in
          ''
            gappsWrapperArgs+=(
              --suffix PATH : ${depsPath}
            )
          '';
      };
    };
}
