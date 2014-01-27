(* Copyright (C) 2013, Florent Monnier *)
(*
#use "topfind"
#require "netclient"
#load "unix.cma"
#directory "../osm-api/webget/"
#load "webget.cmo"
#directory "+xml-light"
#load "xml-light.cma"
#load "osm_api.cmo"
*)

(* net communication *)

let wget ~url ~urn =
  let request =
    Printf.sprintf "GET %s HTTP/1.0\r\n\r\n" urn
  in
  let response =
    Wclient.client ~url ~request ~port:80 
  in
  let head, body = Wclient.resp_read response in
  ignore (head);
  (body)


let wput ~url ~urn ~data =
  let request =
    Printf.sprintf "PUT %s HTTP/1.0\r\n\
      %s\r\n\r\n" urn data
  in
  let response =
    Wclient.client ~url ~request ~port:80 
  in
  let head, body = Wclient.resp_read response in
  ignore (head);
  (body)


(* xml utils *)

let get_attrib attribs name =
  List.assoc name attribs

let get_child children elem_name =
  List.find (function
  | Xml.Element(this_name, _, _) -> (this_name = elem_name)
  | _ -> false
  ) children

let get_attrib_of_child children child_name attrib_name =
  Xml.attrib (get_child children child_name) attrib_name


(* osm-api *)

(* api-url *)

let api_url_real = "api.openstreetmap.org"  (* real access *)
let api_url_test = "api06.dev.openstreetmap.org"  (* test/dev access *)

let get_api_url ~test =
  if test
  then api_url_test
  else api_url_real


(* bbox *)

let get_bbox ?(test = false) () ~left ~bottom ~right ~top =
  let bbox_urn =
    Printf.sprintf
      "/api/0.6/map?bbox=%f,%f,%f,%f"
      left bottom right top
  in
  let api_url = get_api_url ~test in
  wget api_url bbox_urn


(* changeset *)

let changeset = "\
<osm>
  <changeset>
    <tag k='created_by' v='bp-script v0.00 alpha'/>
    <tag k='comment' v='Some Test'/>
  </changeset>
</osm>
"

(*
TODO: implement HTTP PUT in a portable way

module Hc = Http_client.Convenience ;;

let _changeset_create ?(test = false) () =
  let api_url = get_api_url ~test in
  let chset_urn = "/api/0.6/changeset/create" in
  let uri = (api_url ^ chset_urn) in
  print_endline (
    wput ~uri ~data:changeset)


let changeset_create ?(test = false) () =
  Hc.http_user := "user_name";
  Hc.http_password := "passwd";
  let api_url = api_url_test in
  (*
  let api_url = api_url_real in
  *)
  let chset_urn = "/api/0.6/changeset/create" in
  let uri = (api_url ^ chset_urn) in
  Printf.printf "On: %s\nPutting content:\n%s\n%!"
    uri changeset;
  let response = Hc.http_put uri changeset in
  (response)


let changeset_close ~changeset () =
  Hc.http_user := "user_name";
  Hc.http_password := "passwd";
  let api_url = api_url_test in
  (*
  let api_url = api_url_real in
  *)
  let chset_urn =
    Printf.sprintf
      "/api/0.6/changeset/%s/close"
      changeset
  in
  let put_content = changeset in
  let uri = (api_url ^ chset_urn) in
  Printf.printf "On: %s\nPutting content:\n%s\n%!"
    uri put_content;
  let response = Hc.http_put uri put_content in
  (response)
*)


(*
http://wiki.openstreetmap.org/wiki/API_v0.6#Create:_PUT_.2Fapi.2F0.6.2F.5Bnode.7Cway.7Crelation.5D.2Fcreate
*)

