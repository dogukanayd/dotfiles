local nvim_tree_width = 30
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

function CopyDynamicRelativePathAndLineToClipboard()
  -- Get the absolute path of the current file
  local full_path = vim.fn.expand('%:p') 
  
  -- Get the current working directory or the Git root directory
  local base_path = vim.fn.systemlist('git rev-parse --show-toplevel')[1] or vim.fn.getcwd()
  
  -- Remove the base path from the full path to get the relative path
  local relative_path = full_path:gsub('^' .. vim.pesc(base_path .. '/'), '')
  
  -- Get the current line number
  local line_number = vim.fn.line('.')
  
  -- Combine the relative path with the line number
  local content = relative_path .. ':' .. line_number
  
  -- Copy the result to the clipboard
  vim.fn.setreg('+', content)
end

-- run :GoBuild or :GoTestCompile based on the go file
local function build_go_files()
  if vim.endswith(vim.api.nvim_buf_get_name(0), "_test.go") then
    vim.cmd("GoTestCompile")
  else
    vim.cmd("GoBuild")
  end
end

-- Function to adjust NvimTree width
-- @param delta: int: The amount to adjust the width by
function set_nvim_tree_width(delta)
    -- Find the NvimTree window
    local view = require("nvim-tree.view")
    if view.is_visible() then
        -- Get the current width
        local width = view.View.width + delta
        view.View.width = width  -- Update the width setting
        vim.api.nvim_win_set_width(view.get_winnr(), width)  -- Set the window width directly
    end
end

-- Function to enable resize mode
function EnterResizeMode()
    -- Remap arrow keys for resizing while in resize mode
    vim.api.nvim_set_keymap('n', '<Left>', [[:lua set_nvim_tree_width(-5)<CR>]], { noremap = true, silent = true })
    vim.api.nvim_set_keymap('n', '<Right>', [[:lua set_nvim_tree_width(5)<CR>]], { noremap = true, silent = true })

    -- Map Ctrl+n again to exit resize mode and restore original mappings
    vim.api.nvim_set_keymap('n', '<M-n>', [[:lua ExitResizeMode()<CR>]], { noremap = true, silent = true })
end

-- Function to exit resize mode
function ExitResizeMode()
    -- Restore the original arrow key functionality
    vim.api.nvim_del_keymap('n', '<Left>')
    vim.api.nvim_del_keymap('n', '<Right>')

    -- Rebind Ctrl+n to re-enter resize mode
    vim.api.nvim_set_keymap('n', '<M-n>', [[:lua EnterResizeMode()<CR>]], { noremap = true, silent = true })
end

