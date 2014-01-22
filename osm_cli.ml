#use "topfind" ;;
#require "netclient" ;;
#require "unix" ;;
#require "xml-light" ;;
#directory "../osm-api/webget/" ;;
#load "webget.cmo";;
#load "osm_api.cmo";;

module OA = Osm_api

let test1 () =
  let left   = 2.3546255
  and right  = 2.3590457
  and bottom = 48.827944
  and top    = 48.8311222 in
  print_endline (
    OA.get_bbox ~test:true ()
      ~left ~bottom ~right ~top);
;;


let test2 () =
  OA.box_seg ~ni:3 ~nj:3
    ~lon:(2.2968292, 2.3886681)
    ~lat:(48.831388, 48.890568);
;;

let proc_map_bbox map_bbox =
  let left, bottom, right, top =
    Scanf.sscanf map_bbox "%f,%f,%f,%f"
      (fun a b c d -> a, b, c, d)
  in
  print_endline (
  (*
  OA.proc_nodes (
  *)
    OA.get_bbox
      ~test:false ()
      ~left ~bottom ~right ~top)


(* Utils *)

let assoc_of_list lst =
  let rec aux acc = function
    | x :: y :: tl ->
        aux ((x, y)::acc) tl
    | [] ->
        (List.rev acc)
    | _ :: [] ->
        invalid_arg "odd number of elements"
  in
  aux [] lst


let list_until this lst =
  let rec aux acc = function
  | (x::xs) as rem ->
      if x = this
      then (List.rev acc, rem)
      else aux (x::acc) xs
  | [] ->
      (List.rev acc, [])
  in
  aux [] lst


let put_nodes ~nodes_args =
  let rec aux acc = function
  | "-node" :: "-lat" :: lat :: "-lon" :: lon :: "-tags"  :: tags ->
      let tags, tail = list_until "-node" tags in
      let tags = assoc_of_list tags in
      let node = { OA. lat; lon; tags } in
      aux (node::acc) tail
  | [] ->
      (List.rev acc)
  | _ ->
      invalid_arg "-put-nodes"
  in
  let nodes = aux [] nodes_args in
  let changeset = OA.changeset_create ~test:true () in
  let nodes_ids = OA.put_nodes ~changeset ~nodes in
  List.iter (
    Printf.printf "node-id '%s' created\n") nodes_ids;
  let ret = OA.changeset_close ~changeset () in
  Printf.printf "End(%s)\n%!" ret;
;;


let put_nodes_rel ~nodes_args ~way_id =
  let rec aux acc = function
  | "-node" :: "-lat" :: lat :: "-lon" :: lon :: "-tags"  :: tags ->
      let tags, tail = list_until "-node" tags in
      let tags = assoc_of_list tags in
      let node = { OA. lat; lon; tags } in
      aux (node::acc) tail
  | [] ->
      (List.rev acc)
  | _ ->
      invalid_arg "-put-nodes"
  in
  let nodes = aux [] nodes_args in
  let changeset = OA.changeset_create ~test:true () in
  let nodes_ids = OA.put_nodes ~changeset ~nodes in
  List.iter (Printf.printf "node-id '%s' created\n") nodes_ids;
  let rel_ret = OA.put_relation ~changeset ~nodes_ids ~way_id in
  Printf.printf "Relation-res(%s)\n%!" rel_ret;
  let ret = OA.changeset_close ~changeset () in
  Printf.printf "End(%s)\n%!" ret;
;;


let usage () =
  let cmd = Sys.argv.(0) in
  Printf.eprintf "Usage:\n \
    %s -print-api-cap\n \
    %s -map-bbox \"left,bottom,right,top\"\n \
    %s -changeset-create\n \
    %s -put-node -lat <lat> -lon <lon> -tags ( <key> <value> ) list\n \
    %s -put-nodes\n \
    \ list of (\n \
    \  -node -lat <lat> -lon <lon> -tags ( <key> <value> ) list\n \
    \ )\n \
    \n" cmd cmd cmd cmd cmd;
    exit 1


let () =
  match List.tl (Array.to_list Sys.argv) with

  | ["-print-api-cap"] ->
      OA.print_api_capabilities ()

  | ["-map-bbox"; map_bbox] ->
      proc_map_bbox map_bbox

  | "-put-node" :: "-lat" :: lat :: "-lon" :: lon :: "-tags"  :: tags ->
      let changeset = OA.changeset_create ~test:true () in
      let tags = assoc_of_list tags in
      let node_id = OA.put_node ~changeset ~lat ~lon ~tags in
      Printf.printf "node-id '%s' created\n" node_id;
      let ret = OA.changeset_close ~changeset () in
      Printf.printf "End(%s)\n%!" ret

  | "-put-nodes" :: nodes_args ->
      put_nodes ~nodes_args

  | "-put-nodes-rel" :: way_id :: nodes_args ->
      put_nodes_rel ~nodes_args ~way_id

  | _ -> usage ()

