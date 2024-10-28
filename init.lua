local telescopeBuiltin
local harpoon

-- Leader Key
vim.g.mapleader = ","

-- Packer Setup
require('packer').startup(function(use)
    use 'wbthomason/packer.nvim'

    -- Telescope
    use {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.8',
        requires = { {'nvim-lua/plenary.nvim'} },
        config = function()
            telescopeBuiltin = require('telescope.builtin')
            vim.keymap.set('n', '<leader>pf', telescopeBuiltin.find_files, {})
            vim.keymap.set('n', '<C-p>', telescopeBuiltin.git_files, {})
            vim.keymap.set('n', '<leader>ps', function()
                telescopeBuiltin.grep_string({ search = vim.fn.input("Grep > ") })
            end)
        end,
    }
    -- Nvim-Tree
    use {
        "nvim-tree/nvim-tree.lua",
        requires = { 'nvim-tree/nvim-web-devicons' },
        config = function()
            require("nvim-tree").setup({
                sort_by = "case_sensitive",
                filters = {
                    dotfiles = true,
                },
            })
        end,
    }
    -- Harpoon
    use {
        'ThePrimeagen/harpoon',
        branch = 'harpoon2',
        requires = { {'nvim-lua/plenary.nvim'} },
        config = function()
            harpoon = require('harpoon')
            harpoon.setup()

            vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end)
            vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

            -- Toggle previous & next buffers stored within Harpoon list
            vim.keymap.set("n", "<C-S-P>", function() harpoon:list():prev() end)
            vim.keymap.set("n", "<C-S-N>", function() harpoon:list():next() end)
        end
    }

    -- Gruvbox theme
    use { "ellisonleao/gruvbox.nvim" }

    -- Treesitter
    use {
        'nvim-treesitter/nvim-treesitter',
        run = ':TSUpdate',
        config = function()
            require'nvim-treesitter.configs'.setup {
                ensure_installed = { "c", "lua", "vim", "vimdoc", "markdown", "markdown_inline", "php", "go", "javascript", "terraform" },
                sync_install = false,
                auto_install = true,
                highlight = { enable = true, additional_vim_regex_highlighting = false },
            }
        end
    }

    use 'nvim-treesitter/playground'
    use 'mbbill/undotree'
    use 'tpope/vim-fugitive'

    -- Vim-Go
    use {
        "fatih/vim-go",
        config = function()
            vim.g.go_gopls_enabled = 0
            vim.g.go_code_completion_enabled = 0
            vim.g.go_fmt_autosave = 0
            vim.g.go_imports_autosave = 0
            vim.g.go_mod_fmt_autosave = 0
            vim.g.go_doc_keywordprg_enabled = 0
            vim.g.go_def_mapping_enabled = 0
            vim.g.go_textobj_enabled = 0
            vim.g.go_list_type = 'quickfix'
        end,
    }

    -- Mason and LSP configurations
    use { "williamboman/mason.nvim", config = function() require("mason").setup() end }
    use('neovim/nvim-lspconfig')
    use('hrsh7th/nvim-cmp')
    use('hrsh7th/cmp-nvim-lsp')

    -- LSP setup
    local lspconfig_defaults = require('lspconfig').util.default_config
    lspconfig_defaults.capabilities = vim.tbl_deep_extend(
        'force',
        lspconfig_defaults.capabilities,
        require('cmp_nvim_lsp').default_capabilities()
    )

    require'lspconfig'.gopls.setup{ flags = {debounce_text_changes = 200} }
    require'lspconfig'.terraform_lsp.setup{}
    require'lspconfig'.intelephense.setup{}

    -- Completion
    local cmp = require('cmp')
    cmp.setup({
        sources = { {name = 'nvim_lsp'} },
        snippet = { expand = function(args) vim.fn["vsnip#anonymous"](args.body) end },
        mapping = cmp.mapping.preset.insert({}),
    })
end)

-- UI Settings
vim.opt.signcolumn = 'yes'
vim.opt.guicursor = ""
vim.opt.backup = false
vim.opt.colorcolumn = "120"
vim.opt.expandtab = true
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.isfname:append("@-@")
vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.scrolloff = 8
vim.opt.shiftwidth = 4
vim.opt.signcolumn = "yes"
vim.opt.smartindent = true
vim.opt.softtabstop = 4
vim.opt.swapfile = false
vim.opt.tabstop = 4
vim.opt.termguicolors = true
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true
vim.opt.updatetime = 50
vim.opt.wrap = false

-- Colorscheme
vim.cmd([[colorscheme gruvbox]])

-- Additional Key Mappings
vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle)
vim.keymap.set('n', '<leader>gs', vim.cmd.Git)
-- Better split switching
vim.keymap.set('', '<C-j>', '<C-W>j')
vim.keymap.set('', '<C-k>', '<C-W>k')
vim.keymap.set('', '<C-h>', '<C-W>h')
vim.keymap.set('', '<C-l>', '<C-W>l')

-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- optionally enable 24-bit colour
vim.opt.termguicolors = true

vim.keymap.set('n', '<leader>n', ':NvimTreeToggle<CR>', { noremap = true })
vim.keymap.set('n', '<leader>f', ':NvimTreeFindFile!<CR>', { noremap = true })
-- LSP-Specific Key Mappings
vim.api.nvim_create_autocmd('LspAttach', {
    desc = 'LSP actions',
    callback = function(event)
        local opts = {buffer = event.buf}
        vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
        vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
        vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
        vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
        vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
        vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
        vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
        vim.keymap.set('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
        vim.keymap.set({'n', 'x'}, '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
        vim.keymap.set('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
    end,
})

