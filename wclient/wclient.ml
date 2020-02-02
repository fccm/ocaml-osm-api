(* Copyright (C) 2014, Florent Monnier *)

let write_to fout str =
  let n = String.length str in
  ignore (Unix.write fout (Bytes.of_string str) 0 n)


let read_form fin =
  let b_size = 1024 * 8 in
  let s_size = 1024 * 8 in
  let s = Bytes.create s_size in
  let b = Buffer.create b_size in
  let rec aux () =
    match Unix.read fin s 0 s_size with
    | 0 -> Buffer.contents b
    | n -> Buffer.add_subbytes b s 0 n; aux ()
  in
  aux ()


let client ~url ~port ~request =
  let server_addr =
    try (Unix.gethostbyname url).Unix.h_addr_list.(0)
    with Not_found ->
      prerr_endline (url ^ ": Host not found");
      exit 2
  in
  let sock = Unix.socket Unix.PF_INET Unix.SOCK_STREAM 0 in
  Unix.connect sock (Unix.ADDR_INET(server_addr, port));
  write_to sock request;
  let ans = read_form sock in
  (ans)


let resp_read ~resp:s =
  let n = String.length s in
  if n < 4 then failwith "resp_read" else
  let cs =
    ( String.unsafe_get s 0,
      String.unsafe_get s 1,
      String.unsafe_get s 2,
      String.unsafe_get s 3 )
  in
  let rec aux cs i j acc m =
    if j >= n then (List.rev acc, m) else
    match cs with
    | '\r', '\n', '\r', '\n' ->
        let body = String.sub s j (n-j) in
        (List.rev acc, body)
  
    | '\r', '\n', c3, c4 ->
        let hl = String.sub s i (j-i-4) in
        let k = j + 1 in
        if k >= n then failwith "resp_read" else
        let cj = String.unsafe_get s j in
        let ck = String.unsafe_get s k in
        let _cs = (c3, c4, cj, ck) in
        aux _cs (j-2) (k+1) (hl::acc) m
  
    | c1, c2, c3, c4 ->
        let ci = String.unsafe_get s j in
        let _cs = (c2, c3, c4, ci) in
        aux _cs i (j+1) acc m
  in
  aux cs 0 4 [] ""

