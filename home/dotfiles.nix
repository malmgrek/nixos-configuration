{ config, ... }:

let

  inherit (config.customParams) repoPath userName;

  # A configuration directory reached by reference rather than by copy, so the
  # file an application opens and the file in the working tree are one file.
  #
  # "L+" replaces whatever occupies the path, removing a directory recursively:
  # the first switch after a directory is listed here takes out whatever the
  # application had written beside its configuration. See design.md.
  link = name: "L+ %h/.config/${name} - - - - ${repoPath}/config/${name}";

in

{

  # Scoped to one user: the unscoped `systemd.user.tmpfiles.rules` goes into the
  # system profile, which every account's systemd instance reads, and `%h` would
  # then aim each of their ~/.config at this user's checkout.
  #
  # Applied by `systemd-tmpfiles --user` in `system.userActivationScripts`,
  # which switch-to-configuration restarts on every switch, so a link appears on
  # the rebuild that declares it. Editing a file behind an existing link needs
  # no rebuild, which is the point of the mechanism.
  #
  # Applications write their own settings back into the working tree, which is
  # intended: a choice made in an application's interface becomes a reviewable
  # change rather than something the next rebuild discards. Where an application
  # drops churn alongside, a .gitignore in that directory keeps it out.
  systemd.user.tmpfiles.users.${userName}.rules = map link [
    "doom"
    "nixpkgs"
    "nvim"
    "opencode"
  ];

}
