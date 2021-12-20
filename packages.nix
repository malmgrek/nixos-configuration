[
  (self: super: with super; {

    nur = import (builtins.fetchTarball
      "https://github.com/nix-community/NUR/archive/master.tar.gz") {
        pkgs = super;
      };

    #
    # Occasionally, "stable" packages are broken or incomplete, so access to the
    # bleeding edge is necessary, as a last resort. If needed, comment out
    # and use in configuration instead of `pkgs`
    #
    # unstable = import <nixpkgs-unstable> { inherit config; };

  })

  # emacsGit and emacsUnstable
  (import (builtins.fetchTarball https://github.com/nix-community/emacs-overlay/archive/master.tar.gz))
]

