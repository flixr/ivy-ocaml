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

LIBS = ivy.cma ivy.cmxa glibivy.cma glibivy.cmxa
# tkivy.cma tkivy.cmxa
METAFILE = META.ivy

all : $(LIBS)

deb :
	dpkg-buildpackage -rfakeroot

ivy : ivy.cma ivy.cmxa
glibivy : glibivy.cma glibivy.cmxa
tkivy : tkivy.cma tkivy.cmxa

INST_FILES = $(IVYCMI) $(IVYMLI) glibIvy.cmi $(LIBS) libivy.a libglibivy.a ivy.a glibivy.a
# tkIvy.cmi  libtkivy.a  dlltkivy.so tkivy.a
STUBLIBS = dllivy.so dllglibivy.so

install : $(LIBS)
	mkdir -p $(DESTDIR)/`ocamlc -where`/$(OUTDIR)
	cp $(INST_FILES) $(DESTDIR)/`ocamlc -where`/$(OUTDIR)
	mkdir -p $(DESTDIR)/`ocamlc -where`/stublibs
	cp $(STUBLIBS) $(DESTDIR)/`ocamlc -where`/stublibs
	mkdir -p $(DESTDIR)/`ocamlc -where`/METAS
	cp $(METAFILE) $(DESTDIR)/`ocamlc -where`/METAS
	mkdir -p $(DESTDIR)/`ocamlc -where`
	$(foreach file,$(INST_FILES), cd $(DESTDIR)/`ocamlc -where`; ln -s ivy/$(file) $(subst .cm,-ocaml.cm,$(file));)

desinstall :
	cd `ocamlc -where`; rm -f $(INST_FILES); rm -f METAS/$(METAFILE)

ivy.cma : $(IVYCMO) civy.o civyloop.o
	$(OCAMLMKLIB) -o ivy $^ $(LIBRARYS)  -livy

ivy.cmxa : $(IVYCMX) civy.o civyloop.o
	$(OCAMLMKLIB) -o ivy $^ $(LIBRARYS)  -livy

glibivy.cma : $(GLIBIVYCMO) civy.o cglibivy.o
	$(OCAMLMKLIB) -o glibivy $^ $(LIBRARYS) -lglibivy  `pkg-config --libs glib-2.0` -lpcre

glibivy.cmxa : $(GLIBIVYCMX) civy.o cglibivy.o
	$(OCAMLMKLIB) -o glibivy $^ $(LIBRARYS) -lglibivy `pkg-config --libs glib-2.0` -lpcre

tkivy.cma : $(TKIVYCMO) civy.o ctkivy.o
	$(OCAMLMKLIB) -o tkivy $^ $(LIBRARYS) -livy -ltclivy

tkivy.cmxa : $(TKIVYCMX) civy.o ctkivy.o
	$(OCAMLMKLIB) -o tkivy $^ $(LIBRARYS) -livy -ltclivy


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
