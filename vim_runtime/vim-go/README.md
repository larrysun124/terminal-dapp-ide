<<<<<<< HEAD
# vim-go [![Build Status](http://img.shields.io/travis/fatih/vim-go.svg?style=flat-square)](https://travis-ci.org/fatih/vim-go)

<p align="center">
  <img style="float: right;" src="assets/vim-go.png" alt="Vim-go logo"/>
</p>

## Features

This plugin adds Go language support for Vim, with the following main features:

* Compile your package with `:GoBuild`, install it with `:GoInstall` or test it
  with `:GoTest`. Run a single test with `:GoTestFunc`).
* Quickly execute your current file(s) with `:GoRun`.
* Improved syntax highlighting and folding.
* Debug programs with integrated `delve` support with `:GoDebugStart`.
* Completion support via `gocode`.
* `gofmt` or `goimports` on save keeps the cursor position and undo history.
* Go to symbol/declaration with `:GoDef`.
* Look up documentation with `:GoDoc` or `:GoDocBrowser`.
* Easily import packages via `:GoImport`, remove them via `:GoDrop`.
* Precise type-safe renaming of identifiers with `:GoRename`.
* See which code is covered by tests with `:GoCoverage`.
* Add or remove tags on struct fields with `:GoAddTags` and `:GoRemoveTags`.
* Call `gometalinter` with `:GoMetaLinter` to invoke all possible linters
  (`golint`, `vet`, `errcheck`, `deadcode`, etc.) and put the result in the
  quickfix or location list.
* Lint your code with `:GoLint`, run your code through `:GoVet` to catch static
  errors, or make sure errors are checked with `:GoErrCheck`.
* Advanced source analysis tools utilizing `guru`, such as `:GoImplements`,
  `:GoCallees`, and `:GoReferrers`.
* ... and many more! Please see [doc/vim-go.txt](doc/vim-go.txt) for more
  information.

## Install

vim-go requires at least Vim 7.4.2009 or Neovim 0.3.1.

