-- InterSystems ObjectScript (Caché / IRIS) support:
--   * filetype detection (.cls is otherwise guessed as TeX/VB)
--   * tree-sitter grammars from intersystems/tree-sitter-objectscript

local repo = "https://github.com/intersystems/tree-sitter-objectscript"

vim.filetype.add({
  extension = {
    cls = "objectscript_udl",
    mac = "objectscript_routine",
    inc = "objectscript_routine",
    int = "objectscript_routine",
    rtn = "objectscript_routine",
  },
})

-- Register the custom parsers (nvim-treesitter `main` branch API)
vim.api.nvim_create_autocmd("User", {
  pattern = "TSUpdate",
  callback = function()
    local parsers = require("nvim-treesitter.parsers")
    parsers.objectscript_udl = {
      install_info = { url = repo, location = "udl", queries = "udl/queries" },
    }
    parsers.objectscript_routine = {
      install_info = { url = repo, location = "objectscript_routine", queries = "objectscript_routine/queries" },
    }
  end,
})

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "objectscript_udl", "objectscript_routine" })
    end,
  },
}
