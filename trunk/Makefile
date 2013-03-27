# $Id$

DESTDIR = /

DEBUG  = n


OCAMLC = ocamlc
OCAMLMLI = ocamlc
OCAMLOPT = ocamlopt -unsafe
OCAMLDEP = ocamldep
OCAMLMKLIB = ocamlmklib

ifeq ($(DEBUG),y)
OCAMLFLAGS = -g
else
OCAMLFLAGS =
endif

OCAMLOPTFLAGS=
CFLAGS+=-Wall
OCAMLINC=-I `ocamlc -where`
GLIBINC=`pkg-config --cflags glib-2.0`

LBITS := $(shell getconf LONG_BIT)
ifeq ($(LBITS),64)
  FPIC=-fPIC
endif

OUTDIR = ivy


IVY = ivy.ml ivyLoop.ml

IVYCMO= $(IVY:.ml=.cmo)
IVYCMI= $(IVY:.ml=.cmi)
IVYMLI= $(IVY:.ml=.mli)
IVYCMX= $(IVY:.ml=.cmx)

GLIBIVY = ivy.ml glibIvy.ml

GLIBIVYCMO= $(GLIBIVY:.ml=.cmo)
GLIBIVYCMI= $(GLIBIVY:.ml=.cmi)
GLIBIVYCMX= $(GLIBIVY:.ml=.cmx)

TKIVY = ivy.ml tkIvy.ml

TKIVYCMO= $(TKIVY:.ml=.cmo)
TKIVYCMI= $(TKIVY:.ml=.cmi)
TKIVYCMX= $(TKIVY:.ml=.cmx)

UNAME = $(shell uname -s)

ifeq ("$(UNAME)","Darwin")
  LIBRARYS = -L/opt/local/lib
endif

LIBS = ivy-ocaml.cma glibivy-ocaml.cma
XLIBS = ivy-ocaml.cmxa glibivy-ocaml.cmxa
TKLIBS = tkivy.cma tkivy.cmxa
STATIC = libivy-ocaml.a libglibivy-ocaml.a ivy-ocaml.a glibivy-ocaml.a
GLIBIVYCMI = glibIvy.cmi
METAFILES = META.ivy META.glibivy

all : $(LIBS) $(XLIBS)

deb :
	dpkg-buildpackage -rfakeroot

ivy : ivy-ocaml.cma ivy-ocaml.cmxa
glibivy : glibivy-ocaml.cma glibivy-ocaml.cma
tkivy : $(TKLIBS)

INST_FILES = $(IVYCMI) $(IVYMLI) $(GLIBIVYCMI) $(LIBS) $(XLIBS) $(STATIC)
# tkIvy.cmi  libtkivy.a  dlltkivy.so tkivy.a
STUBLIBS = dllivy-ocaml.so dllglibivy-ocaml.so

install : $(LIBS)
	mkdir -p $(DESTDIR)/`ocamlc -where`/$(OUTDIR)
	cp $(INST_FILES) $(DESTDIR)/`ocamlc -where`/$(OUTDIR)
	mkdir -p $(DESTDIR)/`ocamlc -where`/stublibs
	cp $(STUBLIBS) $(DESTDIR)/`ocamlc -where`/stublibs
	mkdir -p $(DESTDIR)/`ocamlc -where`/METAS
	cp $(METAFILES) $(DESTDIR)/`ocamlc -where`/METAS
	mkdir -p $(DESTDIR)/`ocamlc -where`
	$(foreach file,$(LIBS) $(XLIBS) $(STATIC) $(IVYCMI) $(IVYMLI) $(GLIBIVYCMI), \
		cd $(DESTDIR)/`ocamlc -where`; ln -s ivy/$(file) $(file);)

desinstall :
	cd `ocamlc -where`; rm -f $(INST_FILES); rm -f METAS/$(METAFILES)

ivy-ocaml.cma : $(IVYCMO) civy.o civyloop.o
	$(OCAMLMKLIB) -o ivy-ocaml $^ $(LIBRARYS)  -livy

ivy-ocaml.cmxa : $(IVYCMX) civy.o civyloop.o
	$(OCAMLMKLIB) -o ivy-ocaml $^ $(LIBRARYS)  -livy

glibivy-ocaml.cma : $(GLIBIVYCMO) civy.o cglibivy.o
	$(OCAMLMKLIB) -o glibivy-ocaml $^ $(LIBRARYS) -lglibivy  `pkg-config --libs glib-2.0` -lpcre

glibivy-ocaml.cmxa : $(GLIBIVYCMX) civy.o cglibivy.o
	$(OCAMLMKLIB) -o glibivy-ocaml $^ $(LIBRARYS) -lglibivy `pkg-config --libs glib-2.0` -lpcre

tkivy-ocaml.cma : $(TKIVYCMO) civy.o ctkivy.o
	$(OCAMLMKLIB) -o tkivy-ocaml $^ $(LIBRARYS) -livy -ltclivy

tkivy-ocaml.cmxa : $(TKIVYCMX) civy.o ctkivy.o
	$(OCAMLMKLIB) -o tkivy-ocaml $^ $(LIBRARYS) -livy -ltclivy


.SUFFIXES:
.SUFFIXES: .ml .mli .mly .mll .cmi .cmo .cmx .c .o .out .opt

.ml.cmo :
	$(OCAMLC) $(OCAMLFLAGS) $(INCLUDES) -c $<
.c.o :
	$(CC) -Wall -c $(FPIC) -I /opt/local/include/  $(OCAMLINC) $(GLIBINC) $<
.mli.cmi :
	$(OCAMLMLI) $(OCAMLFLAGS) -c $<
.ml.cmx :
	$(OCAMLOPT) $(OCAMLOPTFLAGS) -c $<
.mly.ml :
	ocamlyacc $<
.mll.ml :
	ocamllex $<
.cmo.out :
	$(OCAMLC) -custom -o $@ unix.cma -I . ivy.cma $< -cclib -livy
.cmx.opt :
	$(OCAMLOPT) -o $@ unix.cmxa -I . ivy.cmxa $< -cclib -livy

clean:
	\rm -fr *.cm* *.o *.a .depend *~ *.out *.opt .depend *.so *-stamp debian/ivy-ocaml debian/files debian/ivy-ocaml.debhelper.log debian/ivy-ocaml.substvars debian/*~

.depend:
	$(OCAMLDEP) $(INCLUDES) *.mli *.ml > .depend

include .depend
