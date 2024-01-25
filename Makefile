# Makefile for agda2lagda generated pdfs

# Disable built-in rules
MAKEFLAGS += --no-builtin-rules
.SUFFIXES:

destdir=$(HOME)/public_html

# commands
bibtool=bibtool -- 'preserve.key.case = ON' \
	  -- 'print.use.tab = OFF' \
	  -- 'check.double = ON' \
	  -- 'check.double.delete = ON' \
	  -- 'delete.field = { abstract }' \
	  -- 'delete.field = { dvi }' \
	  -- 'delete.field = { postscript }' \
	  -- 'delete.field = { pdf }' \
	  -- 'delete.field = { month }' \
	  -- 'delete.field = { isbn }' \
	  -- 'delete.field = { doi }' \
	  -- 'delete.field = { note }'
#	  -- 'delete.field = { editor }'

catcfg=sed -e "s/%.*//g" <
latex=latex
pdflatex=xelatex
bibliography=medium.bib

files=Makefile \
  Applicative.lagda.tex \
  latex/agda.sty \
  latex/Applicative.tex

.PRECIOUS : %.pdf %.tex # %.dvi %.ps %.gz

.PHONY: html
html: html/index.html html/Applicative.pdf

html/Applicative.pdf : Applicative.tex template.tex
	tectonic -o html/ $<

# html/index.html: index.md
# 	pandoc --from=markdown --to=html5 --standalone --output=$@ $<

.PHONY: default
default : Applicative.pdf

.PHONY: ship-Applicative
ship-Applicative : $(destdir)/agda/Applicative.pdf

# The generic rule does somehow not work
.PHONY: ship-%
ship-% : $(destdir)/agda/%.pdf

.PHONY: pack
pack : Applicative.zip

Applicative.zip : Applicative.pdf $(files) Applicative.bbl auto-Applicative.bib
	zip $@ $^

%.lagda.tex : src/%.agda
	agda2lagda --force -o $@ $<

latex/%.tex : %.lagda.tex
	agda --latex $<


# Applicative
##################################################################

# Applicative.pdf: Applicative.tex $(files)
# 	latexmk -f -pdf Applicative.tex

# initially, run latex once to create an .aux file
# mark .aux file as fresh by creating a stamp _aux
Applicative_aux : Applicative.tex template.tex # latex/Applicative.tex
	-$(pdflatex) $<;
	touch $@;

# then, run bibtex
Applicative.bbl : Applicative_aux auto-Applicative.bib
	-bibtex Applicative;

# finally, finish by running latex twice again
# this will update .aux, but leave the stamp _aux intact
# (otherwise we would not converge and make would never
# return a "Nothing to do")
Applicative.pdf : Applicative.bbl
	-$(pdflatex) Applicative.tex;
	$(pdflatex) Applicative.tex;

# auto-Applicative.bib is only defined if bibtool is present and all.bib exists

ifneq ($(shell which bibtool),)
ifneq ($(shell ls $(bibliography)),)
auto-Applicative.bib : Applicative_aux $(bibliography)
	echo "%%%% WARNING! AUTOMATICALLY CREATED BIBFILE" > $@;
	echo "%%%% DO NOT EDIT! ALL CHANGES WILL BE LOST!" >> $@ ;
	echo "" >> $@ ;
	$(bibtool) -x Applicative.aux -i $(bibliography) >> $@;
endif
endif

# Templates for the LaTeX build

# then, run bibtex
%.bbl : %_aux auto-%.bib
	-bibtex $*;

# finally, finish by running latex twice again
# this will update .aux, but leave the stamp _aux intact
# (otherwise we would not converge and make would never
# return a "Nothing to do")
%.pdf : %.bbl
	-$(pdflatex) $*.tex;
	$(pdflatex) $*.tex;

# auto-%.bib is only defined if bibtool is present and $(bibliography) exists
ifneq ($(shell which bibtool),)
ifneq ($(shell ls $(bibliography)),)
auto-%.bib : %_aux $(bibliography)
	echo "%%%% WARNING! AUTOMATICALLY CREATED BIBFILE" > $@;
	echo "%%%% DO NOT EDIT! ALL CHANGES WILL BE LOST!" >> $@ ;
	echo "" >> $@ ;
	$(bibtool) -x $*.aux -i $(bibliography) >> $@;
endif
endif

# Templates

$(destdir)/agda/% : %
	cp -p $< $@

talk% : talk%.pdf
	cp -p $? $(destdir)/;
	touch $@;

talk%.pdf : talk%.tex
	pdflatex $<;

# %.tex : %.lhs
# 	lhs2TeX --poly -i lhs2TeX.fmt $< > $@
# # /usr/local/share/lhs2tex-1.13/

% : %.pdf # %.dvi %.ps.gz # %.tar.gz
	cp -p $? $(destdir)/;
	touch $@;

# %.pdf : %.dvi
# 	pdflatex $*.tex;

# %.ps  : %.dvi
# 	dvips -o $@ $<;

# %.gz : %
# 	cat $< | gzip > $@

## does not work since $ is evaluated before %
#%.tar : %.cfg $(shell cat %.cfg)
#	echo $?


#EOF