(* TODO: implement HTTP PUT in a portable way

let put_node ~changeset ~lat ~lon ~tags =
  Printf.printf "\
    # Put point at:\n \
    http://osm.org/?zoom=18&mlat=%s&mlon=%s\n%!"
    lat lon;  (* report what we're doing *)
  let tags =
    List.map (fun (k, v) ->
      Printf.sprintf "<tag k='%s' v='%s'/>" k v
    ) tags
  in
  let tags = String.concat "\n    " tags in
  let put_content =
    Printf.sprintf "\
<osm>
  <node changeset='%s' lat='%s' lon='%s' visible='true'>
    <tag k='note' v='Test node'/>
    %s
  </node>
</osm>
"   changeset lat lon tags
  in
  Hc.http_user := "user_name";
  Hc.http_password := "passwd";
  let api_url = api_url_test in
  (*
  let api_url = api_url_real in
  *)
  let chset_urn = "/api/0.6/node/create" in
  let uri = (api_url ^ chset_urn) in
  Printf.printf "On: %s\nPutting content:\n%s\n%!"
    uri put_content;
  let response = Hc.http_put uri put_content in
  (response)

type node = {
  lat: string;
  lon: string;
  tags: (string * string) list;
}

let put_nodes ~changeset ~nodes =
  let responses =
    List.map (fun node ->
      put_node ~changeset
        ~lat:node.lat
        ~lon:node.lon
        ~tags:node.tags
    ) nodes
  in
  (responses)


let put_request ~urn ~content =
  Hc.http_user := "user_name";
  Hc.http_password := "passwd";
  let api_url = api_url_test in
  (*
  let api_url = api_url_real in
  *)
  let uri = (api_url ^ urn) in
  Printf.printf "On: %s\nPutting content:\n%s\n%!" uri content;
  let response = Hc.http_put uri content in
  (response)


let put_relation ~changeset ~nodes_ids ~way_id =
  let rels =
    List.map (Printf.sprintf "\
      <member type='node' ref='%s' role='house'/>") nodes_ids
  in
  let rels = String.concat "\n    " rels in
  let content = Printf.sprintf "\
<osm>
  <relation changeset='%s'>
    <member type='way' ref='%s' role='street'/>
    %s
    <tag k='type' v='associatedStreet'/>
  </relation>
</osm>
"   changeset way_id rels
  in
  let urn = "/api/0.6/relation/create" in
  put_request ~urn ~content


let put_way ~changeset ~name ~nodes_ids =
  let nodes =
    List.map (Printf.sprintf "\
      <nd ref='%s'/>") nodes_ids
  in
  let nodes = String.concat "\n    " nodes in
  let content = Printf.sprintf "\
<osm>
  <way visible='true' changeset='%s'>
    %s
    <tag k='highway' v='unclassified'/>
    <tag k='name' v='%s'/>
  </way>
</osm>
"   changeset nodes name
  in
  let urn = "/api/0.6/way/create" in
  put_request ~urn ~content
*)


(* API Capabilities *)

type api_capabilities = {
  version: string;
  version_min: string;
  version_max: string;
  max_area: string;
  tracepoints_per_page: string;
  max_waynodes: string;
  changesets_max_elems: string;
  timeout_sec: string;
  database_status: string;
  api_status: string;
  gpx_status: string;
}


let get_capabilities_xml ~test =
  let cap_urn = "/api/capabilities" in
  let api_url = get_api_url ~test in
  wget api_url cap_urn


let get_capabilities ?(test = false) () =
  let xml = get_capabilities_xml ~test in
  match Xml.parse_string xml with
  | Xml.Element ("osm", osm_attrs, [
      Xml.Element ("api", _, api_children)]) ->
        let version = get_attrib osm_attrs "version" in
        let vers = get_child api_children "version" in
        let version_min = Xml.attrib vers "minimum"
        and version_max = Xml.attrib vers "maximum" in
        let get = get_attrib_of_child api_children in
        { version;
          version_min;
          version_max;
          max_area = get "area" "maximum";
          tracepoints_per_page = get "tracepoints" "per_page";
          max_waynodes = get "waynodes" "maximum";
          changesets_max_elems = get "changesets" "maximum_elements";
          timeout_sec = get "timeout" "seconds";
          database_status = get "status" "database";
          api_status = get "status" "api";
          gpx_status = get "status" "gpx";
        }
  | _ ->
      invalid_arg "get_capabilities"


let get_capabipolies ?(test = false) () =
  let xml = get_capabilities_xml ~test in
  match Xml.parse_string xml with
  | Xml.Element ("osm", osm_attrs, [
      Xml.Element ("api", _, api_children)]) ->
        let version = get_attrib osm_attrs "version" in
        let vers = get_child api_children "version" in
        let version_min = Xml.attrib vers "minimum"
        and version_max = Xml.attrib vers "maximum" in
        let get = get_attrib_of_child api_children in
        [ "version", version;
          "version_min", version_min;
          "version_max", version_max;
          "max_area", (get "area" "maximum");
          "tracepoints_per_page", (get "tracepoints" "per_page");
          "max_waynodes", (get "waynodes" "maximum");
          "changesets_max_elems", (get "changesets" "maximum_elements");
          "timeout_sec", (get "timeout" "seconds");
          "database_status", (get "status" "database");
          "api_status", (get "status" "api");
          "gpx_status", (get "status" "gpx");
        ]
  | _ ->
      invalid_arg "get_capabipolies"


let get_capabistring ?test () =
  let c = get_capabilities ?test () in
  Printf.sprintf "\
version: %s
version-min: %s
version-max: %s
max-area: %s
tracepoints-per-page: %s
max-waynodes: %s
changesets-max-elems: %s
timeout-sec: %s
database-status: %s
api-status: %s
gpx-status: %s
"
  c.version
  c.version_min
  c.version_max
  c.max_area
  c.tracepoints_per_page
  c.max_waynodes
  c.changesets_max_elems
  c.timeout_sec
  c.database_status
  c.api_status
  c.gpx_status


let box_seg ~ni ~nj
    ~lon:(lon1, lon2)
    ~lat:(lat1, lat2) =
  let lon_i = (lon2 -. lon1) /. (float ni) in
  let lat_i = (lat2 -. lat1) /. (float nj) in
  let r = Array.make_matrix ni nj (0.0, 0.0, 0.0, 0.0) in
  for i = 0 to pred ni do
    for j = 0 to pred nj do
      let lat_a = lat1 +. (lat_i *. float i) in
      let lon_a = lon1 +. (lon_i *. float j) in
      let lat_b = lat_a +. lat_i in
      let lon_b = lon_a +. lon_i in
      r.(i).(j) <- (lat_a, lon_a, lat_b, lon_b)
    done
  done
  ; (r)
(*
  example:

  get_bboxes
    ~lat:(48.09688, 48.13585)
    ~lon:(-1.72142, -1.60555)

  [0][0] => 48.096880,-1.721420  48.106623,-1.692452
  [0][1] => 48.096880,-1.692452  48.106623,-1.663485
  [0][2] => 48.096880,-1.663485  48.106623,-1.634518
  [0][3] => 48.096880,-1.634518  48.106623,-1.605550
  [1][0] => 48.106623,-1.721420  48.116365,-1.692452
  [1][1] => 48.106623,-1.692452  48.116365,-1.663485
  [1][2] => 48.106623,-1.663485  48.116365,-1.634518
  [1][3] => 48.106623,-1.634518  48.116365,-1.605550
  [2][0] => 48.116365,-1.721420  48.126108,-1.692452
  [2][1] => 48.116365,-1.692452  48.126108,-1.663485
  [2][2] => 48.116365,-1.663485  48.126108,-1.634518
  [2][3] => 48.116365,-1.634518  48.126108,-1.605550
  [3][0] => 48.126107,-1.721420  48.135850,-1.692452
  [3][1] => 48.126107,-1.692452  48.135850,-1.663485
  [3][2] => 48.126107,-1.663485  48.135850,-1.634518
  [3][3] => 48.126107,-1.634518  48.135850,-1.605550
*)


type xml_string = string

let proc_nodes xml =
  match Xml.parse_string xml with
  | Xml.Element ("osm", osm_attrs, osm_contents) ->
      let len = List.length osm_contents in
      Printf.printf "osm-contents-length: %d\n%!" len;
      if len = 0 then print_endline xml;
      List.iter (function
      | Xml.Element ("node", node_attrs, node_contents) ->
          let node_id = get_attrib node_attrs "id" in
          Printf.printf "node-id: %s\n" node_id
      | _ ->
          Printf.printf "not-node\n"
      ) osm_contents
  | _ ->
      invalid_arg "proc_nodes"

