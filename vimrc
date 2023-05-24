
" -----Mappings-----"
filetype off                                                        " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
Plugin 'tpope/vim-vinegar'
Plugin 'tpope/vim-fugitive'
Plugin 'preservim/nerdtree'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'fatih/vim-go'
Plugin 'neoclide/coc.nvim'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'edkolev/tmuxline.vim'
Plugin 'ryanoasis/vim-devicons'
Plugin 'tpope/vim-commentary'
Plugin 'airblade/vim-gitgutter'
Plugin 'sakshamgupta05/vim-todo-highlight'
Plugin 'rking/ag.vim'
Plugin 'skwp/greplace.vim'
Plugin 'MarcWeber/vim-addon-mw-utils'
Plugin 'tomtom/tlib_vim'
Plugin 'garbas/vim-snipmate'
Plugin 'honza/vim-snippets'
Plugin 'tpope/vim-surround'
Plugin 'ervandew/supertab'
Plugin 'tobyS/pdv'
Plugin 'tobyS/vmustache'
Plugin 'SirVer/ultisnips'
Plugin 'hashivim/vim-terraform'
Plugin 'ayu-theme/ayu-vim'
Plugin 'sainnhe/everforest'
Plugin 'fladson/vim-kitty'
Plugin 'nvim-lua/plenary.nvim'
Plugin 'sindrets/diffview.nvim'
Plugin 'zefei/vim-wintabs'
Plugin 'zefei/vim-wintabs-powerline'
Plugin 'github/copilot.vim'
Plugin 'nvim-lua/plenary.nvim'
Plugin 'nvim-telescope/telescope.nvim'
" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

" -----Vim Related Settings-----"
set noerrorbells visualbell t_vb=             		                        "No beeps
set nocompatible              				                        "We want the latest Vim settings/options.
set backspace=indent,eol,start				                                "Make backspace behave like every other editor.
set linespace=5						                                        "Macvim-specific line-height.
set mouse=a						                                            "Enable mouse mode
set noswapfile               				                                "Don't use swapfile
set nobackup                 				                                "Don't create annoying backup files
set ignorecase               				                                "Search case insensitive...
set smartcase                				                                " ... but not it begins with upper case
set nocursorcolumn           				                                "speed up syntax highlighting
set nocursorline
set encoding=UTF-8
set tabstop=4
set autowriteall 							                                 "Automatically write the file when switching buffers.
set complete=.,w,b,u                                                          "Set our desired autocomplation mathing.
set autowrite

let mapleader = ','					                                        "The default leader is \, but comma is much better.

" By pressing ctrl+r in visual mode, you will be prompted to enter text to replace with.
" Press enter and then confirm each change you agree with y or decline with n.
vnoremap <C-r> "hy:%s/<C-r>h//gc<left><left><left>
" -----End of Vim Related Settings-----"

" -----Visual Settings-----"

set number																	"Let's activate the line numbers.
set linespace=1																"Macvim-specific line height.
set guioptions-=e															"We don't want Gui tabs
set nowrap																	"We don't want text wrapping
set colorcolumn=120															"Set a ruler to 120 characters limit

syntax enable
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
set termguicolors
let g:gruvbox_contrast_dark = "hard"                                        "might be hard,dark as well
let g:gruvbox_contrast_light = "dark"
colorscheme gruvbox

" let g:everforest_background = "hard"
" let g:everforest_better_performance = 1
" colorscheme everforest
set background=dark

"
" " reference chart of values
" " 0 -> blinking block
" " 1 -> blinking block (default)
" " 2 -> steady block
" " 3 -> blinking underline.
" " 4 -> steady underline
" " 5 -> blinking bar (xterm)
" " 6 -> steady bar (xterm)
let &t_SI = "\e[6 q"
let &t_EI = "\e[2 q" 
" ChangeBackground changes the background mode based on macOS's `Appearance`
" setting. We also refresh the statusline colors to reflect the new mode.
" this function copied from https://github.com/fatih/dotfiles/blob/main/vimrc#L124
function! ChangeBackground()
  if system("defaults read -g AppleInterfaceStyle") =~ '^Dark'
    set background=dark   " for dark version of theme
  else
    set background=light  " for light version of theme
  endif
  colorscheme gruvbox
  try
    execute "AirlineRefresh"
  catch
  endtry
