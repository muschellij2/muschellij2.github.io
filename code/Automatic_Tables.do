cd "~/Dropbox/CTR/Presentations/Welch_Pearls/Tables"
clear all
sysuse nlsw88, clear

set seed 1234
gen Trt = rbinomial(1, 0.5)
label define Trt 0 "A" 1 "B"
label val Trt Trt

foreach var of varlist race married never_married grade collgrad south smsa c_city industry occupation union {
	estpost tab `var' Trt
}

*****labeling data
/*
foreach var of varlist age wage hours tenure race married never_married grade {
	local name = proper("`var'")
	label var `var' `name'
}
*/

******Posting the table to memory - saving in the e(b) macro - remember - estpost thinks it's posting estimation results, so it calls it B for beta coefficients
estpost tab race Trt

******Esttab (built on estout - look at estout for full options) is the workhorse for the table
*******use the nois option to noisily report the output - aka it will show exactly the code passed into estout
******cells - specifies what you want to get out of estpost - use help estpost to see what you can get
****** also use ereturn list to see what is stored in memory
****** Also I want to format the percent ( the column percent - colpct) to 2 decimals
****** when you want to specify options for a cell - see help esttab - then put a parenthesis and then the option
esttab . using ./results/race_nostack.tex, cells(b colpct(fmt(2))) tex replace
esttab . using ./results/race_nostack.rtf, cells(b colpct(fmt(2))) rtf replace
esttab . using ./results/race_nostack.csv, cells(b colpct(fmt(2))) csv replace
******* we rarely want a cross tab that is ``stacked''

******Using unstack - we want treatment A/B on the column names
esttab . using ./results/race_stack.tex, cells(b colpct(fmt(2))) tex unstack replace
esttab . using ./results/race_stack.rtf, cells(b colpct(fmt(2))) rtf unstack replace
esttab . using ./results/race_stack.csv, cells(b colpct(fmt(2))) csv unstack replace

*******ugh - what is this (1) and the b/colpct doing there - that looks horrible
*******this is taken care of using nonum - for no numbers - it tries to label them with numbers since you number equations/models when presenting for reference
*******this is actually very useful when doing actual regression results, so don't think it just as a nuisance option

*******the b/colpct - it thinks you're trying to label the model with the outcome here - again important for regression - not here
*******collabels(none) takes this out.  You can also specify collabels though
esttab . using ./results/race_nonum.tex, cells(b colpct(fmt(2))) tex unstack replace nonum collabels(none)
esttab . using ./results/race_nonum.rtf, cells(b colpct(fmt(2))) rtf unstack replace nonum collabels(none)
esttab . using ./results/race_nonum.csv, cells(b colpct(fmt(2))) csv unstack replace nonum collabels(none)


*****Why is there still a space??? - this is because esttab also is thinking you want an mtitle - a model title - to label it - which can be useful sometimes, but not 
*****when using estpost tab - so nomtitle can turn that off
******Why is there an N at the bottom of my table? -- again esttab is trying to show the N for the model, but that's not what we want - so we use noobs - saying 
******No observations (I first thought it meant number of observations, which was confusing)
esttab . using ./results/race_nomt.tex, cells(b colpct(fmt(2))) tex unstack replace nonum collabels("N" "\%") nomtitle noobs
*****need a \ in \% in LaTeX because % is a comment character so need to ``escape it'', telling LaTeX I want a % symbol and this is not a comment
esttab . using ./results/race_nomt.rtf, cells(b colpct(fmt(2))) rtf unstack replace nonum collabels("N" "%") nomtitle noobs
esttab . using ./results/race_nomt.csv, cells(b colpct(fmt(2))) csv unstack replace nonum collabels("N" "%") nomtitle noobs


*****Finally, making it look like the correct table 
*****- why is it putting this stuff in columns still - I thought we unstacked it!?
*****well it's how the cells argument is passed into esttab.  If passed as it was before, it treats them as separate statistics (like you'd have a t-statistic or a p-value
*****below a  coefficient maybe), but if you pass it as one big string, by quoting it, then it will put the N and % in different columns
esttab . using ./results/race_cols.tex, cells("b colpct(fmt(2))") tex unstack replace nonum collabels("N" "\%") nomtitle noobs
esttab . using ./results/race_cols.rtf, cells("b colpct(fmt(2))") rtf unstack replace nonum collabels("N" "%") nomtitle noobs
esttab . using ./results/race_cols.csv, cells("b colpct(fmt(2))") csv unstack replace nonum collabels("N" "%") nomtitle noobs

