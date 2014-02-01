#directory "+xml-light" ;;
#load "xml-light.cma" ;;

let get_attrib attribs name =
  List.assoc name attribs

let is_tag = function
  | Xml.Element ("tag", ["k", _; "v", _], []) -> true
  | _ -> false

let map_tag = function
  | Xml.Element ("tag", ["k", k; "v", v], []) -> (k, v)
  | _ -> invalid_arg "map_tag"

let is_nd = function
  | Xml.Element ("nd", ["ref", _], []) -> true
  | _ -> false

let map_nd = function
  | Xml.Element ("nd", ["ref", ref], []) -> (ref)
  | _ -> invalid_arg "map_nd"


let print_node node_attrs node_children =
  let lat = get_attrib node_attrs "lat" in
  let lon = get_attrib node_attrs "lon" in
  let node_id = get_attrib node_attrs "id" in
  Printf.printf "node > id:%s lat:%s lon:%s\n" node_id lat lon;
  let xml_tags = List.filter is_tag node_children in
  let tags = List.map map_tag xml_tags in
  List.iter (fun (k, v) ->
    Printf.printf "     > tag: '%s'=\"%s\"\n" k v;
  ) tags


let print_way way_attrs way_children =
  let way_id = get_attrib way_attrs "id" in
  Printf.printf "way > id=\"%s\"\n" way_id;
  let xml_tags = List.filter is_tag way_children in
  let tags = List.map map_tag xml_tags in
  let xml_nds = List.filter is_nd way_children in
  let nds = List.map map_nd xml_nds in
  List.iter (fun (ref) ->
    Printf.printf "    > nd: ref=\"%s\"\n" ref;
  ) nds;
  List.iter (fun (k, v) ->
    Printf.printf "    > tag: '%s'=\"%s\"\n" k v;
  ) tags;
  print_char '\n'


let print_relation rel_attrs rel_children =
  let rel_id = get_attrib rel_attrs "id" in
  Printf.printf "rel > id=\"%s\"\n" rel_id;
  let xml_tags = List.filter is_tag rel_children in
  let tags = List.map map_tag xml_tags in
  List.iter (fun (k, v) ->
    Printf.printf "    > tag: '%s'=\"%s\"\n" k v;
  ) tags;
  print_char '\n'


let print_txt_verbose = function
  | Xml.Element ("osm", osm_attrs, osm_children) ->
      List.iter (function
      | Xml.Element ("node", node_attrs, node_children) ->
          print_node node_attrs node_children
      | Xml.Element ("way", way_attrs, way_children) ->
          print_way way_attrs way_children
      | Xml.Element ("relation", relat_attrs, relat_children) ->
          print_relation relat_attrs relat_children
      | _ -> ()
      ) osm_children

  | _ ->
      assert false


(* =========================== *)

let get_users = function
  | Xml.Element ("osm", osm_attrs, osm_children) ->
      List.fold_left (fun acc -> function
      | Xml.Element ("node", node_attrs, node_children) ->
          let usr = get_attrib node_attrs "user" in
          if List.mem usr acc then acc else usr::acc
      | Xml.Element ("way", way_attrs, way_children) ->
          let usr = get_attrib way_attrs "user" in
          if List.mem usr acc then acc else usr::acc
      | Xml.Element ("relation", relat_attrs, node_children) ->
          let usr = get_attrib relat_attrs "user" in
          if List.mem usr acc then acc else usr::acc
      | _ -> (acc)
      ) [] osm_children

  | _ ->
      assert false


let print_txt_usr xml =
  let users = List.rev (get_users xml) in
  List.iter print_endline users

(* =========================== *)

let print_way_name way_attrs way_children =
  let way_id = get_attrib way_attrs "id" in
  let xml_tags = List.filter is_tag way_children in
  let tags = List.map map_tag xml_tags in
  let name = List.assoc "name" tags in
  Printf.printf "way: id='%s' name=\"%s\"\n" way_id name

let print_way_name way_attrs way_children =
  try print_way_name way_attrs way_children
  with Not_found -> ()


let print_way_names = function
  | Xml.Element ("osm", osm_attrs, osm_children) ->
      List.iter (function
      | Xml.Element ("way", way_attrs, way_children) ->
          print_way_name way_attrs way_children
      | _ -> ()
      ) osm_children

  | _ ->
      assert false

(* =========================== *)

let usage ec =
  begin
    if ec = 0
    then Printf.printf
    else Printf.eprintf
  end "\
  Usage:
  \ Input:\n\
  \   -\n\
  \   --xml-file <filename>\n\
  \ Output:\n\
  \   --print-txt-verbose\n\
  \   --print-way-names\n\
  \   --print-users\n\
  "
  ; exit ec


(* =========================== *)

let () =
  let args = List.tl (Array.to_list Sys.argv) in

  let rec read_args input output = function
  | [] ->
      (input, output)

  | "-" :: args ->
      read_args (`IC stdin) output args

  | "--xml-file" :: filename :: args ->
      read_args (`Filename filename) output args

  | "--print-txt-verbose" :: args ->
      read_args input print_txt_verbose args

  | "--print-way-names" :: args ->
      read_args input print_way_names args

  | "--print-users" :: args ->
      read_args input print_txt_usr args

  | ["-h"] | ["-help"] | ["--help"] ->
      usage 0

  | _ ->
      usage 1
  in
  let input, output = read_args `none ignore args in

  let xml =
    match input with
    | `Filename filename ->
        Xml.parse_file filename
    | `IC stdin ->
        Xml.parse_in stdin
    | `none ->
        usage 1
  in
  output xml