endfunction

" initialize the colorscheme for the first run
" call ChangeBackground()

set t_CO=256																"Use 256 colors. This is  useful for Terminal Vim.
set guifont=Operator_Mono_Medium_Nerd_Font_Complete:h16						"Set the font with height
set guioptions-=l															"Will hide the scrollbar
set guioptions-=L															"Will hide the scrollbar
set guioptions-=r															"Will hide the scrollbar
set guioptions-=R															"Will hide the scrollbar
"Get rid of ugly split border
hi vertsplit guifg=bg guibg=bg							

"-----Split Management-----"
set splitbelow
set splitright

" -----Search-----"
set hlsearch
set incsearch

" -----Mappings-----"
" json format
nmap <Leader>jf :%!jq .<cr>

" Telescope
" Find files using Telescope command-line sugar.
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>

"Make it east to edit the Vimrc file
nmap <Leader>ev :tabedit $MYVIMRC<cr>
nmap <Leader>ep :tabedit ~/.vim/plugins.vim<cr>
nmap <Leader>es :e ~/.vim/snippets/
nmap <Leader>vdoc :e ~/.vim/README.md<cr>
" show the buffers and select with number
nnoremap <Leader>b :buffers<CR>:buffer<Space>
"copy to clipboard
vmap <Leader><Leader>c "*y<cr> 										
"Add simple highlight removal.
nmap <Leader><space> :nohlsearch<cr>
"Make NERDTree easier to toggle.
nmap <Leader>nt :NERDTreeToggle<cr>
nmap <Leader>nf :NERDTreeFind<cr> 
nmap <Leader>nr :NERDTreeRefresh<cr>
"Find a function or method inside the class easily
nmap <c-R> :CtrlPBufTag<cr>
nmap <c-E> :CtrlPMRUFile<cr>
"Theme
nmap <Leader>bl :set background=light<cr>
nmap <Leader>bd :set background=dark <cr>
"Split management
nmap <C-J> <C-W><C-J>
nmap <C-K> <C-W><C-K>
nmap <C-H> <C-W><C-H>
nmap <C-L> <C-W><C-L>

" JSON Prettifier
autocmd FileType json nmap <Leader>pj :%!python3 -m json.tool<cr>

"COC plugin
nmap <silent> gr <Plug>(coc-references)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> rn <Plug>(coc-rename)

"vim-Go
"
let g:go_test_timeout= '520s'
"Map keys for most used commands.
"Ex: `\b` for building, `\r` for running and `\b` for running test.
autocmd FileType go nmap <leader>rt  <Plug>(go-test)
autocmd FileType go nmap <Leader>gd :GoDef<cr>
autocmd FileType go nmap <Leader>gat :GoAddTags<cr>
autocmd FileType go nmap <Leader>gl :GoMetaLinter<cr>
autocmd FileType go nmap <Leader>gt :GoAlternate<cr>
autocmd FileType go nmap <Leader>gf :GoFillStruct<cr>
autocmd FileType go nmap <Leader>grr :GoRun<cr>
autocmd FileType go nmap <D-C-R> :GoTestFunc<cr>
autocmd FileType go nmap <Leader>gdb :GoDebugBreakpoint<cr>
autocmd FileType go nmap <Leader>gds :GoDebugStart<cr>
autocmd FileType go nmap <Leader>gdc :GoDebugContinue<cr>
autocmd FileType go nmap <leader>gb  <Plug>(go-build)
autocmd FileType go nmap <leader>r  <Plug>(go-run)
autocmd FileType go nmap <Leader>gc <Plug>(go-coverage-toggle)
autocmd FileType go nmap <Leader>gcc <Plug>(go-coverage-clear)
autocmd Filetype go command! -bang A call go#alternate#Switch(<bang>0, 'edit')
autocmd Filetype go command! -bang AV call go#alternate#Switch(<bang>0, 'vsplit')
autocmd Filetype go command! -bang AS call go#alternate#Switch(<bang>0, 'split')
autocmd Filetype go command! -bang AT call go#alternate#Switch(<bang>0, 'tabe')