***** I wanted them in one cell!!! How?? The ampersand & can ``merge'' cells together 
esttab . using ./results/race_mcols.tex, cells("b & colpct(fmt(2))") tex unstack replace nonum collabels("N \%") nomtitle noobs
esttab . using ./results/race_mcols.rtf, cells("b & colpct(fmt(2))") rtf unstack replace nonum collabels("N %") nomtitle noobs
esttab . using ./results/race_mcols.csv, cells("b & colpct(fmt(2))") csv unstack replace nonum collabels("N %") nomtitle noobs


********Well I want parentheses, let's try the par option
esttab . using ./results/race_par.tex, cells("b & colpct(fmt(2) par)") tex unstack replace nonum collabels("N (\%)") nomtitle noobs
esttab . using ./results/race_par.rtf, cells("b & colpct(fmt(2) par)") rtf unstack replace nonum collabels("N (%)") nomtitle noobs
esttab . using ./results/race_par.csv, cells("b & colpct(fmt(2) par)") csv unstack replace nonum collabels("N (%)") nomtitle noobs

*****Hmmm let's say I want brackets, not parentheses.  Looking at the -- help estout -- par option, we can just do par ( )
esttab . using ./results/race_ppar.tex, cells("b & colpct(fmt(2) par( [ ] ) )") tex unstack replace nonum collabels("N [\%]") nomtitle noobs
esttab . using ./results/race_ppar.rtf, cells("b & colpct(fmt(2) par( [ ] ) )") rtf unstack replace nonum collabels("N [%]") nomtitle noobs
esttab . using ./results/race_ppar.csv, cells("b & colpct(fmt(2) par( [ ] ) )") csv unstack replace nonum collabels("N [%]") nomtitle noobs

******to Drop a certain row - think of it as a beta coefficient, just say drop(THAT)
******to drop a column - they think of these as equations and regard them with : so say drop(THAT:)

********Well I want parentheses, let's try the par option
esttab ., cells("b & colpct(fmt(2) par)") unstack replace nonum collabels("N (\%)") nomtitle noobs drop(Total) 
esttab ., cells("b & colpct(fmt(2) par)") unstack replace nonum collabels("N (\%)") nomtitle noobs drop(Total:) 

****These are all equivalent
esttab ., cells("b & colpct(fmt(2) par)") unstack replace nonum collabels("N (\%)") nomtitle noobs drop(Total*) 
esttab ., cells("b & colpct(fmt(2) par)") unstack replace nonum collabels("N (\%)") nomtitle noobs drop(Total Total:) 

estpost tab race Trt, nototal
esttab ., cells("b & colpct(fmt(2) par)") unstack replace nonum collabels("N (\%)") nomtitle noobs 


*******************************
**********T-Test***************
*******************************

estpost ttest age wage hours tenure ttl_exp, by(Trt) unequal
esttab . using ./results/ttest.csv, cells("mu_1(fmt(2)) mu_2(fmt(2)) b(fmt(2)) p(fmt(3))") collabels("Mean Trt A" "Mean Trt B" "Difference" "P-value") ///
	nomtitle noobs nonum csv label replace
	
regress wage age hours tenure 
est store model_wage

regress wage age hours tenure ttl_exp
est store model_age

regress wage age hours tenure married
est store model_exp

regress wage age hours tenure ttl_exp married
est store model_ten

esttab model_wage model_age model_exp model_ten using ./results/reg.csv, replace label csv nostar nonote p 

*esttab ., cells("mu_1(fmt(2)) mu_2(fmt(2)) b(fmt(2)) p(fmt(3))") collabels("Mean Trt A" "Mean Trt B" "Difference" "P-value")   nomtitle noobs nonum

esttab ., wide collabels("Diff" "P-value") 
esttab ., collabels("Diff" "P-value") 

esttab ., cells("mu_1 mu_2 p") csv unstack replace nonum collabels("Mean A" "Mean B" "P-value") nomtitle noobs nois


