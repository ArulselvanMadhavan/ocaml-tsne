open! Js_of_ocaml

let from_2d_arr x =
  let arr = Jv.to_array (fun arr -> Jv.to_array Jv.to_float arr) @@ Jv.repr x in
  let total = Array.fold_left (fun acc arr -> acc +. Owl_base.Stats.sum arr) 0. arr in
  Jv.of_float total
;;