"Golang Debugger"
" https://github.com/fatih/vim-go/blob/master/doc/vim-go.txt#L2505
let g:go_debug_windows = {
       \ 'vars':  'botright 30new',
\ }
let g:go_debug_preserve_layout = 0
let g:go_highlight_debug = 1 					" Highlight the current line and breakpoints in the debugger.

let g:go_debug_mappings = {
     \ '(go-debug-continue)':   {'key': '<F5>'},
     \ '(go-debug-print)':      {'key': '<F6>'},
     \ '(go-debug-breakpoint)': {'key': '<F9>'},
     \ '(go-debug-next)':       {'key': '<F10>'},
     \ '(go-debug-step)':       {'key': '<F11>'},
     \ '(go-debug-halt)':       {'key': '<F8>'},
\ }

"-----------------

" Print full path
map <C-f> :echo expand("%:p")<cr>

" Buffer management with shift and control with arrow keys
" map <S-Left> :bprevious<CR>
" map <S-Right> :bnext<CR>
" map <S-w> :bdelete<CR>


"----- End of Mappings -----"




"-----Plugins-----"
"/
"/ CtrlP
"/
let g:ctrlp_custom_ignore = 'node_modules\DS_Store\git\vendor\|git'
let g:ctrlp_match_window = 'top,order:ttb,min:1,max:30,results:30'
let g:ctrlp_buftag_types = {'go' : '--language-force=go --golang-types=ftv'}

"/
"/ NERDTree
"/
let NERDTreeHijacNetrw = 0
let NERDTreeShowHidden=1
let g:NERDTreeWinSize=70


"/ vim-go
"/
"/
set autowrite
"au filetype go inoremap <buffer> . .<C-x><C-o>
"Go syntax highlighting
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_extra_types = 1
let g:go_highlight_operators = 1
let g:go_highlight_types = 1

"Auto formatting and importing
let g:go_fmt_autosave = 1
let g:go_fmt_command = "goimports"

" Status line types/signatures
let g:go_auto_type_info = 1

let g:copilot_node_command = "/Users/dogukanaydogdu/.nvm/versions/node/v18.12.0/bin/node"

" Run :GoBuild or :GoTestCompile based on the go file
function! s:build_go_files()
  let l:file = expand('%')
  if l:file =~# '^\f\+_test\.go$'
    call go#test#Test(0, 1)
  elseif l:file =~# '^\f\+\.go$'
    call go#cmd#Build(0)
  endif
endfunction

" greplace
"/
"
set grepprg=ag																"We want to use Ag for the search

let g:grep_cmd_opts = '--line-numbers --noheading'

" snipmate
"/
"
let g:snipMate = { 'snippet_version' : 1 }


let g:pdv_template_dir = $HOME ."/.vim/bundle/pdv/templates_snip"

" buffer management
"
"
map <S-H> <Plug>(wintabs_previous)
map <S-L> <Plug>(wintabs_next)
map <S-W> <Plug>(wintabs_close)
map <S-T>u <Plug>(wintabs_undo)
map <S-T>o <Plug>(wintabs_only)
map <S-W>c <Plug>(wintabs_close_window)
map <S-W>o <Plug>(wintabs_only_window)
command! Tabc WintabsCloseVimtab
command! Tabo WintabsOnlyVimtab
"-----End of Plugins-----"


" -----Auto-Commands-----"
"Automatically source the Vimrc file on save
augroup autosourcing
	autocmd!
	autocmd BufWritePost .vimrc source % 
augroup END

