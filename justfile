export date := "2021/11/24"
export version := "1.0.1"
export package := "rbt-mathnotes"

version_token := '\${VERSION}\$'
date_token := '\${DATE}\$'

needs_version := "\
	rbt-mathnotes.tex \
	rbt-mathnotes.sty \
	rbt-mathnotes.cls \
	rbt-mathnotes-util.sty \
	rbt-mathnotes-messages.sty \
	rbt-mathnotes-hw.cls \
	rbt-mathnotes-formula-sheet.cls \
"
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
	@echo "Replacing version placeholder in distribution files."
	cd '{{ package }}' \
	&& sed --in-place --expression 's`{{ version_token }}`{{ version }}`g' {{ needs_version }} \
	&& sed --in-place --expression 's`{{ date_token }}`{{ date }}`g' {{ needs_version }}

_dir-pdf:
	just _dir-no-pdf
	cd '{{ package }}' \
	&& latexmk -xelatex {{ needs_latexmk }} \
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
