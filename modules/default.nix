{ config, options, lib, ... }:
with lib;
let mkOptionStr = value: mkOption
  { type = types.str;
    default = value; };
in {

  imports = [
    ./desktop
    ./editors
  ];

  options = {

    my = {
      username = mkOptionStr "malmgrek";
      email = mkOptionStr "stratos.staboulis@gmail.com";
      # TODO home = Uses home-manager...
      user = mkOption { type = types.submodule; };
      packages = mkOption { type = with types; listOf package; };
      env = mkOption {
        type = with types; attrsOf
          (either (either str path) (listOf (either str path)));
        apply = mapAttrs
          (n: v: if isList v
                 then concatMapStringsSep ":" (x: toString x) v
                 else (toString v));
      };
      alias = mkOption {
        type = with types; nullOr (attrsOf (nullOr (either str path)));
      };
    };

  };

  config = {

    users.users.${config.my.username} = mkAliasDefinitions options.my.user;
    my.user.packages = config.my.packages;
    # NOTE The <...> notation is related to
    # the -I option on CLI.
    # my.env.PATH = [ <bin> "$PATH" ];

  };

}
