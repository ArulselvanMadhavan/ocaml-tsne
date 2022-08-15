open Js_of_ocaml

class type tSNE =
  object
    method hello : unit -> unit Js.meth
  end

type tSNE_cs = (Js.js_string Js.t -> tSNE Js.t) Js.constr

let tSNE () : tSNE = Js.Unsafe.global##._TSNE
