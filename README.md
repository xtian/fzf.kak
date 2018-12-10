# fzf.kak

[![GitHub release](https://img.shields.io/github/release/andreyorst/fzf.kak.svg)](https://github.com/andreyorst/fzf.kak/releases)
[![GitHub Release Date](https://img.shields.io/github/release-date/andreyorst/fzf.kak.svg)](https://github.com/andreyorst/fzf.kak/releases)
![Github commits (since latest release)](https://img.shields.io/github/commits-since/andreyorst/fzf.kak/latest.svg)
![license](https://img.shields.io/github/license/andreyorst/fzf.kak.svg)

**fzf.kak** is a plugin for [Kakoune](https://github.com/mawww/kakoune) editor, that brings integration with [fzf](https://github.com/junegunn/fzf)
tool. This plugin is being tested against Kakoune 2018.09.04.

![showcase](https://user-images.githubusercontent.com/19470159/46813471-6ee76800-cd7f-11e8-89aa-123b3a5f9f1b.gif)

## Installation
Recommended way to install is to use [plug.kak](https://github.com/andreyorst/plug.kak)  plugin
manager. You can install **fzf.kak** by adding this to your `kakrc`:

```kak
plug "andreyorst/fzf.kak"
```

Then reload Kakoune config or restart Kakoune and run `:plug-install`. 

Or install this plugin any other preferred way.

## Usage
There's no default key binding to invoke fzf, but **fzf.kak** provides a `fzf-mode` command that can be mapped to preferred key.
You can set your own mapping to invoke `fzf-mode`:

```kak
map global normal <c-p> ': fzf-mode<ret>'
# note that the space after colon is intentional to suppess fzf-mode to show in command history
```

Each fzf sub-command has mnemonic mapping, like `f` for opening files, `t` for tags and so on.
Available mappings:
- <kbd>b</kbd>     - Select buffer
- <kbd>c</kbd>     - Switch server's working directory
- <kbd>f</kbd>     - Search for file and open it
- <kbd>v</kbd>     - Edit file in version control system tree
- <kbd>Alt+v</kbd> - Explicitly select which vcs command to run
- <kbd>s</kbd>     - Search over buffer contents and jump to result line
- <kbd>t</kbd>     - Browse ctags tags
- <kbd>Alt+t</kbd> - Select tag kind filter on per language basis 
- <kbd>S</kbd>     - Fins symbols in current file

So for example pressing  <kbd>Ctrl+p</kbd><kbd>f</kbd>  will  open  fzf  at  the
bottom of the Kakoune buffer, showing you all possible files.

### Settings
**fzf.kak** features a lot of settings via options that can be altered to change how **fzf.kak** behaves.

#### Tmux
When using inside tmux, fzf will use bottom split. Height of this split can be changed with `fzf_tmux_height` option.
`fzf_tmux_height_file_preview` option is used to control height of the split when you do file searching with file-preview turned on.

#### File with file-preview turned on.
You can configure what command to use to search for files, and it's arguments.
Supported tools are [GNU Find](https://www.gnu.org/software/findutils/), [The Silver Searcher](https://github.com/ggreer/the_silver_searcher), [ripgrep](https://github.com/BurntSushi/ripgrep), [fd](https://github.com/sharkdp/fd). GNU find is used by default, but you can switch to another one. There are some default values for those, so you can go:

```kak
set-option global fzf_file_command 'rg' # 'ag', 'fd' or 'find' 
```

Or if you don't like default file arguments, which are `find -type f`, and would like to disable searching in, say `.git` directories you can set it like so:

```kak
set-option global fzf_file_command "find . \( -path '*/.svn*' -o -path '*/.git*' \) -prune -o -type f -print"
```

The same pattern applies for other commands, except `buffer`, and `cd`.

#### VCS
This script supports these version control systems: Git, Subversion, GNU Bazaar, Mercurial.
By default <kbd>v</kbd> mapping from `fzf mode` will detect your version control system and open fzf for you.
If you wish to explicitly use some particular vcs command, you can use `V` mapping, which includes
all supported vcs shortcuts.

You also able to set parameters to vcs command to use to provide project files. Supported options:

* `fzf_git_command`
* `fzf_svn_command`
* `fzf_bzr_command`
* `fzf_hg_command`

Other VCS are not supported officially. Open a feature request if you want some unsupported VCS to be included.
You also can change one of options to contain your VCS command, and use this command explicitly from VCS sub-mode.

#### ctags
It is also possible to add parameters to ctags search executable. like `sort -u` and others:

```kak
set-option global fzf_tag_command 'readtags -l | cut -f1 | sort -u | ... ' 
```

Though it is not recommended, since `sort` may slowdown `fzf-tag` on huge projects.

##### Filtering tags
Since ctags supports showing particular kind of tag for many languages,
`fzf-tag` dinamicly defines mappings for those languages with <kbd>Alt</kbd> key based on current filetype.
For example to show only functions while `fzf-tag` is active press <kbd>Alt</kbd>+<kbd>f</kbd>.
It will reload fzf window and only function tags will be listed.

#### Preview
When using X11 **fzf.kak** automatically tries to detect where to show preview window, depending
on aspect ratio of new termial window. By default if the height is bigger than the width, preview occupies
upper 60% of space. If height is smaller than the width, preview is shown at the right side.

You can configure the amount of space for preview window with these options: `fzf_preview_height` and `fzf_preview_width`.

When **fzf.kak** is used in tmux, it will show preview on the right side. Heigth of preview split can be adjusted with
`fzf_tmux_height_file_preview`

Amount of lines in preview window can be changed with `fzf_preview_lines` option.

You also can specify which highlighter to use within the preview window with `fzf_highlighter` option. 
Supported tools are:

* [Bat](https://github.com/sharkdp/bat)
* [Coderay](https://github.com/rubychan/coderay)
* [Highlight](https://gitlab.com/saalen/highlight)
* [Rouge](https://github.com/jneen/rouge)

You can disable the preview window in fzf window by setting `fzf_preview` option to `false`:

```kak
set-option global fzf_preview false
```

## Contributing

If you want to contribute to **fzf.kak** by adding a module, you can submit one by providing a pull request,
or just open a feature request and we'll see what can be done.

### Writing a module

You can write a module for **fzf.kak**. To create one, simply define a function in separate file, located
in `rc/fzf-modules/`, and named after the function. **fzf.kak** provides a general purpose command, that can be called with some
Kakoune command as first parameter, and command that provides list of items for fzf as a second parameter. Third optional parameter is 
for defining extra arguments for fzf itself, like additional keybindings.

Overall module structure is:
* Define a `fzf-command` command
* Prepare list of items for fzf, or define an item command
* call `fzf` command and pass needed arguments to it.

Of course modules can and will be more complex, since a good module checks if command for providing item list is available on user's machine,
and supports various settings inside it. Feel free to look how existing modules are made.