----------------
--- plugins ---
----------------
require("lazy").setup({
  {
    "chrisbra/csv.vim",
  },
  {
    -- Debug Adapter Protocol client implementation
    "mfussenegger/nvim-dap",
    dependencies = {
      -- Go extension for nvim-dap
      "leoluz/nvim-dap-go",
      -- UI for nvim-dap with required dependency
      {
        "rcarriga/nvim-dap-ui",
        dependencies = {
          "nvim-neotest/nvim-nio",
        },
      },
    },
    config = function()
      -- Load the dap-go extension
      require("dap-go").setup()

      -- Load the dap-ui extension
      require("dapui").setup()

      -- Explicit setup for Go adapter
      local dap = require("dap")
      local dapui = require("dapui")

      -- Configure the Go adapter for Delve
      dap.adapters.go = function(callback, config)
        callback({
          type = "server",
          host = "127.0.0.1",
          port = 38697, -- Default Delve port
        })
      end

      -- Define configurations for Go
      dap.configurations.go = {
        {
          type = "go",
          name = "Launch File",
          request = "launch",
          program = "${file}", -- Debug the current file
        },
        {
          type = "go",
          name = "Debug Package",
          request = "launch",
          program = "${fileDirname}", -- Debug the package
        },
        {
          type = "go",
          name = "Attach to Process",
          request = "attach",
          processId = require("dap.utils").pick_process,
        },
      }

      -- Open dap-ui automatically when debugging starts
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      -- Define key mappings for debugging
      vim.api.nvim_set_keymap("n", "<F5>", "<Cmd>lua require'dap'.continue()<CR>", { noremap = true, silent = true })
      vim.api.nvim_set_keymap("n", "<F10>", "<Cmd>lua require'dap'.step_over()<CR>", { noremap = true, silent = true })
      vim.api.nvim_set_keymap("n", "<F11>", "<Cmd>lua require'dap'.step_into()<CR>", { noremap = true, silent = true })
      vim.api.nvim_set_keymap("n", "<F12>", "<Cmd>lua require'dap'.step_out()<CR>", { noremap = true, silent = true })
      vim.api.nvim_set_keymap("n", "<F2>", "<Cmd>lua require'dap'.toggle_breakpoint()<CR>", { noremap = true, silent = true })
      vim.api.nvim_set_keymap("n", "<Leader>dt", "<Cmd>lua require'dap-go'.debug_test()<CR>", { noremap = true, silent = true })
      vim.api.nvim_set_keymap("n", "<Leader>du", "<Cmd>lua require'dapui'.toggle()<CR>", { noremap = true, silent = true })

      -- Set up breakpoint sign
      vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DapBreakpoint", linehl = "", numhl = "" })
    end,
  },
  {
    'romgrk/barbar.nvim',
    dependencies = {
      'lewis6991/gitsigns.nvim', -- OPTIONAL: for git status
      'nvim-tree/nvim-web-devicons', -- OPTIONAL: for file icons
    },
    init = function() vim.g.barbar_auto_setup = false end,
    config = function()
      require('barbar').setup({
        animation = true,
        auto_hide = false,
        tabpages = true,
        clickable = true,
      })

      -- Keymaps
      local map = vim.keymap.set
      local opts = { noremap = true, silent = true, desc = "barbar keymap" }

      map('n', '<A-,>', '<Cmd>BufferPrevious<CR>', opts)
      map('n', '<A-.>', '<Cmd>BufferNext<CR>', opts)
      map('n', '<A-<>', '<Cmd>BufferMovePrevious<CR>', opts)
      map('n', '<A->>', '<Cmd>BufferMoveNext<CR>', opts)
      map('n', '<A-c>', '<Cmd>BufferClose<CR>', opts)
      map('n', '<A-p>', '<Cmd>BufferPick<CR>', opts)

      for i = 1, 9 do
        map('n', '<A-' .. i .. '>', '<Cmd>BufferGoto ' .. i .. '<CR>', opts)
      end
      map('n', '<A-0>', '<Cmd>BufferLast<CR>', opts)
    end,
  },

  {
    'airblade/vim-gitgutter',
    -- also show the line numbers in the sign column
  },
  {
    'jvirtanen/vim-hcl'
  },
  {
    -- PERF: fully optimised
    -- HACK: hmm, this looks a bit funky
    -- TODO: what else?
    -- NOTE: adding a note
    -- FIX: this needs fixing
    -- WARNING: ???
    --
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      keywords = {
        DNOTE = { icon = " ", color = "hint" },
      },
    }
  },
  -- colorscheme
  {
    'sainnhe/gruvbox-material',
    config = function ()
      vim.g.gruvbox_material_background = 'hard'
      vim.cmd([[colorscheme gruvbox-material]])
    end,
  },

  -- statusline
  { 
    "nvim-lualine/lualine.nvim",
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function ()
      require("lualine").setup({
        options = { theme = 'gruvbox' },
        sections = {
          lualine_c = {
            {
              'filename',
              file_status = true, -- displays file status (readonly status, modified status)
              path = 2 -- 0 = just filename, 1 = relative path, 2 = absolute path
            }
          }
        }
      })
    end,
  },

  -- terraform formatter
  {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("conform").setup({
        formatters = {
          hcledit = {
            command = "hcledit",
            args = { "fmt", "-f", "terragrunt.hcl", "--update" },
            stdin = true,
          },
        },
        formatters_by_ft = {
          hcl = { "hcledit" },
        },
        format_on_save = {
          lsp_fallback = true,
          async = false,
          timeout_ms = 500,
        },
      })
    end,
  },

  -- you know the drill
  {
    "fatih/vim-go",
    config = function ()
      -- we disable most of these features because treesitter and nvim-lsp
      -- take care of it
      vim.g['go_gopls_enabled'] = 0
      vim.g['go_code_completion_enabled'] = 0
      vim.g['go_fmt_autosave'] = 0
      vim.g['go_imports_autosave'] = 0
      vim.g['go_mod_fmt_autosave'] = 0
      vim.g['go_doc_keywordprg_enabled'] = 0
      vim.g['go_def_mapping_enabled'] = 0
      vim.g['go_textobj_enabled'] = 0
      vim.g['go_list_type'] = 'quickfix'
    end,
  },

  -- search selection via *
  { 'bronson/vim-visual-star-search' },

  -- testing framework
  { 
    "vim-test/vim-test",
    config = function ()
      vim.g['test#strategy'] = 'neovim'
      vim.g['test#neovim#start_normal'] = '1'
      vim.g['test#neovim#term_position'] = 'vert'
    end,
  },

  {
    'dinhhuy258/git.nvim',
    config = function ()
      require("git").setup()
    end,
  },


  -- file explorer
  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require("nvim-tree").setup({
        sort_by = "case_sensitive",
        filters = {
          dotfiles = false,
        },
        on_attach = function(bufnr)
          local api = require('nvim-tree.api')

          local function opts(desc)
            return {
              desc = 'nvim-tree: ' .. desc,
              buffer = bufnr,
              noremap = true,
              silent = true,
              nowait = true,
            }
          end

          api.config.mappings.default_on_attach(bufnr)

          vim.keymap.set('n', 's', api.node.open.vertical, opts('Open: Vertical Split'))
          vim.keymap.set('n', 'i', api.node.open.horizontal, opts('Open: Horizontal Split'))
          vim.keymap.set('n', 'u', api.tree.change_root_to_parent, opts('Up'))
        end
      })
    end,
  },

  -- save my last cursor position
  {
    "ethanholz/nvim-lastplace",
    config = function()
      require("nvim-lastplace").setup({
        lastplace_ignore_buftype = {"quickfix", "nofile", "help"},
        lastplace_ignore_filetype = {"gitcommit", "gitrebase", "svn", "hgcommit"},
        lastplace_open_folds = true
      })
    end,
  },

  -- copilot
  {
    'github/copilot.vim',
    config = function()
      -- Disable Copilot’s default Tab mapping
      vim.g.copilot_no_tab_map = true

      -- Set custom key mapping to accept Copilot suggestion
      vim.api.nvim_set_keymap("i", "<C-l>", 'copilot#Accept("<CR>")', { expr = true, silent = true })
    end,
  },

  -- markdown
  {
    "iamcco/markdown-preview.nvim",
    run = "cd app && yarn install",
    setup = function() vim.g.mkdp_auto_start = 1 end,
  },

  -- commenting out lines
  {
    "numToStr/Comment.nvim",
    config = function()
      require('Comment').setup({
        opleader = {
          ---Block-comment keymap
          block = '<Nop>',
        },
      }) 
    end
  },

  { 
    "AndrewRadev/splitjoin.vim"
  },

  -- fzf extension for telescope with better speed
  {
    "nvim-telescope/telescope-fzf-native.nvim", run = 'make' 
  },

  {'nvim-telescope/telescope-ui-select.nvim' },

  -- fuzzy finder framework
  {
    "nvim-telescope/telescope.nvim", 
    tag = '0.1.4',
    dependencies = { 
      "nvim-lua/plenary.nvim" ,
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    config = function ()
      local make_entry = require('telescope.make_entry')

      require("telescope").setup({
        defaults = {
          wrap_results = true,
          layout_strategy = 'horizontal',
          path_display = {'absolute'},
          layout_config = {
            horizontal = {
              preview_width = 0.6,
            },
            width = 0.9,
          },
          entry_maker = function(entry)
            local display = entry.filename
            return make_entry.set_default_entry_mt({
              value = entry,
              display = display,
              ordinal = display,
              filename = entry.filename,
            })
          end,
        },
        extensions = {
          fzf = {
            fuzzy = true,                    -- false will only do exact matching
            override_generic_sorter = true,  -- override the generic sorter
            override_file_sorter = true,     -- override the file sorter
            case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
                                             -- the default case_mode is "smart_case"
          }
        }
      })

      -- To get fzf loaded and working with telescope, you need to call
      -- load_extension, somewhere after setup function:
      require('telescope').load_extension('fzf')

      -- To get ui-select loaded and working with telescope, you need to call
      -- load_extension, somewhere after setup function:
      require("telescope").load_extension("ui-select")
    end,
  },

  -- lsp-config
  {
    "neovim/nvim-lspconfig", 
    config = function ()
      util = require "lspconfig/util"

      local capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
      capabilities.textDocument.completion.completionItem.snippetSupport = true

      require'lspconfig'.terraform_lsp.setup{}
      require'lspconfig'.intelephense.setup{}
      require'lspconfig'.ts_ls.setup{}
      require'lspconfig'.yamlls.setup{}
      require("lspconfig").gopls.setup({
        capabilities = capabilities,
        flags = { debounce_text_changes = 200 },
        settings = {
          gopls = {
            usePlaceholders = true,
            gofumpt = true,
            analyses = {
              nilness = true,
              unusedparams = true,
              unusedwrite = true,
              useany = true,
            },
            codelenses = {
              gc_details = false,
              generate = true,
              regenerate_cgo = true,
              run_govulncheck = true,
              test = true,
              tidy = true,
              upgrade_dependency = true,
              vendor = true,
            },
            experimentalPostfixCompletions = true,
            completeUnimported = true,
            staticcheck = true,
            directoryFilters = { "-.git", "-node_modules" },
            semanticTokens = false,
            hints = {
              assignVariableTypes = true,
              compositeLiteralFields = true,
              compositeLiteralTypes = true,
              constantValues = true,
              functionTypeParameters = true,
              parameterNames = true,
              rangeVariableTypes = true,
            },
          },
        },
      })
    end,
  },

  -- Alternate between files, such as foo.go and foo_test.go
  {
    "rgroli/other.nvim",
    config = function ()
      require("other-nvim").setup({
        mappings = {
          "rails", --builtin mapping
	        {
	        	pattern = "(.*).go$",
	        	target = "%1_test.go",
            context = "test",
	        },
	        {
	        	pattern = "(.*)_test.go$",
	        	target = "%1.go",
            context = "file",
	        },
	      },
      })

      vim.api.nvim_create_user_command('A',   function(opts)
        require('other-nvim').open(opts.fargs[1])
      end, {nargs = '*'})

      vim.api.nvim_create_user_command('AV',   function(opts)
        require('other-nvim').openVSplit(opts.fargs[1])
      end, {nargs = '*'})

      vim.api.nvim_create_user_command('AS',   function(opts)
        require('other-nvim').openSplit(opts.fargs[1])
      end, {nargs = '*'})
    end,
  },

  -- Highlight, edit, and navigate code
  { 
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ":TSUpdate",
    config = function()
      require('nvim-treesitter.configs').setup({
        ensure_installed = {
          'bash',
          'fish',
          'go',
          'gomod',
          'json',
          'lua',
          'markdown',
          'markdown_inline',
          'mermaid',
          'proto',
          'ruby',
          'vim',
          'vimdoc',
          'php',
          'javascript',
          'terraform'
        },
        indent = { enable = true },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<space>", -- maps in normal mode to init the node/scope selection with space
            node_incremental = "<space>", -- increment to the upper named parent
            node_decremental = "<bs>", -- decrement to the previous node
            scope_incremental = "<tab>", -- increment to the upper scope (as defined in locals.scm)
          },
        },
        autopairs = {
          enable = true,
        },
        textobjects = {
          select = {
            enable = true,
            lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
            keymaps = {
              -- You can use the capture groups defined in textobjects.scm
              ['aa'] = '@parameter.outer',
              ['ia'] = '@parameter.inner',
              ['af'] = '@function.outer',
              ['if'] = '@function.inner',
              ['ac'] = '@class.outer',
              ['ic'] = '@class.inner',
              ["iB"] = "@block.inner",
              ["aB"] = "@block.outer",
            },
          },
          move = {
            enable = true,
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = {
              [']]'] = '@function.outer',
            },
            goto_next_end = {
              [']['] = '@function.outer',
            },
            goto_previous_start = {
              ['[['] = '@function.outer',
            },
            goto_previous_end = {
              ['[]'] = '@function.outer',
            },
          },
          swap = {
            enable = true,
            swap_next = {
              ['<leader>sn'] = '@parameter.inner',
            },
            swap_previous = {
              ['<leader>sp'] = '@parameter.inner',
            },
          },
        },
        highlight = {
          enable = true,

          -- Disable slow treesitter highlight for large files
          disable = function(lang, buf)
            local max_filesize = 100 * 1024 -- 100 KB
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_filesize then
              return true
            end
          end,

          -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
          -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
          -- Using this option may slow down your editor, and you may see some duplicate highlights.
          -- Instead of true it can also be a list of languages
          additional_vim_regex_highlighting = false,
        },
      })
    end,
  },


  {
    "windwp/nvim-autopairs",
    config = function() 
      require("nvim-autopairs").setup {
        check_ts = true,
      }
    end
  },

  {
    "L3MON4D3/LuaSnip",
    dependencies = { "rafamadriz/friendly-snippets" },
    config = function() 
      require("luasnip.loaders.from_vscode").lazy_load()
    end
  },

  -- autocompletion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "onsails/lspkind-nvim",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      local lspkind = require("lspkind")
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")

      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

      luasnip.config.setup {}

      local has_words_before = function()
        unpack = unpack or table.unpack
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end

      require('cmp').setup({
        snippet = {
            expand = function(args)
              luasnip.lsp_expand(args.body)
            end,
        },
        formatting = {
          format = lspkind.cmp_format {
            with_text = true,
            menu = {
              buffer = "[Buffer]",
              nvim_lsp = "[LSP]",
              nvim_lua = "[Lua]",
            },
          },
        },
        mapping = cmp.mapping.preset.insert {
          ['<C-n>'] = cmp.mapping.select_next_item(),
          ['<C-p>'] = cmp.mapping.select_prev_item(),
          ['<C-d>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<CR>'] = cmp.mapping.confirm { select = true },
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_locally_jumpable() then 
              luasnip.expand_or_jump()
            elseif has_words_before() then
              cmp.complete()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
        },
        -- don't auto select item
        preselect = cmp.PreselectMode.None,
        window = {
          documentation = cmp.config.window.bordered(),
        },
        view = {
          entries = {
            name = "custom",
            selection_order = "near_cursor",
          },
        },
        confirm_opts = {
          behavior = cmp.ConfirmBehavior.Insert,
        },
        sources = {
          { name = 'nvim_lsp' },
          { name = "luasnip", keyword_length = 2},
          { name = "buffer", keyword_length = 5},
        },
      })
    end,
  },
})

