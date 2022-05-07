/* */
/* Labeling of all the variables */
proc format;
	value Resolution
		1 = 'Resolved'
		2 = 'Escalated'
		3 = 'Disconnect';
	value Case_Type
		1 = 'Account Related'
		2 = 'Affiliate Related'
		3 = 'Disconnect'
		4 = 'Billing'
		5 = 'Cancellations and Refunds'
		6 = 'Miscellaneous'
		7 = 'Programming'
		8 = 'Technical';
	value Contact_Type
		1 = 'Email'
		2 = 'Phone';
run;

/* Separate dataset for escalations */
data esconly;
	set mynewlib.mis480cs;
	if Resolution = 1 then delete;
	if Resolution = 3 then delete;
run;

/* Separate dataset for Tier 1 resolved */
data resonly;
	set mynewlib.mis480cs;
	if Resolution = 2 then delete;
	if Resolution = 3 then delete;
run;

/* Summary stats */
proc means data=MYNEWLIB.MIS480CS chartype mean std min max n vardef=df;
	format Resolution Resolution. Case_Type Case_Type. Contact_Type Contact_Type.;
	var Resolution;
	class Case_Type Contact_Type;
run;

/* Histograms of case data */
proc univariate data=MYNEWLIB.MIS480CS vardef=df noprint;
	format Resolution Resolution. Case_Type Case_Type. Contact_Type Contact_Type.;
	var Resolution;
	class Case_Type Contact_Type;
	histogram Resolution / barlabel=percent endpoints=(1 to 4 by 1);
run;

/* Pie chart for all case types */
title 'All Resolutions';
proc sgpie data=mynewlib.mis480cs;
	format Case_Type Case_Type.;
	pie Case_Type / DATALABELLOC=inside DATALABELDISPLAY=(CATEGORY PERCENT) dataskin=pressed;
run;

/* Pie chart for cases resolved by Tier 1 */
title 'Handled by Tier 1';
proc sgpie data=work.resonly;
	format Case_Type Case_Type.;
	pie Case_Type / DATALABELLOC=inside DATALABELDISPLAY=(CATEGORY PERCENT) dataskin=pressed;
run;		

/* Pie chart for cases escalated  */
title 'Escalated';
proc sgpie data=work.esconly;
	format Case_Type Case_Type.;
	pie Case_Type / DATALABELLOC=inside DATALABELDISPLAY=(CATEGORY PERCENT) dataskin=pressed;
run;

/* Bar chart for case types and their escalation rates */
title "Percent of Case Types and Escalation Rates";
proc sgplot data=MYNEWLIB.MIS480CS;
	format Resolution Resolution. Case_Type Case_Type.;
	xaxis label='Case Type';
	vbar Case_Type / group=Resolution groupdisplay=stack datalabel stat=percent SEGLABEL dataskin=pressed;
	yaxis grid;
run;

/* Bar chart for the escalation rates - calls vs emails */
title "Percent Escalation Rates - Emails vs. Calls";
proc sgplot data=MYNEWLIB.MIS480CS;
	format Resolution Resolution. Contact_Type Contact_Type.;
	xaxis label='Contact Type';
	vbar Contact_Type / group=Resolution groupdisplay=stack datalabel stat=percent SEGLABEL dataskin=pressed;
	yaxis grid;
run;