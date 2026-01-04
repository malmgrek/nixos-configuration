return {
  {
    "nvim-orgmode/orgmode",
    event = "VeryLazy",
    ft = { "org" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      org_agenda_files = "~/org/**/*",
      org_default_notes_file = "~/org/refile.org",
      org_todo_keywords = { "TODO", "DOING", "|", "DONE" },
      org_hide_leading_stars = true,
    },
  },
}
