export DATE := "2021/11/29"
export VERSION := "1.0.2"
package := "rbt-mathnotes"

# Must be files or directories in this folder (the repo's top level);
# `dist_files` is passed as arguments to `cp`, so need to use single names to
# preserve directory structure.
dist_files := "\
	rbt-mathnotes.tex \
	rbt-mathnotes.sty \
	rbt-mathnotes.cls \
	rbt-mathnotes-util.sty \
	rbt-mathnotes-messages.sty \
	rbt-mathnotes-hw.cls \
	rbt-mathnotes-formula-sheet.cls \
	README.md \
	LICENSE.txt \
	examples \
"
# Filenames to substitute ${LICENSE}$ in.
needs_substitutions := "\
	rbt-mathnotes.tex \
	rbt-mathnotes.sty \
	rbt-mathnotes.cls \
	rbt-mathnotes-util.sty \
	rbt-mathnotes-messages.sty \
	rbt-mathnotes-hw.cls \
	rbt-mathnotes-formula-sheet.cls \
	README.md \
	LICENSE.txt \
	examples/cheat-sheet.tex \
	examples/multivar.tex \
	examples/topology-hw-1.tex \
"
needs_latexmk := "\
	rbt-mathnotes.tex \
	examples/cheat-sheet.tex \
	examples/multivar.tex \
	examples/topology-hw-1.tex \
"

dist:
	just _dir-pdf
	tar -czvf '{{ package }}.tar.gz' '{{ package }}'

_dir-no-pdf:
	mkdir -p '{{ package }}'
	cp -r -t '{{ package }}' {{ dist_files }}
	@echo "Replacing version/date/license placeholders in distribution files."
	cd '{{ package }}' \
	&& ../substitute.py {{ needs_substitutions }}

_dir-pdf:
	just _dir-no-pdf
	cd '{{ package }}' \
	&& latexmk -norc -xelatex {{ needs_latexmk }} \
	&& mv cheat-sheet.pdf multivar.pdf topology-hw-1.pdf examples/ \
	&& just clean


# remove generated TeX files, recursively
clean:
	fd . \
		--no-ignore-vcs \
		--type f \
		-e "log" \
		-e "aux" \
		-e "aux" \
		-e "nav" \
		-e "snm" \
		-e "dvi" \
		-e "toc" \
		-e "fls" \
		-e "out" \
		-e "fdb_latexmk" \
		-e "bbl" \
		-e "bbg" \
		-e "blg" \
		-e "bcf" \
		-e "thm" \
		-e "idx" \
		-e "ilg" \
		-e "ind" \
		-e "kaux" \
		-e "diagnose" \
		-e "synctex.gz" \
		-e "xdv" \
		-e "tmp" \
		-X rm {} \;

# Remove generated files and archives as well as build artifacts.
clean-all:
	rm -rf '{{ package }}'
	rm -rf '{{ package }}.tar.gz'
	just clean
