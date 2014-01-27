ocaml \
  -I ../ocaml-unix-red/mod redUnix.cma \
  -I ./wclient wclient.cmo \
  -I +xml-light xml-light.cma \
  osm_api.cmo \
  osm_cli.ml $*

