let zeros n = Array.make n 0.0
let randn ~mu ~sigma = Owl_base.Stats.gaussian_rvs ~mu ~sigma

let randn2d n d =
  Array.init n (fun _ -> Array.init d (fun _ -> randn ~mu:0.0 ~sigma:1e-4))
;;
