%${LICENSE}$
\NeedsTeXFormat{LaTeX2e}
\RequirePackage{expl3}
\ProvidesExplClass{rbt-mathnotes-hw}{${DATE}$}{${VERSION}$}{Companion styles
  to rbt-mathnotes for typeset homework assignments.}

% \PassOptionsToPackage{noxcolor}{rbt-mathnotes}

\RequirePackage{kvoptions}
\DeclareDefaultOption
  {
    \PassOptionsToClass { \CurrentOption } { rbt-mathnotes }
  }
\ProcessKeyvalOptions*

\LoadClass { rbt-mathnotes }

\cs_set:Npn \mn__undefine_thm:n #1
  {
    \cs_undefine:c { #1 }
    \cs_undefine:c { end#1 }
    \cs_undefine:c { #1* }
    \cs_undefine:c { end#1* }
  }

\mn__undefine_thm:n { thm }
\mn__undefine_thm:n { lem }
\mn__undefine_thm:n { cor }
\mn__undefine_thm:n { prop }
\mn__undefine_thm:n { defn }
\mn__undefine_thm:n { notation }
\mn__undefine_thm:n { ex }

\cs_undefine:N \mn__undefine_thm:n

\theoremstyle { definition }
\newtheorem { thm } { Theorem }
\newtheorem { lem } { Lemma }
\newtheorem { cor } { Corollary }
\newtheorem { prop } { Proposition }
\newtheorem { defn } { Definition }
\newtheorem { notation } { Notation }
\newtheorem { ex } { Example }

% The displayed problem number. \g__mn_problems_int isn't incremented if a
% custom number is given.
\int_new:N \g__mn_problems_int
\int_set_eq:NN \g__mn_problems_int \c_one_int

% The internal problem number. \g__mn_all_problems_int is *always*
% incremented, so it can be used as a unique identifier in hyperref
% pdf bookmark names.
\int_new:N \g__mn_all_problems_int
\int_set_eq:NN \g__mn_all_problems_int \c_one_int

% Label prepended to problem numbers.
\tl_const:Nn \g__mn_problem_string_tl { Problem }

\skip_const:Nn \g__mn_problem_before_skip { 2em }

% Label appended to problem numbers; omitted from PDF bookmarks.
\tl_const:Nn \g__mn_problem_after_tl { . }

% A possible custom problem number. If \c_novalue_tl, use
% \g__mn_problems_int instead.
\tl_new:N \mn__problem_number_tl
\tl_set_eq:NN \mn__problem_number_tl \c_novalue_tl

\tl_const:Nn \mn__problem_number_default_tl
  {
    \int_to_arabic:n { \g__mn_problems_int }
  }

% Current problem number, either from \g__mn_problems_int or
% \mn__problem_number_tl.
\tl_new:N \mn__problem_number_current_tl

% Current problem display title, including "problem" label, number, and
% custom title.
% \tl_new:N \mn__problem_display_title_tl

\keys_define:nn { mn__main }
  {
    problem~string .value_required:n = true ,
    problem~string .tl_set:N = \g__mn_problem_string_tl ,
    problem~before~skip .skip_set:N = \g__mn_problem_before_skip
  }

\keys_define:nn { mn__problem }
  {
    number .value_required:n = true ,
    number .tl_set:N = \mn__problem_number_tl ,

    title .value_required:n = true ,
    title .tl_set:N = \mn__problem_title_tl ,
    title .initial:n = ,

    label .value_required:n = true ,
    label .tl_set:N = \mn__problem_label_tl ,

    % Treat unknown keys as the problem number; this lets us avoid having
    % 2 or more optional arguments.
    unknown .code:n =
      \tl_if_empty:nTF { #1 }
        {
          % No value; use it for the problem number.
          \tl_set_eq:NN \mn__problem_number_tl \l_keys_key_tl
        }
        {
          % Non-empty value; give an error.
          \msg_error:nnx
            { mathnotes }
            { no key in problem }
            { \tl_use:N \l_keys_key_tl }
        } ,
  }

\cs_set:Npn \mn__problem_title_pdf:
  {
    % A string like "Problem" or "Exercise" or "Question"
    \tl_use:N \g__mn_problem_string_tl
    % The problem number.
    \tl_if_empty:NF \mn__problem_number_current_tl
      {
        \ \tl_use:N \mn__problem_number_current_tl
      }
    \tl_if_empty:NF \mn__problem_title_tl
      {
        :~\tl_use:N \mn__problem_title_tl
      }
  }

\cs_set:Npn \mn__problem_title:
  {
    \mn__problem_title_pdf:
    % The text after the problem, nominally a period (".").
    \tl_use:N \g__mn_problem_after_tl
  }

% PDF anchor / bookmark name for hyperref.
\cs_set:Npn \mn__problem_anchor:
  {
    problem.\int_to_arabic:n { \g__mn_all_problems_int }
  }

\NewDocumentEnvironment { problem }
  {
    O{} % Problem number or options
  }
  {
    \keys_set:nn { mn__problem } { #1 }

    % Set the problem number
    \tl_set:Nn \mn__problem_number_current_tl { }
    \tl_if_eq:NNTF \mn__problem_number_tl \c_novalue_tl
      {
        % No number given
        \tl_set_eq:NN \mn__problem_number_current_tl \mn__problem_number_default_tl
      }
      {
        % Some number given, *maybe* empty
        \tl_set_eq:NN \mn__problem_number_current_tl \mn__problem_number_tl
      }

    \vspace { \skip_use:N \g__mn_problem_before_skip }

    \phantomsection
    \addcontentsline
      { toc }
      { chapter }
      { \mn__problem_title_pdf: }
    \begin{mdframed}
      [
        style = note ,
        startinnercode =
          \mn__note_title:n
            {
              \cs_gset:Npx \@currentlabel { \tl_use:N \mn__problem_number_current_tl }
              \cs_gset:Npx \@currentlabelname { \mn__problem_title: }
              \tl_if_empty:NF \mn__problem_label_tl
                {
                  \exp_after:wN \label { \tl_use:N \mn__problem_label_tl }
                }
              \mn__problem_title:
            }
          ,
      ]
  }
  {
    \end{mdframed}
    % If we didn't get a custom number, increment the counter.
    \tl_if_eq:NNT \mn__problem_number_tl \c_novalue_tl
      {
        \int_gincr:N \g__mn_problems_int
      }
    % But always increment the internal counter.
    \int_gincr:N \g__mn_all_problems_int
  }

\NewDocumentCommand \prob
  {
    O{} % Problem number or options
    m % Problem text
  }
  {
    \begin{problem}[#1]
      #2
    \end{problem}
  }

\cs_set:Npn \mn__add_par_arg_to_sectioning_cmd:N #1
  {
    \cs_set_eq:cN { mn__\cs_to_str:N #1 _old } #1
    \cs_set_eq:cc
      { mn__the\cs_to_str:N #1 _old }
      { the\cs_to_str:N #1 }
    \RenewDocumentCommand #1
      {
        s % ##1: Numbered / in ToC?
        d() % ##2: Number override.
        o % ##3: ToC title.
        o % ##4: Page header title.
        m % ##5: Title.
      }
      {
        \group_begin:
        \cs_set:Npx \mn__current_thesection_cmd
          { the\cs_to_str:N #1 }
        % Is there a number override?
        \IfValueTF { ##2 }
          {
            % If yes, *globally* change the number format.
            \cs_gset:cpn { \mn__current_thesection_cmd } { ##2 }
          }
          {
            % Otherwise, restore the number format from a previous override,
            % if applicable.
            \cs_gset_eq:cc
              { \mn__current_thesection_cmd }
              { mn__the\cs_to_str:N #1 _old  }
          }
        % Save the original command so we can use it as a single token.
        \cs_set_eq:Nc \mn__orig_sectioning_cmd { mn__\cs_to_str:N #1 _old }
        \exp_last_unbraced:Ne \mn__orig_sectioning_cmd
          {
            % Propagate the star.
            \IfBooleanT { ##1 } { * }
            % Propogate other arguments.
            \IfValueT { ##3 } { [##3] }
            \IfValueT { ##4 } { [##4] }
            { ##5 }
          }
        \group_end:
      }
  }

\cs_set:Npn \mn__add_par_arg_to_sectioning_cmds:n #1
  {
    \clist_map_function:nN { #1 } \mn__add_par_arg_to_sectioning_cmd:N
  }

\makeheadstyles { rbt-mathnotes-hw }
  {
    \chapterstyle { rbt-mathnotes }
    \headstyles { rbt-mathnotes }

    % Don't use chapter numbers in sections and beyond:
    \cs_set:Npn \thesection { \arabic{section} }

    % Add paren-arg to override numbers in sectioning commands.
    \mn__add_par_arg_to_sectioning_cmds:n
      {
        \chapter ,
        \section ,
        \subsection ,
        \subsubsection ,
        \paragraph ,
        \subparagraph ,
      }
  }

\headstyles { rbt-mathnotes-hw }

\setlength{\columnsep}{3em}

% No chapter numbers for figures.
\counterwithout{figure}{chapter}

% Put author name, title in headings
\makeevenfoot { headings } { } { } { }
\makeoddfoot  { headings } { } { } { }
\makeevenhead { headings } { } { } { \thepage }
\makeoddhead  { headings } { \@author,~\textit{ \@title } } { } { \thepage }
