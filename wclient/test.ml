#directory "../../ocaml-unix-red/mod"
#load "redUnix.cma"
#load "wclient.cmo"

module WC = Wclient

let () =
  let resp =
    WC.client
      "api.openstreetmap.org" 80
      "GET /api/capabilities HTTP/1.0\r\n\r\n"
  in
  print_string resp;
  print_endline "===========================";
  let head, body = WC.resp_read resp in
  List.iter (fun s -> Printf.printf "H: [%s]\n" s) head;
  print_endline "===========================";
  print_string body;
  print_endline "===========================";
;;

