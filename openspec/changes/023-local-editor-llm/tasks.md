# Tasks

## 1. Shared declaration

- [ ] 1.1 In `home/default.nix`, add `LOCAL_LLM_BASE_URL`
  (`http://127.0.0.1:8001/v1`), `LOCAL_LLM_MODEL` and `LOCAL_LLM_API_KEY_FILE`
  (`$HOME/.config/local-llm/api-key`) to `environment.sessionVariables`, and
  remove `unstable.copilot-language-server` from the package list. Ask the
  operator for the model name rather than guessing it.
  Validation: `nix-instantiate '<nixpkgs/nixos>' -A system -I nixos-config=./hosts/spyridon`

- [ ] 1.2 Under the README's "AI development tools" section, document that
  editor AI uses only the local server, which variables declare it, and that
  the operator creates the key file by hand with mode 0600. Seeing the
  variables in a desktop-launched editor needs a rebuild and a new login, so
  that check is run by the operator and recorded here: `M-: (getenv
  "LOCAL_LLM_BASE_URL")` in Emacs, and `:echo $LOCAL_LLM_BASE_URL` in Neovim.
  Validation: `grep -n 'LOCAL_LLM_API_KEY_FILE' README.md`

## 2. Doom Emacs

- [ ] 2.1 Remove copilot.el: its `package!` entry, its `use-package!` block, the
  secret-file regexp, both advices and the `SPC t C` binding.
  Validation: `grep -n 'copilot' config/doom/config.el config/doom/packages.el` prints only gptel lines that task 2.2 removes, or nothing.

- [ ] 2.2 Rework gptel: one OpenAI-compatible backend built from
  `LOCAL_LLM_BASE_URL` and `LOCAL_LLM_MODEL`, with its key read from
  `LOCAL_LLM_API_KEY_FILE` on each request. Remove the Copilot and Ollama
  backends and `my/read-openai-api-key`, and keep `gptel-use-tools nil`. The
  operator then checks that a chat message reaches the server, and that with
  the key file moved away a message fails visibly and Emacs stays usable.
  Validation: `grep -nE 'gh-copilot|make-ollama|openai-api-key|127\.0\.0\.1' config/doom/config.el` prints nothing.

- [ ] 2.3 Add `minuet.el` on the local server's chat endpoint, sharing the
  backend values from task 2.2. Leave it off at startup, and bind one leader
  key that turns automatic suggestions on or off for the session. Use the
  plugin's own global mode if the installed version has one; otherwise turn
  its per-buffer mode on through a hook while the toggle is set. The operator
  then checks three things: typing before the toggle makes no request;
  suggestions appear in newly opened buffers after it; and with the server
  stopped, typing with the toggle on does not hang Emacs.
  Validation: `emacs --batch --eval '(with-temp-buffer (insert-file-contents "config/doom/config.el") (condition-case nil (while t (read (current-buffer))) (end-of-file (message "parses"))))'`

## 3. Neovim

- [ ] 3.1 Remove `config/nvim/lua/plugins/copilot.lua` and the
  `ai.copilot-chat` import in `config/nvim/lua/config/lazy.lua`, along with its
  comment line about the dropped `ai.copilot` extra.
  Validation: `grep -rn -i 'copilot' config/nvim/lua` prints only the commented supermaven line.

- [ ] 3.2 Add `minuet-ai.nvim` on the chat endpoint, built from the three
  variables. Read the key file on each request. Do not load the plugin until a
  `<leader>a` toggle turns automatic suggestions on for the session. The
  operator then checks two things: before the toggle, `:Lazy` lists minuet as
  not loaded; after it, suggestions appear in newly opened buffers.
  Validation: `nvim --headless -u NONE -c 'lua assert(loadfile("config/nvim/lua/plugins/minuet.lua"))' -c q`

- [ ] 3.3 Add CodeCompanion with one OpenAI-compatible adapter built from the
  three variables, set as the chat strategy's adapter, with tools disabled.
  The operator then checks that a chat message reaches the server, and that
  the adapter list shows only this adapter.
  Validation: `nvim --headless -u NONE -c 'lua assert(loadfile("config/nvim/lua/plugins/codecompanion.lua"))' -c q`

- [ ] 3.4 Let lazy.nvim drop the removed plugins from
  `config/nvim/lazy-lock.json`: run `:Lazy clean` and `:Lazy sync` in Neovim,
  then confirm the key appears nowhere in the repository. The check reads the
  key file as patterns and prints only the verdict, never the key.
  Validation: `grep -rqF -f "$LOCAL_LLM_API_KEY_FILE" --exclude-dir=.git . && echo FOUND || echo absent` prints `absent`, and `grep -c -i copilot config/nvim/lazy-lock.json` prints `0`.

## Unreconciled
