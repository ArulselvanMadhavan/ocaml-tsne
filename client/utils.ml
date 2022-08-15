let zeros n = Array.make n 0.0
let randn ~mu ~sigma = Owl_base.Stats.gaussian_rvs ~mu ~sigma

let randn2d n d s =
  Array.init n (fun _ ->
    if Option.is_some s
    then Array.make d @@ Option.get s
    else Array.init d (fun _ -> randn ~mu:0.0 ~sigma:1e-4))
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

let d2p n d_arr pplex tol =
  let h_target = Owl_base.Maths.log pplex in
  let p_row = zeros n in
  let p_arr = zeros (n * n) in
  let f i _val =
    let betamin = ref Float.neg_infinity in
    let betamax = ref Float.infinity in
    let beta = ref 1. in
    let max_tries = 50 in
    let rec tryloop num =
      if num > max_tries
      then num
      else (
        (* kernel row with beta precision *)
        let calc_kernel_row j psum _val =
          let pj =
            if i = j
            then 0.0
            else (
              let d_idx = (i * n) + j in
              let d_val = Float.neg d_arr.(d_idx) in
              Owl_base.Maths.exp (d_val *. !beta))
          in
          p_row.(j) <- pj;
          psum +. pj
        in
        let psum = Core.Array.foldi p_row ~init:0. ~f:calc_kernel_row in
        (* normalize p and compute entropy *)
        let h_here =
          if psum = 0.
          then 0.
          else
            Core.Array.foldi p_row ~init:0. ~f:(fun j hhere elem ->
              let pj = elem /. psum in
              p_row.(j) <- pj;
              if pj > 1e-7 then hhere -. (pj *. Owl_base.Maths.log pj) else hhere)
        in
        (* adjust beta based on result         *)
        let on_high_entropy () =
          betamin := !beta;
          if !betamax == Float.infinity
          then beta := !beta *. 2.
          else beta := (!beta +. !betamax) /. 2.
        in
        let on_low_entropy () =
          betamax := !beta;
          if !betamin == Float.neg_infinity
          then beta := !beta /. 2.
          else beta := (!beta +. !betamin) /. 2.
        in
        let _ = if h_here > h_target then on_high_entropy () else on_low_entropy () in
        if Owl_base.Maths.abs (h_here -. h_target) < tol then num else tryloop (num + 1))
    in
    let num = tryloop 0 in
    Printf.printf "i:%d|num:%d\n" i num;
    Array.iteri
      (fun j elem ->
        let i_idx = (i * n) + j in
        p_arr.(i_idx) <- elem)
      p_row
  in
  Array.iteri f p_row;
  (* symmetrize P and normalize it to sum to 1 over all ij *)
  let p_out = zeros (n * n) in
  let n2 = n * 2 in
  Array.iteri
    (fun i _val ->
      Array.iteri
        (fun j _val ->
          let i_idx = (i * n) + j in
          let j_idx = (j * n) + i in
          let i_plus_j = p_arr.(i_idx) +. p_arr.(j_idx) in
          p_out.(i_idx) <- Float.max (i_plus_j /. Float.of_int n2) 1e-100)
        p_row)
    p_row;
  p_out
;;

let costgrad dim iter p_out y =
  let n = Array.length y in
  let p_mul = if iter < 100 then 4. else 1. in
  let qu = zeros (n * n) in
  let qsum = ref 0. in
  Array.iteri
    (fun i _ ->
      Array.iteri
        (fun j _ ->
          let dsum =
            Core.Array.foldi (Array.make dim 0) ~init:0. ~f:(fun d acc _ ->
              let dhere = y.(i).(d) -. y.(j).(d) in
              acc +. Owl_base.Maths.sqr dhere)
          in
          let quu = 1.0 /. (1.0 +. dsum) in
          let i_idx = (i * n) + j in
          let j_idx = (j * n) + i in
          qu.(i_idx) <- quu;
          qu.(j_idx) <- quu;
          qsum := !qsum +. (2. *. quu))
        y)
    y;
  (* normalize Q distribution to sum to 1 *)
  let q = zeros (n * n) in
  Array.iteri (fun i elem -> q.(i) <- Float.max (elem /. !qsum) 1e-100) q;
  (* cost and grad *)
  let cost = ref 0.0 in
  let grad =
    Array.mapi
      (fun i _ ->
        let gsum = Array.make dim 0.0 in
        Array.iteri
          (fun j _ ->
            let i_idx = (i * n) + j in
            let cost_temp = p_out.(i_idx) *. Owl_base.Maths.log q.(i_idx) in
            cost := !cost +. cost_temp;
            let premult = 4. *. (p_mul *. p_out.(i_idx) *. q.(i_idx)) *. qu.(i_idx) in
            Array.iteri
              (fun d elem -> gsum.(d) <- elem +. (premult *. (y.(i).(d) -. y.(j).(d))))
              gsum)
          y;
        gsum)
      y
  in
  !cost, grad
;;

let step n iter dim epsilon ystep gains grad y =
  let ymean = zeros dim in
  (* N x D *)
  Array.iteri
    (fun i yrow ->
      Array.iteri
        (fun d _ ->
          let gid = grad.(i).(d) in
          let sid = ystep.(i).(d) in
          let gainid = gains.(i).(d) in
          (* Gain update *)
          let newgain =
            if Float.sign_bit gid = Float.sign_bit sid
            then gainid *. 0.8
            else gainid +. 0.2
          in
          let newgain = if newgain < 0.01 then 0.01 else newgain in
          gains.(i).(d) <- newgain;
          (* Momentum step *)
          let momval = if iter < 250 then 0.5 else 0.8 in
          let newsid = (momval *. sid) -. (epsilon *. newgain *. grad.(i).(d)) in
          ystep.(i).(d) <- newsid;
          (* Step *)
          y.(i).(d) <- y.(i).(d) +. newsid;
          ymean.(d) <- ymean.(d) +. y.(i).(d);
          ())
        yrow)
    y;
  (* Reproject Y to be zero mean *)
  let n = Float.of_int @@ n in
  Array.iteri
    (fun i yrow ->
      Array.iteri (fun d _ -> y.(i).(d) <- y.(i).(d) -. (ymean.(d) /. n)) yrow)
    y
;;

let debug_grad dim iter p_out y =
  let _cost, grad = costgrad dim iter p_out y in
  let e = 1e-5 in
  Array.iteri
    (fun i yrow ->
      Array.iteri
        (fun d _ ->
          let yold = y.(i).(d) in
          y.(i).(d) <- yold +. e;
          let cost0, _grad0 = costgrad dim iter p_out y in
          y.(i).(d) <- yold -. e;
          let cost1, _grad1 = costgrad dim iter p_out y in
          let analytic = grad.(i).(d) in
          let numerical = (cost0 -. cost1) /. (2. *. e) in
          Printf.printf "i:%d|d:%d|analytic:%f|numerical:%f\n" i d analytic numerical;
          y.(i).(d) <- yold)
        yrow)
    y
;;
