\NeedsTeXFormat{LaTeX2e}
\RequirePackage{expl3}
\ProvidesExplClass{mathnotes-formula-sheet}{${DATE}$}{${VERSION}$}{Styles for mathematical
  exam formula sheets.}

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
      \seq_if_in:NnF \g__mn_class_options_seq { \CurrentOption }
        {
          \seq_if_in:NnF \g__mn_class_options_seq { no\CurrentOption }
            {
              \typeout { Not~a~keyval~option,~passing~to~memoir:~\CurrentOption }
              \PassOptionsToClass { \CurrentOption } { article }
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
          \PassOptionsToClass { \CurrentOption } { article }
        }
    \fi:
  }

\ProcessKeyvalOptions*

\LoadClass{article}

\RequirePackage{mathnotes}

\cs_set:Npn \@maketitle
  {
    \textbf{\@title}~
    (\@author,~\@date)
  }

\cs_set:Npn \mn__tiny_thm:nn #1#2
  {
    \RenewDocumentEnvironment { #1 } { o }
      {
        \textbf
          {
            #2
            \IfValueT { ##1 }
              {
                :~##1
              }
            .
          }
      }
      {
      }
  }

\mn__tiny_thm:nn { thm } { Thm }
\mn__tiny_thm:nn { lem } { Lem }
\mn__tiny_thm:nn { cor } { Cor }
\mn__tiny_thm:nn { prop } { Prop }
\mn__tiny_thm:nn { defn } { Defn }
\mn__tiny_thm:nn { ex } { Ex }
\mn__tiny_thm:nn { note } { Note }
\mn__tiny_thm:nn { remark } { Rmrk }

\prg_new_conditional:Npnn \mn__if_should_use_multicols:
  { T, }
  {
    \int_compare:nNnTF
      { \g__mn_fs_columns_int } = { \c_one_int }
      { \prg_return_false: }
      { \prg_return_true: }
  }

\RequirePackage{multicol}
\AtBeginDocument
  {
    \scriptsize
    \mn__if_should_use_multicols:T
      {
        \begin
          {
            multicols
            \bool_if:NF \g__mn_should_balance_multicols_bool
              { * }
          }
          {
            \int_use:N \g__mn_fs_columns_int
          }
      }
    \skip_set:Nn \abovedisplayskip { 0pt }
    \skip_set:Nn \belowdisplayskip { 0pt }
  }

\AtEndDocument
  {
    \mn__if_should_use_multicols:T
      {
        \end
          {
            multicols
            \bool_if:NF \g__mn_should_balance_multicols_bool
              { * }
          }
      }
  }

\bool_new:N \g__mn_should_balance_multicols_bool

\keys_define:nn { mn__main }
  {
    columns .int_set:N = \g__mn_fs_columns_int ,
    columns .initial:x = 3 ,

    balance~columns .default:n = true ,
    balance~columns .bool_set:N = \g__mn_should_balance_multicols_bool ,

    width .value_required:n = true ,
    width .code:n = \geometry{ paperwidth = #1 } ,

    height .value_required:n = true ,
    height .code:n = \geometry{ paperheight = #1 } ,
  }

\RequirePackage
  [
    letterpaper ,
    margin = 0.1in ,
  ]
  { geometry }

\skip_set:Nn \parskip { 0.25em }
