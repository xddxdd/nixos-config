{
  agenix,
  nano,
  ...
}: ''
  if [ -z "$1" ]; then
    ${agenix}/bin/agenix -r
  elif (echo "$1" | grep -q ".age"); then
    EDITOR=${nano}/bin/nano ${agenix}/bin/agenix -e "$1"
  else
    EDITOR=${nano}/bin/nano ${agenix}/bin/agenix -e "$1.age"
  fi
''