----------------
--- SETTINGS ---
----------------

-- disable netrw at the very start of our init.lua, because we use nvim-tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1


vim.opt.termguicolors = true -- Enable 24-bit RGB colors

vim.opt.number = true        -- Show line numbers
vim.opt.showmatch = true     -- Highlight matching parenthesis
vim.opt.splitright = true    -- Split windows right to the current windows
vim.opt.splitbelow = true    -- Split windows below to the current windows
vim.opt.autowrite = true     -- Automatically save before :next, :make etc.
vim.opt.autochdir = true     -- Change CWD when I open a file

vim.opt.mouse = 'a'                -- Enable mouse support
vim.opt.clipboard = 'unnamedplus'  -- Copy/paste to system clipboard
vim.opt.swapfile = false           -- Don't use swapfile
vim.opt.ignorecase = true          -- Search case insensitive...
vim.opt.smartcase = true           -- ... but not it begins with upper case 
vim.opt.completeopt = 'menuone,noinsert,noselect'  -- Autocomplete options

vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath("data") .. "undo"

-- Indent Settings
-- I'm in the Spaces camp (sorry Tabs folks), so I'm using a combination of
-- settings to insert spaces all the time. 
vim.opt.expandtab = true  -- expand tabs into spaces
vim.opt.shiftwidth = 2    -- number of spaces to use for each step of indent.
vim.opt.tabstop = 2       -- number of spaces a TAB counts for
vim.opt.autoindent = true -- copy indent from current line when starting a new line
vim.opt.wrap = true

vim.opt.ruler = true
vim.opt.colorcolumn = "120"  -- Replace 120 with your preferred column number

-- This comes first, because we have mappings that depend on leader
-- With a map leader it's possible to do extra key combinations
-- i.e: <leader>w saves the current file
vim.g.mapleader = ','


-- Fast saving
vim.keymap.set('n', '<Leader>w', ':write!<CR>')
vim.keymap.set('n', '<Leader>q', ':q!<CR>', { silent = true })

-- Some useful quickfix shortcuts for quickfix
vim.keymap.set('n', '<C-n>', '<cmd>cnext<CR>zz')
vim.keymap.set('n', '<C-m>', '<cmd>cprev<CR>zz')
vim.keymap.set('n', '<leader>a', '<cmd>cclose<CR>')

-- Exit on jj and jk
vim.keymap.set('n', 'j', 'gj')
vim.keymap.set('n', 'k', 'gk')

-- Exit on jj and jk
vim.keymap.set('i', 'jj', '<ESC>')
vim.keymap.set('i', 'jk', '<ESC>')

-- Remove search highlight
vim.keymap.set('n', '<Leader><space>', ':nohlsearch<CR>')

-- Search mappings: These will make it so that going to the next one in a
-- search will center on the line it's found in.
vim.keymap.set('n', 'n', 'nzzzv', {noremap = true})
vim.keymap.set('n', 'N', 'Nzzzv', {noremap = true})

