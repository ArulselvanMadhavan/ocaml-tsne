let () =
  print_string "Hello JS World!\n";
  let mat = Utils.randn2d 10 10 in
  Array.iter (fun v -> Array.iter (fun vv -> Printf.printf "%f;" vv) v) mat
;;
