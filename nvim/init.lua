vim.g.mapleader = " "

vim.opt.hlsearch = false
vim.opt.incsearch = true

-- vim.opt.spell = true
-- vim.opt.spelllang = {"en_us"}

vim.opt.autoread = true
-- vim.opt.autowrite = true,
-- vim.opt.autowriteall = true,

-- Indentation
vim.opt.expandtab = true -- Expand tab to space in insert mode
vim.opt.shiftwidth = 2 -- Number of spaces used when expanding tab
vim.opt.tabstop = 2 -- Number of spaces that a tab counts for in a file
vim.opt.softtabstop = 2 
vim.opt.smartindent = true -- Smart autoindenting when starting new line 
vim.opt.copyindent = true -- Copy previous indentation when autoindenting

-- Columns
vim.opt.fillchars = { eob = " " } -- Disabe `~` on nonexistent lines
vim.opt.number = true -- Display the number column
vim.opt.numberwidth = 2 -- Width of the number column relativenumber = true, -- Use realtive numbers
vim.opt.relativenumber = true
vim.opt.signcolumn = "no" -- Show the sign column only when there is a sign to show
-- vim.opt.signcolumn = "number" -- Show the sign column only when there is a sign to show

-- Status line
vim.opt.ruler = true -- Don't show coordinates of the cursor on the status line
vim.opt.cmdheight = 0 -- Hide command line unless used
vim.opt.showmode = false -- Don't show current mode on the status line
vim.opt.laststatus = 0

-- Windows
vim.opt.splitright = true -- Split new vertical window to the right
vim.opt.splitbelow = true -- Split new horizontal window below

vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus" -- Use system clipboard

vim.opt.cursorline = true -- Highlight the line of the cursor
vim.opt.termguicolors = true -- Enable 24-bit RGB colors

vim.opt.undofile = true
vim.opt.undolevels = 1000
vim.opt.history = 1000 -- Number of command to remember in a history file

vim.opt.updatetime = 300 -- Interval for writing swap files to disk
vim.opt.timeoutlen = 500 -- Time in miliseconds to complete key mapping

vim.opt.smartcase = true -- Case inensitive search unless capital letters used
vim.opt.ignorecase = true

vim.opt.autowrite = true -- Enable autowrie when switching buffers
vim.opt.conceallevel = 3 -- Completely hide concealed text
vim.opt.list = true -- Show some invisible characters
vim.opt.sessionoptions = { "buffers", "curdir", "tabpages" } -- Used when saving and restoring session with `:mksession`

vim.opt.grepformat = "%f:%l:%c:%m"
vim.opt.grepprg = "rg --vimgrep"

vim.opt.pumblend = 10 -- Popup transparency
vim.opt.pumheight = 10 -- Maximum number of entries in a popup

vim.opt.wrap = true
vim.opt.linebreak = true;

vim.opt.whichwrap:append("<>[]hl")
vim.opt.shortmess:append({ W = true, I = true, c = true, s = true })
vim.opt.shada:append("%")

-- Disabe unneded providers
local default_providers = { "node", "perl", "python3", "ruby" }
for _, provider in ipairs(default_providers) do
  vim.g["loaded_"..provider.."_provider"] = 0
end

local default_plugins = {
  "2html_plugin", "getscript", "getscriptPlugin", "gzip", "logipat",
  "netrw", "netrwPlugin", "netrwSettings", "netrwFileHandlers", "matchit",
  "tar", "tarPlugin", "rrhelper", "spellfile_plugin", "vimball", "vimballPlugin",
  "zip", "zipPlugin", "tutor", "rplugin", "syntax", "synmenu", "optwin", "compiler",
  "bugreport", "ftplugin"
}
for _, plugin in ipairs(default_plugins) do
  vim.g["loaded_"..plugin] = 1
end

-- "sy match Bold '\\#.*$'"
-- sy region WarningMsg matchgroup=@text start="\[\[" end="\]\]" keepend oneline concealends
-- sy region WarningMsg matchgroup=@text start="\[\[.* | " end="\]\]" keepend oneline concealends

-- ime autocommands
vim.api.nvim_create_autocmd("InsertLeave", {command = "silent !fcitx5-remote -c"})
vim.api.nvim_create_autocmd("InsertEnter", {command = "silent !fcitx5-remote -o"})

vim.filetype.add({
  extension = { wgsl = 'wgsl', }
})

-- Bootstrap plugin manager
local path = vim.fn.stdpath'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(path) then vim.fn.system{
    'git',
    'clone',
    '--filter=blob:none',
    '--branch=stable',
    'https://github.com/folke/lazy.nvim',
    path,
  }
end
vim.opt.rtp:prepend(path)

function config_treesitter()
  -- Don't conceal code blocks in markdown
  -- https://github.com/nvim-treesitter/nvim-treesitter/issues/5751
  -- require("vim.treesitter.query").set("markdown", "highlights", [[
  -- ;From MDeiml/tree-sitter-markdown
  -- [
  --   (fenced_code_block_delimiter)
  -- ] @punctuation.delimiter
  -- ]])

  require("nvim-treesitter.configs").setup({
    -- ensure_installed = { "c", "lua", "rust" },
    auto_install = true,
    highlight = {
      enable = true,
      -- additional_vim_regex_highlighting = { "markdown" },
    },
    indentation = { enable = true },
    textobjects = {
      select = {
        enable = true,
        lookahead = true,
        keymaps = {
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["ac"] = "@class.outer",
          ["ic"] = "@class.innter",
          ["as"] = { query = "@scope", query_group = "locals" },
          ["ip"] = "@parameter.inner",
          ["ap"] = "@parameter.outer",
        },
        selection_modes = {
          ["@parameter.outer"] = "v",
          ["@function.outer"] = "V",
          ["@class.outer"] = "<C-V>",
        },
        include_surrounding_whitespace = true,
      },
      swap = {
        enable = true,
        swap_next = {
          ["<leader>a"] = "@parameter.inner",
        },
        swap_previous = {
          ["<leader>A"] = "@parameter.inner",
        },
      },
      move = {
        enable = true;
        set_jumps = true;

        goto_previous_start = {
          ["(("] = "@parameter.inner",
        },

        goto_next_start = {
          ["))"] = "@parameter.inner",
        },
      },
    },
  })
end

function config_telescope()
  require("telescope").setup({
    defaults = {
      mappings = {
        i = {
          ["<C-u>"] = false,
          ["<C-e>"] = function(prompt_bufnr)
            local actions = require("telescope.actions.state")
            local current_picker = actions.get_current_picker(prompt_bufnr)
            local prompt = current_picker:_get_prompt()
            require("telescope.actions").close(prompt_bufnr)
            vim.cmd(":e " .. prompt)
            return true
          end,
        },
      },
      -- borderchars = { " "," "," "," "," "," "," "," " },
      layout_strategy = "flex",
      layout_config = {
        horizontal = {
          prompt_position = "bottom",
          width = { padding = 0 },
          height = { padding = 0 },
          preview_width = 0.5,
        },
        vertical = {
          prompt_position = "bottom",
          width = { padding = 0 },
          height = { padding = 0 },
          preview_height = 0.4,
        },
      },
    },
  })

  require("telescope").load_extension("file_browser")

end

function config_lsp(capabilities)
  local lsp = require("lspconfig")
  local opts = { capabilities = capabilities }
  lsp.rust_analyzer.setup(opts)
  lsp.ts_ls.setup(opts)
  lsp.clangd.setup(opts)
  lsp.markdown_oxide.setup(opts)

end

function config_completion()
  local cmp = require("cmp")
  vim.opt.completeopt = { "menu", "menuone", "noselect" }
  local luasnip = require("luasnip")

  cmp.setup{
    view = {
      docs = { auto_open = false },

    },
    window = {
      completion = cmp.config.window.bordered(),
      documentation = cmp.config.window.bordered(),
    },
    snippet = {
      expand = function(args)
        luasnip.lsp_expand(args.body)
      end,
    },
    sources = cmp.config.sources({
      { name = "nvim_lsp" },
      { name = "luasnip" },
      { name = "calc" },
      -- { name = "spell" },
    }, {
      { name = "buffer" },
      { name = "path" },
    }),
  }

  cmp.setup.cmdline({"/", "?"}, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = "buffer" }
    }
  })

  cmp.setup.cmdline(":", {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = "path" }
    }, {
      { name = "cmdline" }
    }),
    matching = { disallow_symbol_nonprefix_matching = false }
  })

  config_lsp(require("cmp_nvim_lsp").default_capabilities())

end

