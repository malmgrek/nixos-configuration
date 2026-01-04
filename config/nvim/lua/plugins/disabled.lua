-- Disable Mason (use Nix for all tooling)
return {
  { "mason.nvim", enabled = false },
  { "mason-lspconfig.nvim", enabled = false },
  { "mason-nvim-dap.nvim", enabled = false },
}
