tar:
	nix-build -A tar -o mathnotes.tar.gz

dir:
	nix-build -A dir -o mathnotes

dir-pdf:
	nix-build -A dir-pdf -o mathnotes-pdf