The [**latest stable release**](https://github.com/fatih/vim-go/releases/latest) is the
recommended version to use. If you choose to use the master branch instead,
please do so with caution; it is a _development_ branch.


vim-go follows the standard runtime path structure. Below are some helper lines
for popular package managers:

* [Vim 8 packages](http://vimhelp.appspot.com/repeat.txt.html#packages)
  * `git clone https://github.com/fatih/vim-go.git ~/.vim/pack/plugins/start/vim-go`
* [Pathogen](https://github.com/tpope/vim-pathogen)
  * `git clone https://github.com/fatih/vim-go.git ~/.vim/bundle/vim-go`
* [vim-plug](https://github.com/junegunn/vim-plug)
  * `Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }`
* [Vundle](https://github.com/VundleVim/Vundle.vim)
  * `Plugin 'fatih/vim-go'`

You will also need to install all the necessary binaries. vim-go makes it easy
to install all of them by providing a command, `:GoInstallBinaries`, which will
`go get` all the required binaries.

Check out the Install section in [the documentation](doc/vim-go.txt) for more
detailed instructions (`:help go-install`).

## Usage

The full documentation can be found at [doc/vim-go.txt](doc/vim-go.txt). You can
display it from within Vim with `:help vim-go`.

Depending on your installation method, you may have to generate the plugin's
[`help tags`](http://vimhelp.appspot.com/helphelp.txt.html#%3Ahelptags)
manually (e.g. `:helptags ALL`).

We also have an [official vim-go tutorial](https://github.com/fatih/vim-go-tutorial).

## License

The BSD 3-Clause License - see [`LICENSE`](LICENSE) for more details
=======
# vim-go

Go (golang) support for Vim, which comes with pre-defined sensible settings (like
auto gofmt on save), with autocomplete, snippet support, improved syntax
highlighting, go toolchain commands, and more.  If needed vim-go installs all
necessary binaries for providing seamless Vim integration with current
commands. It's highly customizable and each individual feature can be
disabled/enabled easily.

![vim-go](https://dl.dropboxusercontent.com/u/174404/vim-go-2.png)



## Features

* Improved Syntax highlighting with items such as Functions, Operators, Methods.
* Auto completion support via `gocode`
* Better `gofmt` on save, which keeps cursor position and doesn't break your undo
  history
* Go to symbol/declaration with `:GoDef`
* Look up documentation with `:GoDoc` inside Vim or open it in browser
* Automatically import packages via `:GoImport` or plug it into autosave
* Compile your package with `:GoBuild`, install it with `:GoInstall` or test
  them with `:GoTest` (also supports running single tests via `:GoTestFunc`)
* Quickly execute your current file/files with `:GoRun`
* Automatic `GOPATH` detection based on the directory structure (i.e. `gb`
  projects, `godep` vendored projects)
* Change or display `GOPATH` with `:GoPath`
* Create a coverage profile and display annotated source code in browser to see
  which functions are covered with `:GoCoverage`
* Call `gometalinter` with `:GoMetaLinter`, which invokes all possible linters
  (golint, vet, errcheck, deadcode, etc..) and shows the warnings/errors
* Lint your code with `:GoLint`
* Run your code through `:GoVet` to catch static errors
* Advanced source analysis tools utilizing oracle, such as `:GoImplements`,
  `:GoCallees`, and `:GoReferrers`
* Precise type-safe renaming of identifiers with `:GoRename`
* List all source files and dependencies
* Unchecked error checking with `:GoErrCheck`
* Integrated and improved snippets, supporting `ultisnips` or `neosnippet`
* Share your current code to [play.golang.org](http://play.golang.org) with `:GoPlay`
* On-the-fly type information about the word under the cursor. Plug it into
  your custom vim function.
* Go asm formatting on save
* Tagbar support to show tags of the source code in a sidebar with `gotags`
* Custom vim text objects such as `a function` or `inner function`
  list.
* A async launcher for the go command is implemented for Neovim, fully async
  building and testing (beta).
* Integrated with the Neovim terminal, launch `:GoRun` and other go commands
  in their own new terminal. (beta)
* Alternate between implementation and test code with `:GoAlternate`

## Donation

People have asked for this for a long time, now you can be a fully supporter by [being a patron](https://www.patreon.com/fatih)! This is fully optional and is just a way to support vim-go's ongoing development directly. Thanks!

[https://www.patreon.com/fatih](https://www.patreon.com/fatih)

## Install

Vim-go follows the standard runtime path structure, so I highly recommend to
use a common and well known plugin manager to install vim-go. Do not use vim-go
with other Go oriented vim plugins. For Pathogen just clone the repo. For other
plugin managers add the appropriate lines and execute the plugin's install
command.

*  [Pathogen](https://github.com/tpope/vim-pathogen)
  * `git clone https://github.com/fatih/vim-go.git ~/.vim/bundle/vim-go`
*  [vim-plug](https://github.com/junegunn/vim-plug)
  * `Plug 'fatih/vim-go'`
*  [NeoBundle](https://github.com/Shougo/neobundle.vim)
  * `NeoBundle 'fatih/vim-go'`
*  [Vundle](https://github.com/gmarik/vundle)
  * `Plugin 'fatih/vim-go'`

Please be sure all necessary binaries are installed (such as `gocode`, `godef`,
`goimports`, etc.). You can easily install them with the included
`:GoInstallBinaries` command. If invoked, all necessary binaries will be
automatically downloaded and installed to your `$GOBIN` environment (if not set
it will use `$GOPATH/bin`). Note that this command requires `git` for fetching
the individual Go packages. Additionally, use `:GoUpdateBinaries` to update the
installed binaries.

### Optional

* Autocompletion is enabled by default via `<C-x><C-o>`. To get real-time
completion (completion by type) install:
[neocomplete](https://github.com/Shougo/neocomplete.vim) for Vim or
[deoplete](https://github.com/Shougo/deoplete.nvim) and
[deoplete-go](https://github.com/zchee/deoplete-go) for NeoVim
* To display source code tag information on a sidebar install
[tagbar](https://github.com/majutsushi/tagbar).
* For snippet features install:
[neosnippet](https://github.com/Shougo/neosnippet.vim) or
[ultisnips](https://github.com/SirVer/ultisnips).
* Screenshot color scheme is a slightly modified molokai:
  [fatih/molokai](https://github.com/fatih/molokai).
* For a better documentation viewer checkout:
  [go-explorer](https://github.com/garyburd/go-explorer).

## Usage

Many of the plugin's [features](#features) are enabled by default. There are no
additional settings needed. All usages and commands are listed in
`doc/vim-go.txt`. Note that help tags needs to be populated. Check your plugin
manager settings to generate the documentation (some do it automatically).
After that just open the help page to see all commands:

    :help vim-go

## Mappings

vim-go has several `<Plug>` mappings which can be used to create custom
mappings. Below are some examples you might find useful:

Run commands such as `go run` for the current file with `<leader>r` or `go
build` and `go test` for the current package with `<leader>b` and `<leader>t`
respectively. Display beautifully annotated source code to see which functions
are covered with `<leader>c`.

```vim
au FileType go nmap <leader>r <Plug>(go-run)
au FileType go nmap <leader>b <Plug>(go-build)
au FileType go nmap <leader>t <Plug>(go-test)
au FileType go nmap <leader>c <Plug>(go-coverage)
```

By default the mapping `gd` is enabled, which opens the target identifier in
current buffer. You can also open the definition/declaration, in a new vertical,
horizontal, or tab, for the word under your cursor:

```vim
au FileType go nmap <Leader>ds <Plug>(go-def-split)
au FileType go nmap <Leader>dv <Plug>(go-def-vertical)
au FileType go nmap <Leader>dt <Plug>(go-def-tab)
```

Open the relevant Godoc for the word under the cursor with `<leader>gd` or open
it vertically with `<leader>gv`

```vim
au FileType go nmap <Leader>gd <Plug>(go-doc)
au FileType go nmap <Leader>gv <Plug>(go-doc-vertical)
```

Or open the Godoc in browser

```vim
au FileType go nmap <Leader>gb <Plug>(go-doc-browser)
```

Show a list of interfaces which is implemented by the type under your cursor
with `<leader>s`

```vim
au FileType go nmap <Leader>s <Plug>(go-implements)
```

Show type info for the word under your cursor with `<leader>i` (useful if you
have disabled auto showing type info via `g:go_auto_type_info`)

```vim
au FileType go nmap <Leader>i <Plug>(go-info)
```

Rename the identifier under the cursor to a new name

```vim
au FileType go nmap <Leader>e <Plug>(go-rename)
```

More `<Plug>` mappings can be seen with `:he go-mappings`. Also these are just
recommendations, you are free to create more advanced mappings or functions
based on `:he go-commands`.

## Settings
Below are some settings you might find useful. For the full list see `:he
go-settings`.

By default syntax-highlighting for Functions, Methods and Structs is disabled.
To change it:
```vim
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_structs = 1
let g:go_highlight_interfaces = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1
```

Enable goimports to automatically insert import paths instead of gofmt:

```vim
let g:go_fmt_command = "goimports"
```

By default vim-go shows errors for the fmt command, to disable it:

```vim
let g:go_fmt_fail_silently = 1
```

Disable auto fmt on save:

```vim
let g:go_fmt_autosave = 0
```

Disable opening browser after posting your snippet to `play.golang.org`:

```vim
let g:go_play_open_browser = 0
```

By default when `:GoInstallBinaries` is called, the binaries are installed to
`$GOBIN` or `$GOPATH/bin`. To change it:

```vim
let g:go_bin_path = expand("~/.gotools")
let g:go_bin_path = "/home/fatih/.mypath"      "or give absolute path
```

### Using with Neovim (beta)

Note: Neovim currently is not a first class citizen for vim-go. You are free
to open bugs but I'm not going to look at them. Even though I'm using Neovim
myself, Neovim itself is still alpha. So vim-go might not work well as good as
in Vim. I'm happy to accept pull requests or very detailed bug reports.


Run `:GoRun` in a new tab, horizontal split or vertical split terminal

```vim
au FileType go nmap <leader>rt <Plug>(go-run-tab)
au FileType go nmap <Leader>rs <Plug>(go-run-split)
au FileType go nmap <Leader>rv <Plug>(go-run-vertical)
```

By default new terminals are opened in a vertical split. To change it

```vim
let g:go_term_mode = "split"
```

By default the testing commands run asynchronously in the background and
display results with `go#jobcontrol#Statusline()`. To make them run in a new
terminal

```vim
let g:go_term_enabled = 1
```

### Using with Syntastic
Sometimes when using both `vim-go` and `syntastic` Vim will start lagging while
saving and opening files. The following fixes this:

```vim
let g:syntastic_go_checkers = ['golint', 'govet', 'errcheck']
let g:syntastic_mode_map = { 'mode': 'active', 'passive_filetypes': ['go'] }
```

## More info

Check out the [Wiki](https://github.com/fatih/vim-go/wiki) page for more
information. It includes
[Screencasts](https://github.com/fatih/vim-go/wiki/Screencasts), an [FAQ
section](https://github.com/fatih/vim-go/wiki/FAQ-Troubleshooting), and many
other [various pieces](https://github.com/fatih/vim-go/wiki) of information.

## Credits

* Go Authors for official vim plugins
* Gocode, Godef, Golint, Oracle, Goimports, Gotags, Errcheck projects and
  authors of those projects.
* Other vim-plugins, thanks for inspiration (vim-golang, go.vim, vim-gocode,
  vim-godef)
* [Contributors](https://github.com/fatih/vim-go/graphs/contributors) of vim-go

## License

The BSD 3-Clause License - see `LICENSE` for more details
>>>>>>> 9b6a50cb85f1e18e94ca5aace9ae9ca237de667d
