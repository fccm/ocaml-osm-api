ocaml \
  unix.cma -I ./webget webget.cmo \
  -I +xml-light xml-light.cma \
  osm_api.cmo \
  osm_cli.ml $*
