
-- vim.keymap.set("n", "j", "gj")
-- vim.keymap.set("n", "k", "gk")

vim.keymap.set("i", "<C-b>", "<C-o>^")
vim.keymap.set("i", "<C-e>", "<C-o>$")


vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist)
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next)


vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-d>", "<C-u>zz")
vim.keymap.set("n", "n", "nzz")
vim.keymap.set("n", "N", "Nzz")

vim.keymap.set("v", "<Up>", ":m '<-2<cr>gv=gv")
vim.keymap.set("v", "<Down>", ":m '>+1<cr>gv=gv")
vim.keymap.set("v", "<Left>", "<gv")
vim.keymap.set("v", "<Right>", "<gv")

vim.keymap.set({"n", "o"}, "<leader>j", function()
  require("leap.remote").action({ input = "gd" })
end)

local telescope = require("telescope.builtin")
local fb = require("telescope").extensions.file_browser

-- vim.keymap.set("n", "<leader>g", telescope.git_files)
vim.keymap.set("n", "<leader>g", telescope.live_grep)
vim.keymap.set("n", "<leader>o", telescope.oldfiles)
vim.keymap.set("n", "<C-f>", telescope.find_files)
vim.keymap.set("n", "<leader>F", function() telescope.find_files({ cwd = vim.fn.expand("%:h") }) end)
vim.keymap.set("n", "<leader>f", fb.file_browser)
vim.keymap.set("n", "<leader>n", function() telescope.find_files({ cwd = "/n" }) end)
vim.keymap.set("n", "<leader>h", function() fb.file_browser({ cwd = "~" }) end)
vim.keymap.set("n", "<leader>q", telescope.quickfix)
vim.keymap.set("n", "<leader>b", telescope.buffers)
vim.keymap.set("n", "<leader>t", telescope.treesitter)
vim.keymap.set("n", "<leader>f", fb.file_browser)
vim.keymap.set("n", "<C-t>", telescope.resume)
vim.keymap.set("n", "<leader>j", telescope.jumplist)

vim.keymap.set("n", "<leader>gc", telescope.git_commits)
vim.keymap.set("n", "<leader>gs", telescope.git_status)
vim.keymap.set("n", "<leader>gl", telescope.git_bcommits)
vim.keymap.set("n", "<leader>gb", telescope.git_branches)

vim.keymap.set("n", "<leader>m", MiniFiles.open);
vim.keymap.set("n", "<leader>M", function() MiniFiles.open(vim.api.nvim_buf_get_name(0)) end);
vim.keymap.set("n", "<Tab>", ":b#<CR>", { silent = true })

-- vim.keymap.set({"n", "i"}, "<C-s>", vim.cmd.write)
vim.keymap.set("t", "<C-q>", "<C-\\><C-n>", { silent = true })
vim.keymap.set("n", "<C-g>", vim.cmd.Git)

local luasnip = require("luasnip")
local cmp = require("cmp")
local select_options = { bahavior = cmp.SelectBehavior.Select }
local options = { silent = true }
-- vim.keymap.set("i", "<C-u>", cmp.mapping.scroll_docs(-4))
-- vim.keymap.set("i", "<C-d>", cmp.mapping.scroll_docs(4))
vim.keymap.set({"i", "s"}, "<C-H>", function() luasnip.jump(-1) end, options)
vim.keymap.set({"i", "s"}, "<C-L>", function() luasnip.expand_or_jump(1) end, options)
vim.keymap.set({"i", "s"}, "<C-j>", function() cmp.select_next_item(select_options) end)

vim.keymap.set({"i", "s"}, "<C-k>", function() cmp.select_prev_item(select_options) end)
vim.keymap.set({"i", "s"}, "<C-space>", cmp.mapping.confirm({ select = true }))
vim.keymap.set({"i", "s"}, "<C-c>", cmp.mapping.abort())

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omifunc"

    local options = { buffer = ev.buf }
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, options)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, options)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, options)
    vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, options)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, options)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, options)
    vim.keymap.set("n", "<C-h>", vim.lsp.buf.signature_help, options)
    vim.keymap.set("n", "<leader>ws", vim.lsp.buf.workspace_symbol, options)
    vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, options)
    vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, options)
    vim.keymap.set("n", "<leader>wl", function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, options)
    vim.keymap.set("n", "<leader>s", vim.lsp.buf.document_symbol, options)
    vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, options)
    vim.keymap.set({"n", "v"}, "<leader>ca", vim.lsp.buf.code_action, options)
    vim.keymap.set({"n", "v"}, "<leader>F", function()
      vim.lsp.buf.format{ async = true }
    end, options)
  end
})

-- local flash = require("flash")
-- vim.keymap.set("n", "<C-e>", flash.jump)
-- vim.keymap.set("n", "<leader>e", flash.treesitter)
-- vim.keymap.set("n", "<C-s>", flash.treesitter_search)

local harpoon = require("harpoon")
vim.keymap.set("n", "<C-a>", function() harpoon:list():add() end)
vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

vim.keymap.set({"n","i"}, "<A-f>", function() harpoon:list():select(1) end)
vim.keymap.set({"n","i"}, "<A-d>", function() harpoon:list():select(2) end)
vim.keymap.set({"n","i"}, "<A-s>", function() harpoon:list():select(3) end)
vim.keymap.set({"n","i"}, "<A-a>", function() harpoon:list():select(4) end)

vim.keymap.set({"n", "i"}, "<C-p>", function() harpoon:list():prev() end)
vim.keymap.set({"n", "i"}, "<C-n>", function() harpoon:list():next() end)

vim.keymap.set("n", "<C-s>", ":SessionSearch<CR>", { silent = true })
vim.keymap.set("n", "<C-S-s>", ":SessionSave<CR>", { silent = true })

vim.keymap.set({"n", "i"}, "<A-J>", "<C-W><C-J>")
vim.keymap.set({"n", "i"}, "<A-K>", "<C-W><C-K>")
vim.keymap.set({"n", "i"}, "<A-H>", "<C-W><C-H>")
vim.keymap.set({"n", "i"}, "<A-L>", "<C-W><C-L>")
