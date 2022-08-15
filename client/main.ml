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
       val mutable epsilon = 10.
       val mutable perplexity = 30.
       val mutable dim = 2
       val mutable _N = 0
       val mutable _P = Js.array [||]
       val mutable _Y = Jv.of_jv_array [||]
       val mutable gains = Jv.of_jv_array [||]
       val mutable ystep = Jv.of_jv_array [||]
       val mutable iter = 0

       method init epsilon perplexity dim =
         _self##.dim := dim;
         _self##.epsilon := epsilon;
         _self##.perplexity := perplexity

       method initDataRaw (x : float Js.js_array Js.js_array Js.t) =
         let mat = Jsutils.from_2d_arr x in
         let n = Array.length mat in
         let dists = Utils.xtod mat in
         let p_out = Utils.d2p n dists _self##.perplexity 1e-4 in
         _self##._N := n;
         _self##._P := Js.array p_out

       method initDataDist (d : float Js.js_array Js.js_array Js.t) =
         let mat = Jsutils.from_2d_arr d in
         let n = Array.length mat in
         let dists = Utils.zeros (n * n) in
         Array.iteri
           (fun i _ ->
             Array.iteri
               (fun j _ ->
                 let d = mat.(i).(j) in
                 dists.((i * n) + j) <- d;
                 dists.((j * n) + i) <- d)
               mat)
           mat;
         let p_out = Utils.d2p n dists _self##.perplexity 1e-4 in
         _self##._N := n;
         _self##._P := Js.array p_out

       method initSolution =
         let mat = Utils.randn2d _self##._N _self##.dim None in
         let gains = Utils.randn2d _self##._N _self##.dim @@ Some 1.0 in
         let ystep = Utils.randn2d _self##._N _self##.dim @@ Some 0.0 in
         _self##._Y := Jsutils.to_2d_arr mat;
         _self##.gains := Jsutils.to_2d_arr gains;
         _self##.ystep := Jsutils.to_2d_arr ystep;
         _self##.iter := 0

       method getSolution = _self##._Y

       method step =
         _self##.iter := _self##.iter + 1;
         let p_out = Js.to_array _self##._P in
         let y = Jsutils.from_2d_arr_jv _self##._Y in
         let cost, grad = Utils.costgrad _self##.dim _self##.iter p_out y in
         let ystep = Jsutils.from_2d_arr_jv _self##.ystep in
         let gains = Jsutils.from_2d_arr_jv _self##.gains in
         Utils.step _self##._N _self##.iter _self##.dim _self##.epsilon ystep gains grad y;
         _self##.gains := Jsutils.to_2d_arr gains;
         _self##.ystep := Jsutils.to_2d_arr ystep;
         _self##._Y := Jsutils.to_2d_arr y;
         cost

       method debugGrad =
         let p_out = Js.to_array _self##._P in
         let y = Jsutils.from_2d_arr_jv _self##._Y in
         Utils.debug_grad _self##.dim _self##.iter p_out y
    end)
;;
(* let mat = Utils.randn2d 10 10 in
 * print_mat mat;
 * Printf.printf "L2:%f\n" @@ Utils.l2 mat.(0) mat.(7);
 * Printf.printf "XtoD\n";
 * print_arr (Utils.xtod mat) *)
