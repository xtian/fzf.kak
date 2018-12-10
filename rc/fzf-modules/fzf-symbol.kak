# ╭─────────────╥──────────────────────────╮
# │ Author:     ║ File:                    │
# │ Andrey Orst ║ fzf-ctags.kak            │
# ╞═════════════╩══════════════════════════╡
# │ Module for searching tags with fzf     │
# │ and universal-ctags for fzf.kak plugin │
# ╞════════════════════════════════════════╡
# │ GitHub.com/andreyorst/fzf.kak          │
# ╰────────────────────────────────────────╯

map global fzf -docstring "find symbol in current file" 'S' '<esc>: fzf-file-symbol<ret>'

define-command -hidden fzf-file-symbol -params ..2 %{ evaluate-commands %sh{
    tags="${TMPDIR:-/tmp}/tags-${kak_buffile##*/}"; tags="${tags%.*}"
    ctags -f $tags $kak_buffile

    message="Jump to a symbol''s definition
<ret>: open tag in new buffer
<c-w>: open tag in new window"

    [ -n "${kak_client_env_TMUX}" ] && tmux_keybindings="
<c-s>: open tag in horizontal split
<c-v>: open tag in vertical split"

    printf "%s\n" "info -title 'fzf symbol' '$message$tmux_keybindings'"

    [ ! -z "${kak_client_env_TMUX}" ] && additional_flags="--expect ctrl-v --expect ctrl-s"
    printf "%s\n" "fzf %{fzf-file-symbol-search} %{cut -f 1 '$tags' | grep -v '^!' | awk '!a[\$0]++'} %{--expect ctrl-w $additional_flags}"
}}

define-command -hidden fzf-file-symbol-search -params 1 %{ evaluate-commands %sh{
    tags="${TMPDIR:-/tmp}/tags-${kak_buffile##*/}"; tags="${tags%.*}"
    menu="${TMPDIR:-/tmp}/ctags-menu"
    open='{'; close='}'
    readtags -t "$tags" "$1" |
    while read tag; do
        name=$(printf "%s\n" "$tag" | cut -f 2 | sed "s:':'':g")
        menuinfo=$(printf "%s\n" "$tag" | sed "s:.*/\^\(\s\+\)\?::;s:\(\\\$\)\?/$::;s:':'':g;s:$open:\\\\$open:g")
        keys=$(printf "%s\n" "$tag" | sed "s:.*/\^::;s:\(\\\$\)\?/$::;s:':'''''''''''''''':g;s:<:<lt>:g")
        file=$(printf "%s\n" "$name" | sed "s:'':'''''''''''''''':g")
        command="evaluate-commands '' try '''' edit ''''''''$file''''''''; execute-keys ''''''''/\Q$keys<ret>vc'''''''' '''' catch '''' echo -markup ''''''''{Error}unable to find tag'''''''' '''' ''"
        if [ -n "$file" ] && [ -n "$keys" ]; then
            printf "%s " "'$name {MenuInfo}$menuinfo' '$command'" >> $menu
        fi
    done
    if [ -s "$menu" ]; then
        printf "%s\n" "menu -auto-single -markup $(cat $menu)"
        rm $menu
    else
        printf "%s\n" "echo -markup %{{Error}tag '${1:-$kak_selection}' not found}"
    fi
    rm $tags
}}
