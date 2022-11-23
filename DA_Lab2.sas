

LIBNAME Pharma_D "ignore this part";


* Read in external data file;
* change the DATAFILE path to your own;
PROC IMPORT OUT=mydata
            DATAFILE= "/home/rwomack0/OnlineDemo/PharmaDemo.xls"
            DBMS=XLS REPLACE;
     GETNAMES=YES;
     SHEET=csv;                                  
     DATAROW=2;
RUN;

* Save the output to a rtf file;

ODS RTF FILE='/home/rwomack0/Pharma_demo/PharmaDemo.rtf';

* Print the data set;
PROC PRINT DATA=mydata;
RUN;


* Show the variables list;
PROC CONTENTS DATA=mydata;
RUN;

* Drop and rename variables, create a new data set, label and transform variables;

DATA my_new_data REPLACE;
  SET mydata;
  DROP Painkiller;
  LABEL Tot_Opi=Total Opiate Use Opi_N_T=Opiate Naive/Tolerant TOT_LOS_H=Length of Hospital Stay;
RUN;
DATA my_new_data REPLACE;
  SET my_new_data;
  RENAME Tot_Opi=Tot_Opiate_Use Average_Pain_Score=Avg_Pain;
RUN;
DATA my_new_data REPLACE;
  SET my_new_data;
  Hourly_Dose=(Tot_Opiate_Use/TOT_LOS_H);
RUN;

PROC CONTENTS DATA=my_new_data;
RUN;


* Calculate descriptive statistics;
PROC UNIVARIATE DATA=my_new_data;
  VAR Tot_Opiate_Use TOT_LOS_H;
RUN;


* Compare basic descriptive statistics among groups;
PROC MEANS DATA=my_new_data;
  CLASS IV_APAP;
  VAR Tot_Opiate_Use TOT_LOS_H;
RUN;

* Categorical data frequencies;
* must SORT before using BY option;

PROC SORT DATA=my_new_data;
   BY IV_APAP;
RUN;

* Chi-squared test;
* This tests for equality, but you can also specify expected proportions in each cell;
PROC FREQ DATA=my_new_data;
   TABLES IV_APAP*Epidural / chisq measures;
RUN;

PROC FREQ DATA=my_new_data;
   TABLES IV_APAP*Opi_N_T / chisq measures;
RUN;

PROC FREQ DATA=my_new_data;
   TABLES IV_APAP*Tramadol / chisq measures;
RUN;

* Check normality with PROC UNIVARIATE;
PROC UNIVARIATE DATA=my_new_data NORMAL;
   VAR Weight;
   QQPLOT;
   PROBPLOT;
   
* T-test, compare groups;
PROC TTEST DATA=my_new_data;
   CLASS IV_APAP;
   VAR Weight;
   
   PROC TTEST DATA=my_new_data;
   CLASS IV_APAP;
   VAR Avg_Pain;
   
   PROC TTEST DATA=my_new_data;
   CLASS IV_APAP;
   VAR Tot_Opiate_Use;
   
   PROC TTEST DATA=my_new_data;
   CLASS IV_APAP;
   VAR TOT_LOS_H;

* T-test, one sample;
PROC TTEST DATA=my_new_data H0=70 PLOTS(showh0) SIDES=u ALPHA=0.1;
   VAR TOT_LOS_H;
   

* Side-by-side boxplots;
* First, sort the data;
PROC SORT DATA=my_new_data;
  BY Epidural;
RUN;

** Draw the plots;
PROC SGPLOT DATA=my_new_data;
  VBOX Tot_Opiate_Use / CATEGORY=Epidural;
RUN;

* Correlation between two variables;

PROC CORR DATA=my_new_data;
  VAR Tot_Opiate_Use Avg_Pain;
RUN;


* Scatter plot;

PROC SGPLOT DATA=my_new_data;
  SCATTER X=Avg_Pain Y=Tot_Opiate_Use;
RUN;


* Regression;
* Use QUIT statement to clear any stored variables from the regression;

** Model: Tot_Opiate_Use = Avg_Pain;
PROC REG DATA=my_new_data;
  MODEL Tot_Opiate_Use = Avg_Pain;
RUN;
QUIT;

** Model: Tot_Opiate_Use = Avg_Pain + Epidural;

*Recode Epidural first;
DATA my_new_data REPLACE;
   SET my_new_data;
   Epidural2 = .;
  IF (Epidural="Yes")  THEN Epidural2 = 1;
  IF (Epidural="No") THEN Epidural2 = 0;
RUN;

PROC  REG DATA=my_new_data;
  MODEL Tot_Opiate_Use = Avg_Pain Epidural2;
RUN;
QUIT;

** Logistic Regression with PROC LOGISTIC;
PROC  LOGISTIC  DATA=my_new_data Descending;
   MODEL IV_APAP = Avg_Pain Weight;
RUN;
QUIT;



* Save the data file to a SAS data file on local drive;
DATA '/home/rwomack0/Pharma_demo/Pharma_Demo' REPLACE;
  SET my_new_data;
RUN;

*close out the document recording the session;
ODS RTF CLOSE;
