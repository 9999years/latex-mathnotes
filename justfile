export date := "2021/11/04"
export version := "1.0.0"
export package := "mathnotes"

version_token := '\${VERSION}\$'
date_token := '\${DATE}\$'

needs_version := "\
	mathnotes.tex \
	mathnotes.sty \
	mathnotes.cls \
	mathnotes-util.sty \
	mathnotes-messages.sty \
	mathnotes-hw.cls \
	mathnotes-formula-sheet.cls \
"
dist_files := "\
	mathnotes.tex \
	mathnotes.sty \
	mathnotes.cls \
	mathnotes-util.sty \
	mathnotes-messages.sty \
	mathnotes-hw.cls \
	mathnotes-formula-sheet.cls \
	LICENSE.txt \
	examples \
"
needs_latexmk := "\
	mathnotes.tex \
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
