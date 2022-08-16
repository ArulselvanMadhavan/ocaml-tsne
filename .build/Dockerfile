FROM ocaml/opam:ubuntu-22.04-ocaml-4.14
ARG USER_NAME
ARG UID
ARG GID
ARG OCAML_COMPILER

USER root
RUN apt-get update
RUN apt-get -y install git build-essential ocaml wget unzip aspcud m4 pkg-config
RUN apt-get -y install libshp-dev libplplot-dev
RUN apt-get -y install libopenblas-dev liblapacke-dev
RUN apt-get -y install libgmp-dev
RUN apt-get -y install emacs tmux fish

USER opam
# Opam installs
RUN opam init -a -y -c ${OCAML_COMPILER} --disable-sandboxing

####################   INSTALL OWL  #######################

ENV OWLPATH /root/owl
ENV OWL_CFLAGS "-g -O3 -Ofast -march=native -funroll-loops -ffast-math -DSFMT_MEXP=19937 -fno-strict-aliasing -Wno-tautological-constant-out-of-range-compare"
ENV EIGENCPP_OPTFLAGS "-Ofast -march=native -funroll-loops -ffast-math"
ENV EIGEN_FLAGS "-O3 -Ofast -march=native -funroll-loops -ffast-math"
RUN opam install owl owl-plplot -y

RUN opam install -y utop merlin
RUN opam install -y js_of_ocaml js_of_ocaml-compiler js_of_ocaml-ppx merlin dune cohttp-lwt-unix conduit-lwt ocamlformat
RUN opam install -y core brr opam-embed-file