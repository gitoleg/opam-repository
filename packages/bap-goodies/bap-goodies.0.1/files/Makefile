.PHONY: mkpath install uninstall

OPAMSHARE = $(shell opam config var share)/emacs/site-lisp

bap-mode.el:
	@test -f bap-mode.el || \
	wget  https://raw.githubusercontent.com/fkie-cad/bap-mode/master/bap-mode.el

emacs-dot.el:
	@test -f dot.el || \
	wget https://raw.githubusercontent.com/ivg/emacs-dot/master/dot.el

bap-goodies.el: bap-mode.el emacs-dot.el
	@echo "(load \"bap-mode\")" >> bap-goodies.el
	@echo "(load \"dot\")" >> bap-goodies.el

mkpath:
	echo "test $(OPAMSHARE)"
	@test -d $(OPAMSHARE) || mkdir -p $(OPAMSHARE)

install: mkpath bap-goodies.el
	cp *.el $(OPAMSHARE)

clean:
	@rm -f *.el

uninstall:
	rm -f $(OPAMSHARE)/bap-mode.el
	rm -f $(OPAMSHARE)/dot.el
	rm -f $(OPAMSHARE)/bap-goodies.el
