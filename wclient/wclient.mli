(* Public Domain: CC0 1.0
   http://creativecommons.org/publicdomain/zero/1.0/
*)

val client : url:string -> port:int -> request:string -> string
(** example:
  [client
    ~url:"ocaml.org"
    ~port:80
    ~request:"GET /~fmonnier/ocaml/ HTTP/1.0\r\n\r\n"]
*)

val resp_read : resp:string -> string list * string
(** separates the [response] into its [head] and [body] *)

