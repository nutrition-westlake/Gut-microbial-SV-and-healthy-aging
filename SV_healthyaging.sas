%macro impt(data,csv);
PROC IMPORT OUT= WORK.&data. 
            DATAFILE= "D:\example\&csv..csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
	 guessingrows=10000;
RUN;
%mend;


%macro loopit(mylist,RAlist,out,lab,cov_con,cov_cat,name);
   %let n = %sysfunc(countw(&mylist));
   %do i=1 %to &n;
      %let val = %scan(&mylist,&i);
	  %let ra = %scan(&RAlist,&i);

      proc logistic data=&val;
      class  &cov_cat./ref=first;
      model &out.(event="1")=&cov_con. &cov_cat. &ra  COL1;
      by _NAME_;
      ods output ParameterEstimates=&lab._dsv ;
	  ods output OddsRatios=&lab._dsv_OR ;
      run;

      data &lab._dsv;retain _NAME_ Estimate se ProbChiSq model;
      set &lab._dsv;model="&name.";
      where Variable="COL1";format ProbChiSq e10.;
      se=round(StdErr,0.001);
      keep _Name_ Estimate se ProbChiSq model;
      rename estimate=beta  ProbChiSq=pvalue;
      run;

      data &lab._dsv_OR;retain _NAME_  OddsRatioEst LowerCL UpperCL model;
      set &lab._dsv_OR;model="&name.";
      where Effect="COL1";
      CI=cat("(",round(LowerCL,0.01),",",round(UpperCL,0.01),")");
      keep _NAME_  OddsRatioEst CI model;
      run;

      proc sort data=&lab._dsv;by _name_;run;
      proc sort data=&lab._dsv_OR;by _name_;run;
      data &lab._dsv;merge &lab._dsv &lab._dsv_OR;by _name_;run;


       proc sort data=&lab._dsv;by pvalue;run;
      
       data &lab._&val;
       set &lab._dsv;
       run;
       quit;
   %end;
%mend;


%macro loopit(mylist,RAlist,out,lab,cov_con,cov_cat,name);
   %let n = %sysfunc(countw(&mylist));
   %do i=1 %to &n;
      %let val = %scan(&mylist,&i);
	  %let ra = %scan(&RAlist,&i);

      proc logistic data=&val;
      class  &cov_cat./ref=first;
      model &out.(event="1")=&cov_con. &cov_cat. &ra  COL1;
      by _NAME_;
      ods output ParameterEstimates=&lab._vsv ;
	  ods output OddsRatios=&lab._vsv_OR ;
      run;

      data &lab._vsv;retain _NAME_ Estimate se ProbChiSq model;
      set &lab._vsv;model="&name.";
      where Variable="COL1";format ProbChiSq e10.;
      se=round(StdErr,0.001);
      keep _Name_ Estimate se ProbChiSq model;
      rename estimate=beta  ProbChiSq=pvalue;
      run;

      data &lab._vsv_OR;retain _NAME_  OddsRatioEst LowerCL UpperCL model;
      set &lab._vsv_OR;model="&name.";
      where Effect="COL1";
      CI=cat("(",round(LowerCL,0.01),",",round(UpperCL,0.01),")");
      keep _NAME_  OddsRatioEst CI model;
      run;
      proc sort data=&lab._vsv;by _name_;run;
      proc sort data=&lab._vsv_OR;by _name_;run;
      data &lab._vsv;merge &lab._vsv &lab._vsv_OR;by _name_;run;


       proc sort data=&lab._vsv;by pvalue;run;
      
       data &lab._&val;
       set &lab._vsv;
       run;
       quit;
   %end;
%mend;


%macro loopit(mylist,RAlist,out,lab,cov_con,cov_cat,name);
   %let n = %sysfunc(countw(&mylist));
   %do i=1 %to &n;
      %let val = %scan(&mylist,&i);
	  %let ra = %scan(&RAlist,&i);
        proc glm data=&val;
        class  &cov_cat./ref=first;
        model &out.=&cov_con. &cov_cat. &ra COL1/solution;
        by _NAME_;
        ods output ParameterEstimates=&lab._vsv ;
        run;

        data &lab._vsv;retain _NAME_ estimate se probt model;
        set &lab._vsv;model="&name.";
        where parameter in ("COL1");format probt e10.;
        se=round(stderr,0.001);
        keep _Name_ estimate se probt model;
        rename estimate=beta  probt=pvalue;
        run;

       proc sort data=&lab._vsv;by pvalue;run;
      
       data &lab._&val;
       set &lab._vsv;
       run;
       quit;
   %end;
%mend;


%macro expt(data,csv);
PROC EXPORT DATA= work.&data. 
            OUTFILE= "D:\example\&csv..csv" 
            DBMS=CSV REPLACE;

RUN;
%mend;
