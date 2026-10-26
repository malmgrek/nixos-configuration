{ config, pkgs, ... }:

let

  cursorTheme = "Vanilla-DMZ";
  cursorSize = 32;

  # What home.pointerCursor generated: a theme named "default" that inherits the
  # real one, so applications asking for the default cursor get it. The package
  # lands in a profile, and xdg/icons.nix already puts every profile's
  # share/icons in XCURSOR_PATH.
  defaultCursorTheme = pkgs.writeTextFile {
    name = "default-cursor-theme";
    destination = "/share/icons/default/index.theme";
    text = ''
      [Icon Theme]
      Name=Default
      Comment=Default Cursor Theme
      Inherits=${cursorTheme}
    '';
  };

in

{
  users.users.${config.customParams.userName}.packages = with pkgs; [
    xhost
    vanilla-dmz
    defaultCursorTheme
  ];

  environment.sessionVariables = {
    XCURSOR_THEME = cursorTheme;
    XCURSOR_SIZE = toString cursorSize;
  };

  # Its own merge rather than appended to the one in options.nix: that one is
  # gated on a pinned dpi, and the cursor has nothing to do with density.
  # sessionCommands is lines, so the two concatenate.
  services.xserver.displayManager.sessionCommands = ''
    ${pkgs.xrdb}/bin/xrdb -merge <<EOF
      Xcursor.theme: ${cursorTheme}
      Xcursor.size: ${toString cursorSize}
    EOF
  '';
}
