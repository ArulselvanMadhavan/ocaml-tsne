open! Js_of_ocaml

let from_2d_arr x = Jv.to_array (fun arr -> Jv.to_array Jv.to_float arr) @@ Jv.repr x

let to_2d_arr (x : float array array) =
  Jv.of_array (fun a -> Jv.of_array (fun aa -> Jv.of_float aa) a) x
;;

let from_2d_arr_jv x = Jv.to_array (fun v -> Jv.to_array (fun vv -> Jv.to_float vv) v) x
