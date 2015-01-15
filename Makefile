# Makefile for building and installing the ivy ocaml bindings

DESTDIR ?=

#ifneq ($(DESTDIR),)
#OCAMLFINDFLAGS += -destdir $(DESTDIR)
#endif

# Set to "y" to enable backwards compatibility symlink creation
COMPAT_SYMLINK_CREATE ?= n

# Symlink source path modifier between $(DESTDIR)/`ocamlc -where`
# and [glib]ivy/PKGFILES
# For linux, nothing; for darwin "site-lib/" with trailing slash
COMPAT_SYMLINK_SRCMOD ?=

# Specify default Macports path on OS X
OSX_MACPORTS_PREFIX ?= /opt/local

DEBUG ?= n


OCAMLC = ocamlc
OCAMLMLI = ocamlc
OCAMLOPT = ocamlopt
OCAMLDEP = ocamldep
OCAMLMKLIB = ocamlmklib

ifeq ($(DEBUG),y)
OCAMLFLAGS = -g
else
OCAMLFLAGS =
endif

OCAMLOPTFLAGS=
CFLAGS+=-Wall
OCAMLINC=-I $(shell ocamlc -where)

GLIB_CFLAGS = $(shell pkg-config --cflags glib-2.0)

IVY_CINC = $(shell pkg-config --cflags-only-I ivy-glib)

IVY_CLIBS = $(shell pkg-config --libs ivy-c)
ifeq ($(strip $(IVY_CLIBS)),)
IVY_CLIBS = -livy
endif

IVYGLIB_CLIBS=$(shell pkg-config --libs ivy-glib)
ifeq ($(strip $(IVYGLIB_CLIBS)),)
IVYGLIB_CLIBS = -lglibivy -lglib-2.0
endif

IVYTCL_CLIBS=$(shell pkg-config --libs ivy-tcl)
ifeq ($(strip $(IVYTCL_CLIBS)),)
IVYTCL_CLIBS = -ltclivy
endif

# at least on Debian this is a symlink to the latest tcl version if tcl-dev is installed
TKINC=-I/usr/include/tcl

# by default use fPIC on all systems
FPIC ?= -fPIC

uname_S := $(shell sh -c 'uname -s 2>/dev/null || echo not')
ifeq ($(uname_S),Darwin)
  LIBRARYS = -L$(OSX_MACPORTS_PREFIX)/lib
  IVY_CINC += -I$(OSX_MACPORTS_PREFIX)/include
endif


IVY = ivy.ml ivyLoop.ml

IVYCMO= $(IVY:.ml=.cmo)
IVYCMI= $(IVY:.ml=.cmi)
IVYMLI= $(IVY:.ml=.mli)
IVYCMX= $(IVY:.ml=.cmx)

GLIBIVY = ivy.ml glibIvy.ml

GLIBIVYCMO= $(GLIBIVY:.ml=.cmo)
GLIBIVYCMI= $(GLIBIVY:.ml=.cmi)
GLIBIVYMLI= $(GLIBIVY:.ml=.mli)
GLIBIVYCMX= $(GLIBIVY:.ml=.cmx)

TKIVY = ivy.ml tkIvy.ml

TKIVYCMO= $(TKIVY:.ml=.cmo)
TKIVYCMI= $(TKIVY:.ml=.cmi)
TKIVYMLI= $(TKIVY:.ml=.mli)
TKIVYCMX= $(TKIVY:.ml=.cmx)


IVYLIBS = ivy-ocaml.cma ivy-ocaml.cmxa
GLIBIVYLIBS = glibivy-ocaml.cma glibivy-ocaml.cmxa
TKLIBS = tkivy-ocaml.cma tkivy-ocaml.cmxa

IVYSTATIC = libivy-ocaml.a ivy-ocaml.a
GLIBIVYSTATIC = libglibivy-ocaml.a glibivy-ocaml.a
TKIVYSTATIC = libtkivy-ocaml.a tkivy-ocaml.a
LIBS = ivy-ocaml.cma glibivy-ocaml.cma
XLIBS = ivy-ocaml.cmxa glibivy-ocaml.cmxa


all : $(LIBS) $(XLIBS) $(TKLIBS)

deb :
	dpkg-buildpackage -rfakeroot

ivy : $(IVYLIBS)
glibivy : $(GLIBIVYLIBS)
tkivy : $(TKLIBS)

