{ pkgs ? import <nixpkgs> { } }:
let
  # mathnotes version number and version date
  versionNumber = "0.2.10";
  date = "2020/11/01";

  inherit (pkgs) stdenv lib fetchzip texlive sd;

  charter = stdenv.mkDerivation rec {
    pname = "charter";
    version = "210112";

    src = fetchzip {
      url = "https://practicaltypography.com/fonts/Charter%20${version}.zip";
      name = "Charter-${version}.zip";
      sha256 = "0z5jwvksvpfji90zji48gcby04pwgw8xf37q2i72n4n1wakqrhmf";
    };

    dontConfigure = true;
    dontBuild = true;
    installPhase = ''
      mkdir -p $out/fonts/opentype/public
      mv "OTF format (best for Mac OS)/Charter" \
         $out/fonts/opentype/public/charter
      mv "Charter license.txt" $out/fonts/opentype/public/charter/LICENSE.txt
      # mv "Charter/OpenType TT" $out/share/fonts/truetype
      # mv "Charter/WOFF" $out/share/fonts/woff
    '';

    # needed for texlive...
    tlType = "run";
  };

  charter-texlive = { pkgs = lib.singleton charter; };

  pkg = "mathnotes";
  versionSentinel = "\${VERSION}$";
  dateSentinel = "\${DATE}$";
  build = { pdf ? true, tar ? true, ... }:
    stdenv.mkDerivation rec {
      inherit pkg versionNumber date;
      name = "latex-${pkg}";
      pname = "latex-${pkg}-${versionNumber}";
      version = "${date} ${versionNumber}";

      buildInputs = [
        (texlive.combine rec {
          inherit (texlive)
            scheme-small collection-xetex latexmk collection-latexrecommended
            ltxguidex translations framed enumitem showexpl babel babel-german
            babel-english changepage fira varwidth;
          charter = charter-texlive;
        })
        sd
      ];

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
        sd --string-mode '${versionSentinel}' '${version}' *.tex *.sty *.cls
        sd --string-mode '${dateSentinel}' '${date}' *.tex *.sty *.cls
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
  tar = build { };
  dir = build {
    pdf = false;
    tar = false;
  };
  dir-pdf = build { tar = false; };

  # Copied from nixpkgs.
  combinePkgs = pkgSet:
    lib.concatLists # uniqueness is handled in `texlive.combine`
    (lib.mapAttrsToList (_n: a: a.pkgs) pkgSet);

  mathnotes-texlive-deps = combinePkgs {
    inherit (texlive)
    # article.cls: needed by ./mathnotes-formula-sheet.cls
      latex

      # multicol.sty: needed by ./mathnotes-formula-sheet.cls
      # longtable.sty: needed by ./mathnotes.sty
      tools

      # xparse.sty: needed by:
      #     - ./mathnotes.cls
      #     - ./mathnotes.sty
      l3packages

      # expl3.sty: needed by:
      #     - ./mathnotes-formula-sheet.cls
      #     - ./mathnotes-hw.cls
      #     - ./mathnotes.cls
      #     - ./mathnotes.sty
      #     - ./mathnotes-util.sty
      #     - ./mathnotes-messages.sty
      l3kernel

      geometry # geometry.sty: needed by ./mathnotes-formula-sheet.cls

      #   needed by:
      #     - ./mathnotes-formula-sheet.cls
      #     - ./mathnotes.sty
      enumitem # enumitem.sty

      #   needed by:
      #     - ./mathnotes-formula-sheet.cls
      #     - ./mathnotes.sty
      kvoptions # kvoptions.sty

      memoir # memoir.cls: needed by ./mathnotes.cls
      etoolbox # etoolbox.sty: needed by ./mathnotes.cls and ./mathnotes.sty

      # Needed by mathnotes.sty:
      xkeyval # xkeyval.sty
      mathtools # mathtools.sty
      amsmath # amsmath.sty
      unicode-math # unicode-math.sty
      stix2-otf # Needed when using xelatex (optional, default)
      # stix2-type1 # Needed when using pdflatex (optional, default)
      ntheorem # ntheorem.sty
      listings # listings.sty: Needed with 'listings' option (optional, non-default)
      xcolor # needed by ./mathnotes.sty (optional, default)
      mdframed # mdframed.sty
      zref # zref-abspage.sty: needed by mdframed.sty
      hyperref # hyperref.sty
      knowledge # knowledge.sty
      currfile # currfile.sty: needed by knowledge.sty
      filehook # filehook.sty: needed by currfile.sty
      # needspace
      tabu # tabu.sty: optional, non-default
      booktabs # booktabs.sty
      multirow # multirow.sty
      graphics # graphicx.sty (optional, non-default)
      caption # caption.sty (optional, non-default)
      footmisc # footmisc.sty (optional, non-default)
    ;
  };

in {
  inherit tar dir dir-pdf;
  texlive = {
    pkgs = lib.singleton ((dir.overrideAttrs (old: {
      tlType = "run";
      installPhase = old.installPhase + ''
        mkdir -p $out/tex/latex/
        mv $out/${old.pkg} $out/tex/latex/
      '';
    }))) ++ mathnotes-texlive-deps;
  };
  mathnotes-transitive = stdenv.mkDerivation {
    pname = "mathnotes";
    version = "0.0.0";
    src = ./.;
    buildInputs = [
      (texlive.combine ({
        inherit (texlive)
          collection-latex # Stuff i don't want to deal with.
          latexmk;
        mathnotes-deps = { pkgs = mathnotes-texlive-deps; };
      }))
    ];
  };
}
