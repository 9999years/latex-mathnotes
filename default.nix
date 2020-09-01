{ pkgs ? import <nixpkgs> { } }:
let
  inherit (pkgs) stdenv lib fetchzip fontconfig;

  charter = stdenv.mkDerivation rec {
    pname = "charter";
    version = "200512";

    src = fetchzip {
      url = "https://practicaltypography.com/fonts/Charter%20${version}.zip";
      name = "Charter-${version}.zip";
      sha256 = "1832amplwrxp3cwyf2xnc47f5fasbwhdc2i4sblbhgdgga07pxa0";
    };

    dontConfigure = true;
    dontBuild = true;
    installPhase = ''
      mkdir -p $out/share/fonts
      mv "Charter/OpenType" $out/share/fonts/opentype
      mv "Charter/OpenType TT" $out/share/fonts/truetype
      mv "Charter/WOFF" $out/share/fonts/woff
      mv "Charter license.txt" $out/LICENSE.txt
    '';
  };

  pkg = "mathnotes";
  versionSentinel = "\${VERSION}$";
  dateSentinel = "\${DATE}$";
  build = { pdf ? true, tar ? true, ... }:
    stdenv.mkDerivation rec {
      inherit pkg;
      name = "latex-${pkg}";
      pname = "latex-${pkg}-${versionNumber}";
      versionNumber = "0.1.1";
      date = "2020/09/01";
      version = "${date} ${versionNumber}";

      buildInputs = with pkgs;
        [
          (texlive.combine rec {
            inherit (texlive)
              scheme-small collection-xetex latexmk collection-latexrecommended
              ltxguidex translations framed enumitem showexpl babel babel-german
              babel-english changepage fira varwidth;
          })
          fd
          sd
          just
        ] ++ [ charter ];

      src = ./.;
      distSrcs = [
        "mathnotes.cls"
        "mathnotes-formula-sheet.cls"
        "mathnotes-hw.cls"
        "mathnotes.sty"
        "mathnotes-messages.sty"
        "mathnotes-util.sty"
        "mathnotes.tex"
        "LICENSE.txt"
        "README.md"
        "*.pdf"
      ];

      dontConfigure = true;
      buildPhase = let latexmk = "latexmk -pdf -r ./latexmkrc -pvc- -pv-";
      in ''
        sd --string-mode '${versionSentinel}' '${version}' *.tex *.sty
        sd --string-mode '${dateSentinel}' '${date}' *.tex *.sty
        ${lib.optionalString pdf "${latexmk} *.tex"}

        rm -rf ${pkg}
        mkdir ${pkg}
        cp $distSrcs ${pkg}
      '';

      installPhase = ''
        ${if tar then ''
          tar -czf ${pkg}.tar.gz ${pkg}
          tar -tvf ${pkg}.tar.gz
          cp ${pkg}.tar.gz $out
        '' else ''
          mkdir -p $out
          cp -r ${pkg} $out
        ''}
      '';
    };
in rec {
  tar = build { };
  dir = build {
    pdf = false;
    tar = false;
  };
  dir-pdf = build { tar = false; };
  texlive = {
    pkgs = lib.singleton (dir.overrideAttrs (old: {
      tlType = "run";
      installPhase = old.installPhase + ''
        mkdir -p $out/tex/latex/
        mv $out/${old.pkg} $out/tex/latex/
      '';
    }));
  };
}