IVY_ALL_LIBS = $(IVYLIBS) $(IVYSTATIC) dllivy-ocaml.so
GLIBIVY_ALL_LIBS = $(GLIBIVYLIBS) $(GLIBIVYSTATIC) dllglibivy-ocaml.so
TKIVY_ALL_LIBS = $(TKIVYLIBS) $(TKIVYSTATIC) dlltkivy-ocaml.so

IVY_INST_FILES = $(IVYMLI) $(IVYCMI) $(IVYCMX) $(IVY_ALL_LIBS)
GLIBIVY_INST_FILES = $(GLIBIVYMLI) $(GLIBIVYCMI) $(GLIBIVYCMX) $(GLIBIVY_ALL_LIBS)
TKIVY_INST_FILES = $(TKIVYMLI) $(TKIVYCMI) $(TKIVYCMX) $(TKIVY_ALL_LIBS)

install : $(IVY_INST_FILES) $(GLIBIVY_INST_FILES) $(TKIVY_INST_FILES)
	mv META.ivy META && ocamlfind install $(OCAMLFINDFLAGS) ivy META $(IVY_INST_FILES) && mv META META.ivy || (mv META META.ivy && exit 1)
	mv META.glibivy META && ocamlfind install $(OCAMLFINDFLAGS) glibivy META $(GLIBIVY_INST_FILES) && mv META META.glibivy || (mv META META.glibivy && exit 1)
	mv META.tkivy META && ocamlfind install $(OCAMLFINDFLAGS) tkivy META $(TKIVY_INST_FILES) && mv META META.tkivy || (mv META META.tkivy && exit 1)
ifeq ($(COMPAT_SYMLINK_CREATE), y)
	# make some symlinks for backwards compatibility
	@echo "Creating symlinks for backwards compatibility..."
	$(foreach file,$(IVYLIBS) $(IVYSTATIC) $(IVYCMI) $(IVYMLI), \
		cd $(DESTDIR)/`ocamlc -where`; ln -fs $(COMPAT_SYMLINK_SRCMOD)ivy/$(file) $(file);)
	$(foreach file,$(GLIBIVYLIBS) $(GLIBIVYSTATIC) glibIvy.cmi, \
		cd $(DESTDIR)/`ocamlc -where`; ln -fs $(COMPAT_SYMLINK_SRCMOD)glibivy/$(file) $(file);)
endif

uninstall :
	ocamlfind remove ivy
	ocamlfind remove glibivy
	ocamlfind remove tkivy
#	cd `ocamlc -where`; rm -f $(SYMLINKS)

ivy-ocaml.cma : $(IVYCMO) civy.o civyloop.o
	$(OCAMLMKLIB) -o ivy-ocaml $^ $(LIBRARYS) $(IVY_CLIBS)

ivy-ocaml.cmxa : $(IVYCMX) civy.o civyloop.o
	$(OCAMLMKLIB) -o ivy-ocaml $^ $(LIBRARYS) $(IVY_CLIBS)

glibivy-ocaml.cma : $(GLIBIVYCMO) civy.o cglibivy.o
	$(OCAMLMKLIB) -o glibivy-ocaml $^ $(LIBRARYS) $(IVYGLIB_CLIBS) -lpcre

glibivy-ocaml.cmxa : $(GLIBIVYCMX) civy.o cglibivy.o
	$(OCAMLMKLIB) -o glibivy-ocaml $^ $(LIBRARYS) $(IVYGLIB_CLIBS) -lpcre

tkivy-ocaml.cma : $(TKIVYCMO) civy.o ctkivy.o
	$(OCAMLMKLIB) -o tkivy-ocaml $^ $(LIBRARYS) $(IVYTCL_CLIBS)

tkivy-ocaml.cmxa : $(TKIVYCMX) civy.o ctkivy.o
	$(OCAMLMKLIB) -o tkivy-ocaml $^ $(LIBRARYS) $(IVYTCL_CLIBS)


.SUFFIXES:
.SUFFIXES: .ml .mli .mly .mll .cmi .cmo .cmx .c .o .out .opt

.ml.cmo :
	$(OCAMLC) $(OCAMLFLAGS) $(INCLUDES) -c $<
.c.o :
	$(CC) -Wall -c $(FPIC) $(OCAMLINC) $(IVY_CINC) $(TKINC) $(GLIB_CFLAGS) $<
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

.PHONY: all dev ivy glibivy tkivy install uninstall clean

.depend:
	$(OCAMLDEP) $(INCLUDES) *.mli *.ml > .depend

ifneq ($(MAKECMDGOALS),clean)
-include .depend
endif