-- Don't jump forward if I higlight and search for a word
local function stay_star()
  local sview = vim.fn.winsaveview()
  local args = string.format("keepjumps keeppatterns execute %q", "sil normal! *")
  vim.api.nvim_command(args)
  vim.fn.winrestview(sview)
end
vim.keymap.set('n', '*', stay_star, {noremap = true, silent = true})

-- We don't need this keymap, but here we are. If I do a ctrl-v and select
-- lines vertically, insert stuff, they get lost for all lines if we use
-- ctrl-c, but not if we use ESC. So just let's assume Ctrl-c is ESC.
vim.keymap.set('i', '<C-c>', '<ESC>')

-- If I visually select words and paste from clipboard, don't replace my
-- clipboard with the selected word, instead keep my old word in the
-- clipboard
vim.keymap.set("x", "p", "\"_dP")

-- rename the word under the cursor 
vim.keymap.set("n", "<leader>rw", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- Better split switching
vim.keymap.set('', '<C-j>', '<C-W>j')
vim.keymap.set('', '<C-k>', '<C-W>k')
vim.keymap.set('', '<C-h>', '<C-W>h')
vim.keymap.set('', '<C-l>', '<C-W>l')

-- Visual linewise up and down by default (and use gj gk to go quicker)
vim.keymap.set('n', '<Up>', 'gk')
vim.keymap.set('n', '<Down>', 'gj')

-- Yanking a line should act like D and C
vim.keymap.set('n', 'Y', 'y$')

-- Terminal
-- Clost terminal window, even if we are in insert mode
vim.keymap.set('t', '<leader>q', '<C-\\><C-n>:q<cr>')

-- switch to normal mode with esc
vim.keymap.set('t', '<ESC>', '<C-\\><C-n>')

-- Open terminal in vertical and horizontal split
vim.keymap.set('n', '<leader>tv', '<cmd>vnew term://zsh<CR>', { noremap = true })
vim.keymap.set('n', '<leader>ts', '<cmd>split term://zsh<CR>', { noremap = true })

-- Open terminal in vertical and horizontal split, inside the terminal
vim.keymap.set('t', '<leader>tv', '<c-w><cmd>vnew term://zsh<CR>', { noremap = true })
vim.keymap.set('t', '<leader>ts', '<c-w><cmd>split term://zsh<CR>', { noremap = true })

-- mappings to move out from terminal to other views
vim.keymap.set('t', '<C-h>', '<C-\\><C-n><C-w>h')
vim.keymap.set('t', '<C-j>', '<C-\\><C-n><C-w>j')
vim.keymap.set('t', '<C-k>', '<C-\\><C-n><C-w>k')
vim.keymap.set('t', '<C-l>', '<C-\\><C-n><C-w>l')

-- we don't use netrw (because of nvim-tree), hence re-implement gx to open
-- links in browser
vim.keymap.set("n", "gx", '<Cmd>call jobstart(["open", expand("<cfile>")], {"detach": v:true})<CR>')

-- automatically switch to insert mode when entering a Term buffer
vim.api.nvim_create_autocmd({ "WinEnter", "BufWinEnter", "TermOpen" }, {
    group = vim.api.nvim_create_augroup("openTermInsert", {}),
    callback = function(args)
        -- we don't use vim.startswith() and look for test:// because of vim-test
        -- vim-test starts tests in a terminal, which we want to keep in normal mode
        if vim.endswith(vim.api.nvim_buf_get_name(args.buf), "fish") then
            vim.cmd("startinsert")
        end
    end,
})

-- Create an augroup to manage the autocommand
vim.api.nvim_create_augroup('TerraformFmt', { clear = true })

-- Define the autocommand
vim.api.nvim_create_autocmd('BufWritePost', {
  group = 'TerraformFmt',
  pattern = '*.hcl',
  callback = function()
    -- Save the current buffer before formatting
    vim.cmd('write')
    -- Execute 'terraform fmt' on the current file
    vim.fn.system('hcledit fmt -f terragrunt.hcl --update' .. vim.fn.shellescape(vim.fn.expand('%:p')))
    -- Reload the buffer to reflect the formatted changes
    vim.cmd('edit!')
  end,
})

-- Open help window in a vertical split to the right.
vim.api.nvim_create_autocmd("BufWinEnter", {
    group = vim.api.nvim_create_augroup("help_window_right", {}),
    pattern = { "*.txt" },
    callback = function()
        if vim.o.filetype == 'help' then vim.cmd.wincmd("L") end
    end
})

-- don't show number
vim.api.nvim_create_autocmd("TermOpen", {
    command = [[setlocal nonumber norelativenumber]]
})

-- copy the file path and the line number
vim.api.nvim_set_keymap('n', '<leader>ca', [[:lua CopyDynamicRelativePathAndLineToClipboard()<CR>]], { noremap = true, silent = true })

-- git.nvim
vim.keymap.set('n', '<leader>gb', '<CMD>lua require("git.blame").blame()<CR>')
vim.keymap.set('n', '<leader>go', "<CMD>lua require('git.browse').open(false)<CR>")
vim.keymap.set('x', '<leader>go', ":<C-u> lua require('git.browse').open(true)<CR>")

-- old habits 
vim.api.nvim_create_user_command("GBrowse", 'lua require("git.browse").open(true)<CR>', {
  range = true,
  bang = true,
  nargs = "*",
})

-- File-tree mappings
vim.keymap.set('n', '<leader>n', ':NvimTreeToggle<CR>', { noremap = true })
vim.keymap.set('n', '<leader>f', ':NvimTreeFindFile!<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<M-n>', [[:lua EnterResizeMode()<CR>]], { noremap = true, silent = true })

-- vim-test
vim.keymap.set('n', '<leader>tt', ':TestNearest -v<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>tf', ':TestFile -v<CR>', { noremap = true, silent = true })


-- telescope
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<C-p>', builtin.git_files, {})
vim.keymap.set('n', '<C-b>', builtin.find_files, {})
vim.keymap.set('n', '<C-g>', builtin.lsp_document_symbols, {})
vim.keymap.set('n', '<leader>td', builtin.diagnostics, {})
vim.keymap.set('n', '<leader>gs', builtin.grep_string, {})
vim.keymap.set('n', '<leader>gg', builtin.live_grep, {})
-- vim.keymap.set('n', '<leader>gg', function()
--   require('telescope.builtin').live_grep {
--     cwd = vim.fn.expand('%:p:h')  -- Sets the current file's directory as the root
--   }
-- end, {})

-- diagnostics
vim.keymap.set('n', '<leader>do', vim.diagnostic.open_float)
vim.keymap.set('n', '<leader>dp', vim.diagnostic.goto_prev)
vim.keymap.set('n', '<leader>dn', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>ds', vim.diagnostic.setqflist)

-- vim-go
vim.keymap.set('n', '<leader>b', build_go_files)

vim.api.nvim_set_keymap('n', '<leader>cp', [[:let @+=fnamemodify(expand('%'), ':~:.')<CR>]], { noremap = true, silent = true })


-- disable diagnostics, I didn't like them
-- vim.lsp.handlers["textDocument/publishDiagnostics"] = function() end

-- Go uses gofmt, which uses tabs for indentation and spaces for aligment.
-- Hence override our indentation rules.
vim.api.nvim_create_autocmd('Filetype', {
  group = vim.api.nvim_create_augroup('setIndent', { clear = true }),
  pattern = { 'go' },
  command = 'setlocal noexpandtab tabstop=4 shiftwidth=4'
})

-- Run gofmt/gofmpt, import packages automatically on save
vim.api.nvim_create_autocmd('BufWritePre', {
  group = vim.api.nvim_create_augroup('setGoFormatting', { clear = true }),
  pattern = '*.go',
  callback = function()
    local params = vim.lsp.util.make_range_params()
    params.context = { only = { "source.organizeImports" } }
    local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 2000)
    for _, res in pairs(result or {}) do
      for _, r in pairs(res.result or {}) do
        if r.edit then
          vim.lsp.util.apply_workspace_edit(r.edit, "utf-16")
        else
          vim.lsp.buf.execute_command(r.command)
        end
      end
    end
  
    vim.lsp.buf.format()
  end
})

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { buffer = ev.buf }

    vim.keymap.set('n', 'gd', "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
    vim.keymap.set('n', '<leader>v', "<cmd>vsplit | lua vim.lsp.buf.definition()<CR>", opts)
    vim.keymap.set('n', '<leader>s', "<cmd>belowright split | lua vim.lsp.buf.definition()<CR>", opts)

    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', '<leader>cl', vim.lsp.codelens.run, opts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
    -- vim.keymap.set({'n', 'v'}, '<leader>ca', vim.lsp.buf.code_action, opts)
  end,
})

