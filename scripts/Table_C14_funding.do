cap est drop _all

//++++++++++++++++++++++++++++++++++++++++++++
// TABLE C14 - The effect of the amount of public funding on sponsored ///
//	patents at the applicant level, clean tech sample
//++++++++++++++++++++++++++++++++++++++++++++

use "${data_path}/db_for_restat_treat_het.dta",clear


qui reg count  amount_tot  nb_inventors nb_applicants ///
	originality $cpc_4d_green ,vce(robust)
estadd local  vce_rob "Yes"
est store est1


qui reg fwd_cits5  amount_tot  count nb_inventors nb_applicants ///
	originality $cpc_4d_green ,vce(robust)
estadd local  vce_rob "Yes"
est store est2

esttab est* using "${output_tables}/table_C14.html", align(center) ///
drop(d_ei_* _cons) ///
starlevels(+ 0.1 * 0.05 ** 0.01) ///
order(amount_tot count) ///
varlabels(amount_tot "amount of Gvt R&D" count "# clean tech Gvt patents" ///
nb_inventors "avg. team size" nb_applicants "avg. # of applicants" ///
originality "avg. originality") ///
cells(b(star fmt(3)) ///
se(par([ ]) fmt(3)))legend collabels(, none) ///
stats (r2 N, labels ( ///
"R sq" "N (applicants)") ///
fmt(3 0)) ///
title("Table C 14: The effect of the amount of public funding on sponsored patents at the applicant level, clean tech sample") ///
mtitles("# clean tech patents" "# citations to clean tech patents") ///
replace