local plugins = {

  -- Themes
  { "folke/tokyonight.nvim" },
  { "nyoom-engineering/oxocarbon.nvim" },
  { "rebelot/kanagawa.nvim" },
  { "sontungexpt/witch" },
  { "Abstract-IDE/Abstract-cs" },

  { "kyazdani42/nvim-web-devicons" },
  { "echasnovski/mini.files", version = false, opts = {}},
  { 'glacambre/firenvim', build = ":call firenvim#install(0)" },
  { "windwp/nvim-ts-autotag", opts = {} },
  -- { "stevearc/oil.nvim", opts = {} },
  { "tpope/vim-fugitive" },
  { "lewis6991/gitsigns.nvim", opt = {} },
  { "folke/zen-mode.nvim", opts = {} },
  { "wellle/targets.vim" },
  { "tpope/vim-repeat", event = "VeryLazy" },
  -- { "gpanders/nvim-parinfer", ft = {"lisp", "clojure", "scheme"} },
  { "eraserhd/parinfer-rust", build = "cargo build --release" },
  { "windwp/nvim-autopairs", event = "InsertEnter", config = true },
  { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },
  { "nvim-lua/plenary.nvim" },
  { "LhKipp/nvim-nu", ft = "nu", opt = {} },
  { "kylechui/nvim-surround", event = "VeryLazy", opts = {} },
  -- { "arnamak/stay-centered.nvim", event = "VeryLazy", opts = {}, enabled = false, },
  { "ggandor/leap.nvim", config = function() require("leap").add_default_mappings() end, },
  { "ggandor/flit.nvim", opts = {} },
  { "ggandor/leap-spooky.nvim", opts = {} },
  -- { "joshuadanpeterson/typewriter.nvim", dependencies = "nivm-treesitter/nvim-treesitter", opts = {} },
  --
  {
    "rmagatti/auto-session",
    lazy = false,
    opts = {
      supressed_dirs = { "~/", "/", "/nix" },
    },
  },

  {
    "folke/noice.nvim",
    dependencies = { "MunifTanjim/nui.nvim" },
    event = "VeryLazy",
    opts = {
      lsp = {
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
          },
        },
      presets = {
        bottom_search = false, -- use a classic bottom cmdline for search command_palette = true, -- position the cmdline and popupmenu together
        long_message_to_split = true, -- long messages will be sent to a split
        inc_rename = false, -- enables an input dialog for inc-rename.nvim
        lsp_doc_border = true, -- add a border to hover docs and signature help
      },
    },
  },

  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
    opts = {},
    enabled = false,
  },

  -- {
  --   "romgrk/barbar.nvim",
  --   dependencies = { "nvim-tree/nvim-web-devicons" },
  --   -- init = function() vim.g.barbar_auto_setup = false end,
  --   config = function()
  --     vim.keymap.set({"n", "i"}, "<C-q>", vim.cmd.BufferClose)
  --     vim.keymap.set({"n", "i"}, "<C-p>", vim.cmd.BufferPrevious)
  --     vim.keymap.set({"n", "i"}, "<C-n>", vim.cmd.BufferNext)
  --     vim.keymap.set("n", "<C-e>", vim.cmd.BufferPick)
  --   end,
  --   opts = {},
  -- },

  {
    "folke/which-key.nvim", even = "VeryLazyy", opts = {},
    keys = {
      { "<leader>?", function() require("which-key").show({ global = true }) end },
    }
  },

  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = { "nushell/tree-sitter-nu" },
    build = ":TSUpdate",
    config = config_treesitter,
  },
  -- { "nvim-treesitter/nvim-treesitter-context", opt = {} },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    dependencies = {  "nvim-treesitter/nvim-treesitter" },
  },

  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = config_telescope,
  },
  {
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" }
  },

  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "neovim/nvim-lspconfig", "f3fora/cmp-spell", "max397574/cmp-greek",
      "hrsh7th/cmp-nvim-lsp", "hrsh7th/cmp-calc", "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path", "hrsh7th/cmp-cmdline", "saadparwaiz1/cmp_luasnip",
      {
        "L3MON4D3/LuaSnip",
        dependencies = { "rafamadriz/friendly-snippets" },
        -- build = "make install_jsregexp",
        config = function() require("luasnip.loaders.from_vscode").lazy_load() end,
      },
    },
    config = config_completion,
  },

  {
    "saghen/blink.cmp",
    lazy = false,
    dependencies = "rafamadriz/friendly-snippets",
    version = "v0.*",
    opts = {
      nerd_font_variant = "normal",
    },
    enabled = false,
  },

  {
    "ThePrimeagen/harpoon",
    branch="harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
  },

  -- {
  --   "folke/flash.nvim",
  --   even = "VeryLazy",
  --   opts = {},
  -- },
}

require("lazy").setup(plugins, { default = { lazy = true } })

-- Make background black
vim.api.nvim_set_hl(0, "Normal", { bg = "#000000" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#000000" })
vim.api.nvim_set_hl(0, "LineNr", { bg = "#000000" })
vim.cmd("color abscs")

require("config.keybindings")