-- automatically resize all vim buffers if I resize the terminal window
vim.api.nvim_command('autocmd VimResized * wincmd =')

-- https://github.com/neovim/neovim/issues/21771
local exitgroup = vim.api.nvim_create_augroup('setDir', { clear = true })
vim.api.nvim_create_autocmd('DirChanged', {
  group = exitgroup,
  pattern = { '*' },
  command = [[call chansend(v:stderr, printf("\033]7;file://%s\033\\", v:event.cwd))]],
})

vim.api.nvim_create_autocmd('VimLeave', {
  group = exitgroup,
  pattern = { '*' },
  command = [[call chansend(v:stderr, "\033]7;\033\\")]],
})


-- put quickfix window always to the bottom
local qfgroup = vim.api.nvim_create_augroup('changeQuickfix', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'qf',
  group = qfgroup,
  command = 'wincmd J',
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'qf',
  group = qfgroup,
  command = 'setlocal wrap',
})

-- add a newline at the end of the file
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function()
    local last_line = vim.api.nvim_buf_get_lines(0, -2, -1, false)[1]
    if last_line ~= "" then
      vim.api.nvim_buf_set_lines(0, -1, -1, false, {""})
    end
  end,
})


-- markdown
vim.g.mkdp_auto_start = 1  -- Automatically open preview
vim.g.mkdp_auto_close = 1  -- Automatically close preview when switching buffers
vim.g.mkdp_browser = 'firefox'  -- or 'chrome', depending on your browser
vim.g.mkdp_echo_preview_url = 1

