{ config, options, lib, ... }:
with lib;
let mkOptionStr = value: mkOption
  { type = types.str;
    default = value; };
in {
  
  options = {
    my = {
      username = mkOptionStr "malmgrek";
      email = mkOptionStr "stratos.staboulis@gmail.com";
    };
  };

}
