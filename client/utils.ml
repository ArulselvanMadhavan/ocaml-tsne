let zeros n = Array.make n 0.0
let randn ~mu ~sigma = Owl_base.Stats.gaussian_rvs ~mu ~sigma

let randn2d n d =
  Array.init n (fun _ -> Array.init d (fun _ -> randn ~mu:0.0 ~sigma:1e-4))
;;

let l2 x1 x2 =
  let f idx acc x1i =
    let x2i = x2.(idx) in
    let diff = x1i -. x2i in
    let sqr_diff = Owl_base.Maths.sqr diff in
    let acc = acc +. sqr_diff in
    (* Printf.printf "%f|%f|%f\n" diff sqr_diff acc; *)
    acc
  in
  Core.Array.foldi x1 ~init:0. ~f
;;
