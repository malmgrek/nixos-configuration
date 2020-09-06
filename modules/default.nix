{ config, options, lib, ... }:
with lib;
let mkOptionStr = value: mkOption
  { type = types.str;
    default = value; };
in {

  imports = [];
  
  options = {

    my = {
      username = mkOptionStr "malmgrek";
      email = mkOptionStr "stratos.staboulis@gmail.com";
      user = mkOption { type = types.submodule; };
    };

  };

  config = {

    users.users.${config.my.username} = mkAliasDefinitions options.my.user;
    
  };

}
