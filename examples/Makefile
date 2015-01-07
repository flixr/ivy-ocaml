# $Id$

OCAMLC = ocamlfind ocamlc -I ..
OCAMLMLI = ocamlfind ocamlc -I ..
OCAMLOPT = ocamlfind ocamlopt
OCAMLDEP = ocamlfind ocamldep

all: ivyprobe.out glibivyprobe.out tkivyprobe.out

ivyprobe.out : ivyprobe.cmo ivyivyprobe.cmo
	$(OCAMLC) -custom -o $@ unix.cma ivy-ocaml.cma $^

glibivyprobe.out : ivyprobe.cmo glibivyprobe.cmo
	$(OCAMLC) -custom -o $@ unix.cma glibivy-ocaml.cma $^

tkivyprobe.out : ivyprobe.cmo tkivyprobe.cmo
	$(OCAMLC) -custom -o $@ unix.cma -I +labltk labltk.cma tkivy-ocaml.cma $^

tkivyprobe.cmo : tkivyprobe.ml
	$(OCAMLC) -package unix,labltk -c $<

%.cmo : %.ml
	$(OCAMLC) -c $<

clean:
	\rm -f *.cm* *.o *.a .depend *~ *.out *.opt .depend *.so

.depend:
	$(OCAMLDEP) $(INCLUDES) *.mli *.ml > .depend

include .depend
