val zeros : int -> float array
val randn2d : int -> int -> float option -> float array array
val l2 : float array -> float array -> float
val xtod : float array array -> float array
val d2p : int -> float array -> float -> float -> float array
val costgrad : int -> int -> float array -> float array array -> float * float array array

val step
  :  int
  -> int
  -> int
  -> float
  -> float array array
  -> float array array
  -> float array array
  -> float array array
  -> unit
