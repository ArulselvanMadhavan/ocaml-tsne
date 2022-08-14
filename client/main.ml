let print_mat mat =
  Array.iter
    (fun v ->
      let row = Array.fold_left (fun acc vv -> Printf.sprintf "%s,%f" acc vv) "" v in
      Printf.printf "%s\n" row)
    mat
;;

let print_arr arr = Array.iter (fun v -> Printf.printf "%f," v) arr

let () =
  print_string "Hello JS World!\n";
  let mat = Utils.randn2d 10 10 in
  print_mat mat;
  Printf.printf "L2:%f\n" @@ Utils.l2 mat.(0) mat.(7);
  Printf.printf "XtoD\n";
  print_arr (Utils.xtod mat)
;;
