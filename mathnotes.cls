\NeedsTeXFormat{LaTeX2e}
\RequirePackage{expl3}
\ProvidesExplClass{mathnotes}{2019/10/17}{0.0.1}{Styles for mathematical
  note taking.}

\PassOptionsToClass { openany, oneside } { memoir }

\RequirePackage{kvoptions}

\seq_new:N \g__mn_class_options_seq
\seq_set_from_clist:Nn \g__mn_class_options_seq
  {
    fonts, stix, symbols, maketitle, titles, xcolor, listings, knowledge,
    index, footnotes, figures, tabu,
  }

\DeclareDefaultOption
  {
    \if_meaning:w \CurrentOptionValue \relax
      % The current option is not parsable as a keyval option.
      \seq_if_in:NnTF \g__mn_class_options_seq { \CurrentOption }
        {
          \typeout { Not~a~keyval~option,~passing~to~mathnotes:~\CurrentOption }
          \PassOptionsToPackage { \CurrentOption } { mathnotes }
        }
        {
          \typeout { Not~a~keyval~option,~passing~to~memoir:~\CurrentOption }
          \PassOptionsToClass { \CurrentOption } { memoir }
        }
    \else:
      \seq_if_in:NnTF \g__mn_class_options_seq { \CurrentOptionKey }
        {
          \typeout { Passing~to~mathnotes:~\CurrentOption }
          \PassOptionsToPackage { \CurrentOption } { mathnotes }
        }
        {
          \typeout { Passing~to~memoir:~\CurrentOption }
          \PassOptionsToClass { \CurrentOption } { memoir }
        }
    \fi:
  }

\ProcessKeyvalOptions*

\LoadClass{memoir}
\setsecnumdepth{subsubsection}
\nouppercaseheads
\makeevenfoot { plain } { } { } { }
\makeoddfoot  { plain } { } { } { }
\makeevenhead { plain } { } { } { \thepage }
\makeoddhead  { plain } { } { } { \thepage }

\RequirePackage{etoolbox}
\AtBeginDocument{
    \patchcmd { \@tocmaketitle }
      { \thispagestyle { chapter } }
      { }
      { }
      { }
  }

\RequirePackage{mathnotes}
