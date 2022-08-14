let () =
  print_string "Hello JS World!\n";
  let mat = Utils.randn2d 10 10 in
  Array.iter
    (fun v ->
      let row = Array.fold_left (fun acc vv -> Printf.sprintf "%s,%f" acc vv) "" v in
      Printf.printf "%s\n" row)
    mat;
  Printf.printf "L2:%f\n" @@ Utils.l2 mat.(0) mat.(7)
;;
