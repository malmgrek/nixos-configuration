{ config, options, lib, pkgs, ... }:
with lib;
{

  options.modules.editors.vim = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.modules.editors.vim.enable {
    my = {
      packages = with pkgs; [
        editorconfig-core-c
        neovim
      ];
    };
    programs.vim = {
      enable = true;
      plugins = with pkgs.vimPlugins; [
        auto-pairs
        vim-airline
        vim-airline-themes
        vim-fugitive
        vim-nix
      ];
      extraConfig = ''
      " Colors
      "
      " Use 24-bit (true-color) mode in Vim when outside tmux
      "
      " NOTE: A longer if statement for Neovim is given e.g. in
      "       https://github.com/joshdick/onedark.vim
      "
      if (has("termguicolors"))
        set termguicolors
      endif
      set t_Co=256  " Use 256 (uncomment if supported in terminal)
      syntax on
      let color = expand("~/.vim/color.vim")
      if filereadable(color)
        exec "source" color
      else
        colorscheme delek
      endif

      " Additional file type definitions
      autocmd BufRead,BufNewFile *.zsh-theme set filetype=zsh
      autocmd BufRead,BufNewFile .spacemacs set filetype=lisp

      " Remove trailing whitespace on saving
      autocmd BufWritePre * :%s/\s\+$//e
      ''
    };
  };

}
