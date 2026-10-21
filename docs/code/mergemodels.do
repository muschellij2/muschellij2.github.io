/*** 
******mergemodels - useful for creating a ``Univariate'' Column of Models
******
***Adapted from From	  "Ben Jann" <ben.jann@gmail.com>
On Stata List-Serv
http://www.stata.com/statalist/archive/2007-06/msg00636.html
Syntax mergemodels mod1 mod2 mod3 ...
The resultant e(b) in memory has all variables from each model (including constants)
******
*****/


***start of do-file***
capt prog drop mergemodels
prog mergemodels, eclass
// assuming that last element in e(b)/e(V) is _cons
 version 8
 syntax namelist
 tempname b V tmp
 foreach name of local namelist {
   qui est restore `name'
   mat `b' = nullmat(`b') , e(b)
   mat `b' = `b'[1,1..colsof(`b')-1]
   mat `tmp' = e(V)
   mat `tmp' = `tmp'[1..rowsof(`tmp')-1,1..colsof(`tmp')-1]
   capt confirm matrix `V'
   if _rc {
     mat `V' = `tmp'
   }
   else {
     mat `V' = ///
      ( `V' , J(rowsof(`V'),colsof(`tmp'),0) ) \ ///
      ( J(rowsof(`tmp'),colsof(`V'),0) , `tmp' )
   }
 }
 local names: colfullnames `b'
 mat coln `V' = `names'
 mat rown `V' = `names'
 eret post `b' `V'
 eret local cmd "whatever"
end

/*
mergemodels u1 u2 u3
est sto u123
estout u1 u2 u3 u123, style(smcl)
*/
/*
	for loop {
			local storer = subinstr("`var'", "i.", "", 1)
			local vlab : variable label `storer'
			di "`vlab'"
			local changelabs `"`changelabs' "`storer' `vlab'""'
			 est store `storer'
			 mat B = e(b)
			 mat `N' = nullmat(`N') , e(N)
			 mat list `N'
			 local r = colsof(B)
			 local names: colfullnames e(b)
		
			if (`r' > 2) {
				 local i = 1
				 foreach name of local names {
				 	di "`name'"
				 	if (`i' == 1) local namer = "`name'"
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
*/
