open! Js_of_ocaml

(* let print_mat mat =
 *   Array.iter
 *     (fun v ->
 *       let row = Array.fold_left (fun acc vv -> Printf.sprintf "%s,%f" acc vv) "" v in
 *       Printf.printf "%s\n" row)
 *     mat *)
(* let print_arr arr = Array.iter (fun v -> Printf.printf "%f," v) arr *)

let () =
  let open Js_of_ocaml in
  print_string "Hello JS World!\n";
  Js.export
    "tSNE"
    (object%js (_self)
       val mutable epsilon = 10
       val mutable perplexity = 30
       val mutable dim = 2

       method init epsilon perplexity dim =
         _self##.dim := dim;
         _self##.epsilon := epsilon;
         _self##.perplexity := perplexity

       method init_raw_data (x : float Js.js_array Js.t) =
         let arr = Jv.to_array Jv.to_float @@ Jv.repr x in
         let total = Owl_base.Stats.sum arr in
         Jv.of_float total
    end)
;;
(* let mat = Utils.randn2d 10 10 in
 * print_mat mat;
 * Printf.printf "L2:%f\n" @@ Utils.l2 mat.(0) mat.(7);
 * Printf.printf "XtoD\n";
 * print_arr (Utils.xtod mat) *)
