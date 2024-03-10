*** DO-FILE:       TALES ****************************************************
*** PROJECT NAME:  Master's Thesis ******************************************
*** DATE: 		   28.12.2023 ***********************************************
*** AUTHOR: 	   JG *******************************************************

* Note: The purpose of this do-file is to create the result tables


*****************************************************************************
*** SECTION 3.1 - TABLES ****************************************************

// This file creates a LaTeX document including tables with the analysis results, that I will use in the master thesis
cd "$data"
texdoc init 3.1.tables.tex, replace

/*tex
\begin{comment}
\begin{table}[H]
\begin{threeparttable}
\caption{Treatment Effect of the PIS on Rice Production of Treated Farmers (PDS-Lasso)}
\begin{tabular}{cccccc}
\hline\hline \multirow[t]{2}{*}{ (1) } & (2) & (3) & (4) & (5) & (6) \T \\
\multicolumn{4}{c}{$\triangle$ Rice production} & \makecell{$\triangle$ } & \makecell{$\triangle$ \\} \\
\cline{1-4} \noalign{\vskip 1mm} \makecell{(Log) \\  Expendi- \\ tures \\ (PPP-\$) \B} & \makecell{(Log) \\ Area \\ \\ (Rai) \B} & \makecell{(Log) \\ Agri. \\ assets \\ (Value) \B} & \makecell{(Log) \\ Total \\ produce \\ (Kg) \B} & \makecell{Production \\ index, \\  based on \\ (1) to (4) \B} & \makecell{(Log) \\ Produce \\ sold \\ (Kg) \B} \\
\hline \multicolumn{6}{c}{ Panel A: Short-term effects (2010 vs. 2008)} \T \B \\
\hline \input{infile/dataset_v3.131.noQU.tex} \T \\
\input{infile/dataset_v3.132.noQU.tex} \B \\
\hline \multicolumn{6}{c}{ Panel B: Medium-term effects (2013 vs. 2008)} \T \B \\
\hline \input{infile/dataset_v3.151.noQU.tex} \T \\
\input{infile/dataset_v3.152.noQU.tex} \B \\
\hline\hline
\end{tabular}
\end{threeparttable}
\end{table}
\end{comment}

\begin{comment} Test 2
\begin{table}[H]
\begin{threeparttable}
\caption{Treatment Effects of the PIS on Treated Farmers (PDS-Lasso). Possible Coupling Mechanisms: Land and Labor Allocation}
\begin{tabular}{ccccccc}
\hline \hline (1) & (2) & (3) & (4) & (5) & (6) & (7) \T \B \\
\makecell{$\triangle$ Land \\  used for} & \multicolumn{4}{c}{\makecell{$\triangle$ Number of income generating \\ activities in ... }} & \makecell{$\triangle$ \\ Activity} & \makecell{$\triangle$ HH \\ members} \\
\cline{2-5} \noalign{\vskip 0.5mm} \makecell{rice cul- \\ tivation \\ (share) \\ \\} & \makecell{Livestock \\ products \\ \\ \\} & \makecell{Resource \\ extrac- \\ tion \\ \\} & \makecell{Wage \\ employ- \\ ment \\ \\} & \makecell{Self- \\ employment \\ \\ \\} & \makecell{index, \\ based on \\ (2) to (5) \\ \\} & \makecell{temp. gone \\ for job/ \\ job search \\ (share)} \\
\hline \multicolumn{7}{c}{ Panel A: Short-term effects (2010 vs. 2008)} \T \B \\
\hline \input{infile/dataset_v3.231.tex} \T \\
\input{infile/dataset_v3.232.noQU.tex} \B \\
\hline \multicolumn{7}{c}{ Panel B: Medium-term effects (2013 vs. 2008)} \T \B \\
\hline \input{infile/dataset_v3.251.tex} \T \\
\input{infile/dataset_v3.252.noQU.tex} \B \\
\hline \hline
\end{tabular}
\end{threeparttable}
\end{table}
\end{comment}

\begin{comment} Test
\begin{table}[H]
\begin{threeparttable}
\caption{Treatment Effects of the PIS on Treated Farmers (PDS-Lasso). Possible Coupling Mechanisms: Wealth, Risk Aversion, and Credit Constraints}
\begin{tabular}{ccc}
\hline \hline (1) & (2) & (3) \T \B \\
\makecell{$\triangle$ Income \\ from public \\ transfers \\ (incl. PIS) \B} & \makecell{$\triangle$ Risk\\ attitude \\ \\ \\} & \makecell{$\triangle$ Agri \\ loans \\ (Yes=1) \\ \\} \\
\hline \multicolumn{3}{c}{ Panel A: Short-term effects (2010 vs. 2008) \T \B} \\
\hline\ \input{infile/dataset_v3.331.noQU.tex} \T \\
\input{infile/dataset_v3.332.noQU.tex} \B \\
\hline \multicolumn{3}{c}{ Panel B: Medium-term effects (2013 vs. 2008)} \T \B \\
\hline \ \input{infile/dataset_v3.351.noQU.tex} \T \\
\input{infile/dataset_v3.352.noQU.tex} \B \\
\hline \hline
\end{tabular}
\end{threeparttable}
\end{table}
\end{comment}

\begin{comment} Test
\begin{table}[H]
\begin{threeparttable}
\caption{Treatment Effects of the PIS on Incomes of Treated Farmers (PDS-Lasso)}
\begin{tabular}{ccccccc}
\hline \hline (1) & (2) & (3) & (4) & (5) & (6) & (7) \T \B \\
\multicolumn{7}{c}{\makecell{$\triangle$ Income (PPP-\$)}} \\
\hline \noalign{\vskip 1mm} \makecell{Crop \\ cultiva- \\ tion \\ \\} & \makecell{Life- \\ stock/life- \\ stock \\ products} & \makecell{Resource \\ extrac- \\ tion \\ \\} & \makecell{Wage \\ employ- \\ ment\\ \\} & \makecell{Self- \\ employment \\ \\ \\} & \makecell{Remit- \\ tances \\ (family/ \\ relatives)} & \makecell{Total \\ \\ \\ \\} \\
\hline \multicolumn{7}{c}{ Panel A: Short-term effects (2010 vs. 2008)} \T \B \\
\hline \input{infile/dataset_v3.431.noQU.tex} \T \\
\input{infile/dataset_v3.432.noQU.tex} \B \\
\hline \multicolumn{7}{c}{ Panel B: Medium-term effects (2013 vs. 2008)} \T \B \\
\hline \input{infile/dataset_v3.451.noQU.tex} \T \\
\input{infile/dataset_v3.452.noQU.tex} \B \\
\hline \hline
\end{tabular}
\end{threeparttable}
\end{table}
\end{comment}

\begin{comment}
\begin{table}[H]
\begin{threeparttable}
\caption{Treatment Effect of the PIS on Rice Production of Treated Farmers (PDS-Lasso)}
\begin{tabular}{cccccc}
\hline\hline \multirow[t]{2}{*}{ (1) } & (2) & (3) & (4) & (5) & (6) \T \\
\multicolumn{4}{c}{$\triangle$ Rice production} & \makecell{$\triangle$ } & \makecell{$\triangle$ \\} \\
\cline{1-4} \noalign{\vskip 1mm} \makecell{(Log) \\  Expendi- \\ tures \\ (PPP-\$) \B} & \makecell{(Log) \\ Area \\ \\ (Rai) \B} & \makecell{(Log) \\ Agri. \\ assets \\ (Value) \B} & \makecell{(Log) \\ Total \\ produce \\ (Kg) \B} & \makecell{Production \\ index, \\  based on \\ (1) to (4) \B} & \makecell{(Log) \\ Produce \\ sold \\ (Kg) \B} \\
\hline \multicolumn{6}{c}{ Panel A: Short-term effects (2010 vs. 2008)} \T \B \\
\hline \input{infile/dataset_v3.131.tex} \T \\
\input{infile/dataset_v3.132.tex} \B \\
\hline \multicolumn{6}{c}{ Panel B: Medium-term effects (2013 vs. 2008)} \T \B \\
\hline \input{infile/dataset_v3.151.tex} \T \\
\input{infile/dataset_v3.152.tex} \B \\
\hline \multicolumn{6}{c}{ Panel C: Long-term effects (2016 vs. 2008)} \T \B \\
\hline \input{infile/dataset_v3.161.tex} \T \\
\input{infile/dataset_v3.162.tex} \B \\
\hline \multicolumn{6}{c}{ Panel C: Long-term effects (2017 vs. 2008)} \T \B \\
\hline \input{infile/dataset_v3.171.tex} \T \\
\input{infile/dataset_v3.172.tex} \B \\
\hline \multicolumn{6}{c}{ Panel C: Long-term effects (2019 vs. 2008)} \T \B \\
\hline \input{infile/dataset_v3.181.tex} \T \\
\input{infile/dataset_v3.182.tex} \B \\
\hline\hline
\end{tabular}
\end{threeparttable}
\end{table}
\end{comment}

\begin{comment} Test 2
\begin{table}[H]
\begin{threeparttable}
\caption{Treatment Effects of the PIS on Treated Farmers (PDS-Lasso). Possible Coupling Mechanisms: Land and Labor Allocation}
\begin{tabular}{ccccccc}
\hline \hline (1) & (2) & (3) & (4) & (5) & (6) & (7) \T \B \\
\makecell{$\triangle$ Land \\  used for} & \multicolumn{4}{c}{\makecell{$\triangle$ Number of income generating \\ activities in ... }} & \makecell{$\triangle$ \\ Activity} & \makecell{$\triangle$ HH \\ members} \\
\cline{2-5} \noalign{\vskip 0.5mm} \makecell{rice cul- \\ tivation \\ (share) \\ \\} & \makecell{Livestock \\ products \\ \\ \\} & \makecell{Resource \\ extrac- \\ tion \\ \\} & \makecell{Wage \\ employ- \\ ment \\ \\} & \makecell{Self- \\ employment \\ \\ \\} & \makecell{index, \\ based on \\ (2) to (5) \\ \\} & \makecell{temp. gone \\ for job/ \\ job search \\ (share)} \\
\hline \multicolumn{7}{c}{ Panel A: Short-term effects (2010 vs. 2008)} \T \B \\
\hline \input{infile/dataset_v3.231.tex} \T \\
\input{infile/dataset_v3.232.tex} \B \\
\hline \multicolumn{7}{c}{ Panel B: Medium-term effects (2013 vs. 2008)} \T \B \\
\hline \input{infile/dataset_v3.251.tex} \T \\
\input{infile/dataset_v3.252.tex} \B \\
\hline \multicolumn{7}{c}{ Panel C: Long-term effects (2016 vs. 2008)} \T \B \\
\hline \input{infile/dataset_v3.261.tex} \T \\
\input{infile/dataset_v3.262.tex} \B \\
\hline \multicolumn{7}{c}{ Panel C: Long-term effects (2017 vs. 2008)} \T \B \\
\hline \input{infile/dataset_v3.271.tex}\T \\
\input{infile/dataset_v3.272.tex} \B \\
\hline \multicolumn{7}{c}{ Panel C: Long-term effects (2019 vs. 2008)} \T \B \\
\hline \input{infile/dataset_v3.281.tex} \T \\
\input{infile/dataset_v3.282.tex} \B \\
\hline \hline
\end{tabular}
\end{threeparttable}
\end{table}
\end{comment}

\begin{comment} Test
\begin{table}[H]
\begin{threeparttable}
\caption{Treatment Effects of the PIS on Treated Farmers (PDS-Lasso). Possible Coupling Mechanisms: Wealth, Risk Aversion, and Credit Constraints}
\begin{tabular}{ccc}
\hline \hline (1) & (2) & (3) \T \B \\
\makecell{$\triangle$ Income \\ from public \\ transfers \\ (incl. PIS) \B} & \makecell{$\triangle$ Risk\\ attitude \\ \\ \\} & \makecell{$\triangle$ Agri \\ loans \\ (Yes=1) \\ \\} \\
\hline \multicolumn{3}{c}{ Panel A: Short-term effects (2010 vs. 2008) \T \B} \\
\hline\ \input{infile/dataset_v3.331.tex} \T \\
\input{infile/dataset_v3.332.tex} \B \\
\hline \multicolumn{3}{c}{ Panel B: Medium-term effects (2013 vs. 2008)} \T \B \\
\hline \ \input{infile/dataset_v3.351.tex} \T \\
\input{infile/dataset_v3.352.tex} \B \\
\hline \multicolumn{3}{c}{ Panel B: Long-term effects (2016 vs. 2008)} \T \B \\
\hline \input{infile/dataset_v3.361.tex} \T \\
\input{infile/dataset_v3.362.tex} \B \\
\hline \multicolumn{3}{c}{ Panel B: Long-term effects (2017 vs. 2008)} \T \B \\
\hline \input{infile/dataset_v3.371.tex} \T \\
\input{infile/dataset_v3.372.tex} \B \\
\hline \multicolumn{3}{c}{ Panel B: Long-term effects (2019 vs. 2008)} \T \B \\
\hline \input{infile/dataset_v3.381.tex} \T \\
\input{infile/dataset_v3.382.tex} \B \\
\hline \hline
\end{tabular}
\end{threeparttable}
\end{table}
\end{comment}

\begin{comment} Test
\begin{table}[H]
\begin{threeparttable}
\caption{Treatment Effects of the PIS on Incomes of Treated Farmers (PDS-Lasso)}
\begin{tabular}{ccccccc}
\hline \hline (1) & (2) & (3) & (4) & (5) & (6) & (7) \T \B \\
\multicolumn{7}{c}{\makecell{$\triangle$ Income (PPP-\$)}} \\
\hline \noalign{\vskip 1mm} \makecell{Crop \\ cultiva- \\ tion \\ \\} & \makecell{Life- \\ stock/life- \\ stock \\ products} & \makecell{Resource \\ extrac- \\ tion \\ \\} & \makecell{Wage \\ employ- \\ ment\\ \\} & \makecell{Self- \\ employment \\ \\ \\} & \makecell{Remit- \\ tances \\ (family/ \\ relatives)} & \makecell{Total \\ \\ \\ \\} \\
\hline \multicolumn{7}{c}{ Panel A: Short-term effects (2010 vs. 2008)} \T \B \\
\hline \input{infile/dataset_v3.431.tex} \T \\
\input{infile/dataset_v3.432.tex} \B \\
\hline \multicolumn{7}{c}{ Panel B: Medium-term effects (2013 vs. 2008)} \T \B \\
\hline \input{infile/dataset_v3.451.tex} \T \\
\input{infile/dataset_v3.452.tex} \B \\
\hline \multicolumn{7}{c}{ Panel C: Long-term effects (2016 vs. 2008)} \T \B \\
\hline \input{infile/dataset_v3.461.tex} \T \\
\input{infile/dataset_v3.462.tex} \B \\
\hline \multicolumn{7}{c}{ Panel C: Long-term effects (2017 vs. 2008)} \T \B \\
\hline \input{infile/dataset_v3.471.tex} \T \\
\input{infile/dataset_v3.472.tex} \B \\
\hline \multicolumn{7}{c}{ Panel C: Long-term effects (2019 vs. 2008)} \T \B \\
\hline \input{infile/dataset_v3.481.tex} \T \\
\input{infile/dataset_v3.482.tex} \B \\
\hline \hline
\end{tabular}
\end{threeparttable}
\end{table}
\end{comment}
tex*/

texdoc close