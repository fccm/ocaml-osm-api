let contents_of_inchan ic =
  let buf = Buffer.create 16384
  and tmp = String.create 4096 in
  let rec aux () =
    let bytes = input ic tmp 0 4096 in
    if bytes > 0 then begin
      Buffer.add_substring buf tmp 0 bytes;
      aux ()
    end
  in
  (try aux () with End_of_file -> ());
  (Buffer.contents buf)

let contents_of_file ~filename =
  let ic = open_in filename in
  let cont = contents_of_inchan ic in
  close_in ic;
  (cont)

