# Personal notes:

## Check `nm -U -/executable`

- the idea is to filter the authorized functions via here-doc in order to see possible unauthorized functions used:
```
cat << 'EOF' | tr -d ',' | tr -s '[:space:]' '\n' | grep -v '^$' | grep -Fxv -f - <(nm -u ./minishell | awk '{print $NF}' | sed 's/@.*//' | grep -vE "^(_|__)")
```
or
```
cat << 'EOF' | tr -d ',' | xargs -n1 | { echo; grep -Fxv -f - <(nm -u ./minishell | awk '{sub(/@.*/,"",$NF); if($NF!~/^_/) print $NF}'); }
```

then you copy and paste the authorized functions for a given project into the here-doc, type EOF, and you get the results filtered.

## Disable the slow typewritter animation during copy-pasting

- Add to `.zshrc`, for instance after the plugins section:

```
# Disable the slow typewritter animation during copy-pasting
zstyle ':bracketed-paste-magic' active-widgets '.self-*'
```
`vim ~/.zshrc`:
