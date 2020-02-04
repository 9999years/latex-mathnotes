\NeedsTeXFormat{LaTeX2e}
\RequirePackage{expl3}
\ProvidesExplClass{mathnotes}{${DATE}$}{${VERSION}$}{Styles for mathematical
  note taking.}

\PassOptionsToClass { openany, oneside } { memoir }

\RequirePackage{kvoptions}

\seq_new:N \g__mn_class_options_seq
\seq_set_from_clist:Nn \g__mn_class_options_seq
  {
    fonts, stix, symbols, maketitle, titles, xcolor, listings, knowledge,
    index, footnotes, figures, tabu, kindle,
  }

\DeclareDefaultOption
  {
    \if_meaning:w \CurrentOptionValue \relax
      % The current option is not parsable as a keyval option.
      \seq_if_in:NnF \g__mn_class_options_seq { \CurrentOption }
        {
          \seq_if_in:NnF \g__mn_class_options_seq { no\CurrentOption }
            {
              \typeout { Not~a~keyval~option,~passing~to~memoir:~\CurrentOption }
              \PassOptionsToClass { \CurrentOption } { memoir }
              \use_none:n
            }
        }
      {
        \typeout { Not~a~keyval~option,~passing~to~mathnotes:~\CurrentOption }
        \PassOptionsToPackage { \CurrentOption } { mathnotes }
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
\settocdepth{subsubsection}
\nouppercaseheads
\makeevenfoot { plain } { } { } { }
\makeoddfoot  { plain } { } { } { }
\makeevenhead { plain } { } { } { \thepage }
\makeoddhead  { plain } { } { } { \thepage }

\RequirePackage{etoolbox}
\RequirePackage{xparse}
\AtBeginDocument{
    \patchcmd { \@tocmaketitle }
      { \thispagestyle { chapter } }
      { }
      { }
      { }
  }

\makechapterstyle { mathnotes }
  {
    % allow for 99 chapters!
    \settowidth{\chapindent}{\chapnumfont 999}

    \RenewDocumentCommand \chapnumfont { }
      {
        \normalfont
        \huge
        \exp:w \mn__color:n {MNsecnum}
      }
    \RenewDocumentCommand \chapterheadstart { } { }
    \RenewDocumentCommand \printchaptername { } { }
    \RenewDocumentCommand \chapternamenum   { } { }
    \RenewDocumentCommand \printchapternum  { }
      {
        \noindent
        \llap
          {
            \makebox [ \chapindent ]
              { \chapnumfont \thechapter }
          }
      }
    \RenewDocumentCommand \afterchapternum  { } { }
    \RenewDocumentCommand \printchaptertitle { m }
      {
        \raggedright
        \huge
        ##1
      }
    \RenewDocumentCommand \afterchaptertitle { }
      {
        \vskip \onelineskip
        \hrule
        \vskip \onelineskip
      }
  }

\makeheadstyles { mathnotes }
  {
    \chapterstyle { mathnotes }

    \setsecnumformat
      {
        \group_begin:
        \exp:w \mn__color:n {MNsecnum}
        \cs:w the##1 \cs_end:
        \quad
        \group_end:
      }

    % Sections.
    \setbeforesecskip
      {
          -1\onelineskip plus -0.5\onelineskip minus -0.5\onelineskip
      }
    \setaftersecskip
      {
        1\onelineskip plus 0.1\onelineskip
      }
    \setsecheadstyle
      {
        \normalfont
        \memRTLraggedright
        \bfseries
        \LARGE
        % \scshape
        % \MakeTextLowercase
      }

    % Subsections.
    \setbeforesubsecskip
      {
        -1.0\onelineskip plus -0.25\onelineskip minus -0.25\onelineskip
      }
    \setaftersubsecskip
      {
        1.0\onelineskip plus 0.1\onelineskip
      }
    \setsubsecheadstyle
      {
        \sethangfrom { \noindent ####1 }
        \normalfont
        \bfseries
        \memRTLraggedright
      }

    % Subsubsections.
    \setbeforesubsubsecskip
      {
        1.0\onelineskip plus 0.5\onelineskip minus 0.2\onelineskip
      }
    \setaftersubsubsecskip
      {
        1.0\onelineskip plus 0.1\onelineskip
      }
    \setsubsubsecheadstyle
      {
        \normalfont
        \normalsize
        \bfseries
        \memRTLraggedright
      }

    % Paragraphs.
    \setbeforeparaskip
      {
        1.0\onelineskip plus 0.5\onelineskip minus 0.2\onelineskip
      }
    \setafterparaskip { -1em }
    \setparaheadstyle
      {
        \normalfont
        \normalsize
        \bfseries
      }

    % Subparagraphs.
    \setsubparaindent { \parindent }
    \setbeforesubparaskip
      {
        1.0\onelineskip plus 0.5\onelineskip minus 0.2\onelineskip
      }
    \setaftersubparaskip { -1em }
    \setsubparaheadstyle
      {
        \normalfont
        \normalsize
        \itshape
        \addperiod
      }
  }

\headstyles { mathnotes }

% \chapterstyle{hangnum}
% \cs_set:Npn \chapnumfont
  % {
    % \HUGE \bfseries
    % \exp:w \mn__color:n {MNsecnum}
  % }

\RequirePackage{mathnotes}
