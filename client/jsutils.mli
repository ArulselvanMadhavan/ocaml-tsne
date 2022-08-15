open Js_of_ocaml

val from_2d_arr : float Js.js_array Js.js_array Js.t -> float array array
val to_2d_arr : float array array -> Jv.t
val from_2d_arr_jv : Jv.t -> float array array
