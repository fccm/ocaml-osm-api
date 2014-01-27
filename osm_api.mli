(** OCaml interface to the OSM API *)
(* Public Domain: CC0 1.0
   http://creativecommons.org/publicdomain/zero/1.0/
*)

(** {3 API Capabilities} *)

type api_capabilities = {
  version : string;
  version_min : string;
  version_max : string;
  max_area : string;
  tracepoints_per_page : string;
  max_waynodes : string;
  changesets_max_elems : string;
  timeout_sec : string;
  database_status : string;
  api_status : string;
  gpx_status : string;
}

val get_capabilities : ?test:bool -> unit -> api_capabilities
(** get the API capabilities as a record *)

val get_capabipolies : ?test:bool -> unit -> (string * string) list
(** get the API capabilities as a polymorphic association list *)

val get_capabistring : ?test:bool -> unit -> string
(** get the API capabilities as a printable string *)


(** {3 Bbox} *)

val get_bbox :
  ?test:bool -> unit ->
  left:float ->
  bottom:float ->
  right:float ->
  top:float -> string
(** get the content of an area *)


(** {3 Changeset} *)

(** TODO: implement HTTP PUT in a portable way
val changeset_create :
  ?test:bool -> unit -> string

val changeset_close :
  changeset:string -> unit -> string
*)


(** {3 Create elements} *)

(** TODO: implement HTTP PUT in a portable way
{[
val put_node :
  changeset:string ->
  lat:string -> lon:string ->
  tags:(string * string) list ->
  string

type node = {
  lat: string;
  lon: string;
  tags: (string * string) list;
}

val put_nodes :
  changeset:string ->
  nodes:node list ->
  string list

val put_relation :
  changeset:string ->
  nodes_ids:string list ->
  way_id:string ->
  string

val put_way :
  changeset:string ->
  name:string ->
  nodes_ids:string list ->
  string
]}
*)


(** {4 Utils} *)

val box_seg :
  ni:int ->
  nj:int ->
  lon:float * float ->
  lat:float * float ->
    (float * float * float * float) array array
(** segments an area into several smaller areas *)

(**/**)

type xml_string = string

val proc_nodes : xml_string -> unit

