		tempname N
			
			local addnames = ""
			local changelabs ""
		
			
			foreach var of varlist `catvars' {
				local storer = subinstr("`var'", "i.", "", 1)
				local vlab : variable label `storer'					
				tab `var' `trt', chi2 exact
				logistic `trt' i.`var'
				est store `var'
				
				mat B = e(b)
				mat `N' = nullmat(`N') , e(N)
				di "N Matrix"
				mat list `N'
				local r = colsof(B)
				local names: colfullnames e(b)
				di "Names: `names', `r'"
				local namer = ""
				if (`r' > 1) {
					local i = 1
					foreach name of local names {
						di "`name'"
						if (`i' == 2) local namer = "`namer' `name'"
					 		local i = `i' + 1
					 	}
				 	}
				else {
				 		local namer = "`storer'"
				 	}
				 local addnames "`addnames' `namer'"
			}
				
				di "`addnames'"
				mat coln `N' = `addnames'
				mat rown `N' = "y1"
				estadd matrix N = `N', replace
				mat list e(N)
		
			mergemodels `catvars'
			est store unadj
			ereturn list
			estadd matrix N = `N', replace
			mat list e(b)
			mat list e(N)
			est store unadj_cat







			*******************
			****Continuous*****
			*******************	
			
			tempname N
			
			local addnames = ""
			local changelabs ""	
			foreach var of varlist `convars' {
				if ($graphs != 0) {
					twoway scatter `trt' `var', jitter(1) || lowess `trt' `var', logit ||, title("`data'; Outcome: `trt', Variable: `var'")
					graph export "$resdir/plots/`app'Lowess_`trt'_`var'.png", as(png) replace 
				}
				logistic `trt' `var'
				est store `var'	
				
				mat B = e(b)
				mat `N' = nullmat(`N') , e(N)
				di "N Matrix"
				mat list `N'
				local r = colsof(B)
				local names: colfullnames e(b)
				di "Names: `names', `r'"
				local namer = ""
				if (`r' > 1) {
					local i = 1
					foreach name of local names {
						di "`name'"
						if (`i' == 1) local namer = "`namer' `name'"
					 		local i = `i' + 1
					 	}
				 	}
				else {
				 		local namer = "`storer'"
				 	}
				 local addnames "`addnames' `namer'"
			}
				
				di "`addnames'"
				mat coln `N' = `addnames'
				mat rown `N' = "y1"
				estadd matrix N = `N', replace
				mat list e(N)
				
		
			mergemodels `convars'
			est store unadj
			ereturn list
			estadd matrix N = `N', replace
			mat list e(b)
			mat list e(N)
			est store unadj_contin
		
			esttab unadj_contin using "$resdir/`app'contin_`trt'.tex", cells(" b(fmt(3)) ci(par( ( , ) )) N(fmt(0)) p(fmt(4)) ") tex nonum nogap nomti replace noobs ///
				collabels("Odds Ratio" "95\% CI" "Sample Size" "P-value") eform ///
				substitute("sys_bp_s" "Pre-Hospital Systolic BP" "phresp" "Pre-Hospital Respiratory Rate" "phhr" "Pre-Hospital Heart Rate" "age" "Age" ///
					"edrr" "ED Respiratory Rate" "sysbped" "ED BP" "phgcstot" "Pre-Hospital GCS Total" "edhr" "ED Heart Rate" "edgcstot" "ED GCS Total" "_" " ") 
