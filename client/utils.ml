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

let xtod x =
  let n = Array.length x in
  let dist = zeros (n * n) in
  let f i irow =
    for j = i + 1 to n - 1 do
      let jrow = x.(j) in
      let d = l2 irow jrow in
      let dij = (i * n) + j in
      let dji = (j * n) + i in
      dist.(dij) <- d;
      dist.(dji) <- d
    done
  in
  Core.Array.iteri x ~f;
  dist
;;
