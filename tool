#!/bin/sh -e

prompt(){
    printf '%s\n\033[2J'

    if [ -e site/posts/"$1".md ]; then
        printf '\nPost already exists. Edit post instead? [y/n]: '; read -r as
        case "$as" in
            y) "${EDITOR:-vim}" site/posts/"$1".md ;;
            *) post "$1"
        esac
    else
        post "$1"
    fi
}

post(){
    printf -- "---\ntitle: %s\nauthor: %s\ndate: %s\n...\n" \
        "$1".md "$USER" "$(date '+%A, %b %d, %Y')" > site/posts/"$1".md

    "${EDITOR:-vim}" site/posts/"$1".md
    md2html "$1"
}

md2html(){
    # Grab the title from the file.
    t=$(grep -m 1 -e '^title:' site/posts/"$1".md | sed 's/^title: //')
    # Clear the screen.
    printf '%s\n\033[2J'

    # Markdown to HTML
    for i in site/posts/*.md; do
        printf '%s\n' '[post] MD2HTML.'
        pandoc --template site/template.html "$i" -o "${i%.md}.html"
    done

    # List the posts on main page.
    for x in site/posts/*.md; do
        printf '%s\n' '[post] Indexing.'
        t=$(grep -m 1 -e '^title:' "$x" | sed 's/^title: //')
        pandoc -s "$x" -o "${x%.md}.html"            
        echo "<a href=\"${x%.md}.html\">$t</a>" >> index.html
    done
}

main(){
    case "$@" in
        "")
            printf '%s\n' 'Usage: tool [filename]' 
            exit 0 ;;
        "-r")
            md2html && rm -rf site/posts/*.md ;;
        "-c")
            rm -rf site/posts/*.md ;;
        "-h")
            printf '-r remove original posts files\n'
            printf '-c remove all posts\n-h show help\n'
            exit 0 
            ;;
        *)
            prompt "$1" ;;
    esac
}

main "$@"
