# generate a tar distribution
tar:
	nix-build -A tar -o mathnotes.tar.gz

# generate the source directory
dir:
	nix-build -A dir -o mathnotes

# generate the source directory and don't render pdfs
dir-pdf:
	nix-build -A dir-pdf -o mathnotes-pdf

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
		-X rm {} \;
