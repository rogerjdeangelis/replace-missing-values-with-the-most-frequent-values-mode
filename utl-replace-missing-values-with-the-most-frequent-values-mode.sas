Replace missing values with the most frequent values mode                                                                        
                                                                                                                                 
                                                                                                                                 
   I could not find a function in SAs that would provide the mode for                                                            
   character variables.                                                                                                          
                                                                                                                                 
   Method (R solution)                                                                                                           
                                                                                                                                 
         a. Load SAS daatset into an R data table using haven package.                                                           
         b. Convert SAS character missings to R character missings.                                                              
         c. Apply R mode function to each column (works for both char and numeric values).                                       
         d. Convert R data table to SAS V5 transport file.                                                                       
         e. Conver SA V5 transport file to SAS dataset.                                                                          
                                                                                                                                 
                                                                                                                                 
github                                                                                                                           
https://tinyurl.com/ybxqabbr                                                                                                     
https://github.com/rogerjdeangelis/replace-missing-values-with-the-most-frequent-values-mode                                     
                                                                                                                                 
SAS Forum                                                                                                                        
https://tinyurl.com/ydd47o5u                                                                                                     
https://communities.sas.com/t5/SAS-Programming/Help-Macro-to-replace-missing-values-with-the-most-frequent/m-p/665163            
                                                                                                                                 
/*                   _                                                                                                           
(_)_ __  _ __  _   _| |_                                                                                                         
| | `_ \| `_ \| | | | __|                                                                                                        
| | | | | |_) | |_| | |_                                                                                                         
|_|_| |_| .__/ \__,_|\__|                                                                                                        
        |_|                                                                                                                      
*/                                                                                                                               
options validvarname=upcase;                                                                                                     
libname sd1 "d:/sd1";                                                                                                            
data sd1.have;                                                                                                                   
 input v1 v2 V3$;                                                                                                                
cards4;                                                                                                                          
3 . a                                                                                                                            
3 1 .                                                                                                                            
. 2 b                                                                                                                            
4 2 b                                                                                                                            
;;;;                                                                                                                             
run;quit;                                                                                                                        
                                                                                                                                 
                                                                                                                                 
SD1.HAVE total obs=4  | RULES  Since b is the most frequent                                                                      
                      |                                                                                                          
 V1    V2    V3       |  V3                                                                                                      
                      |                                                                                                          
  3     .    a        |  a                                                                                                       
  3     1             |  b   < -- slug b in here                                                                                 
  .     2    b        |  b                                                                                                       
  4     2    b        |  b                                                                                                       
                                                                                                                                 
/*           _               _                                                                                                   
  ___  _   _| |_ _ __  _   _| |_                                                                                                 
 / _ \| | | | __| `_ \| | | | __|                                                                                                
| (_) | |_| | |_| |_) | |_| | |_                                                                                                 
 \___/ \__,_|\__| .__/ \__,_|\__|                                                                                                
                |_|                                                                                                              
*/                                                                                                                               
                                                                                                                                 
                                                                                                                                 
WORK.WANT total obs=4                                                                                                            
                                                                                                                                 
 V1    V2    V3                                                                                                                  
                                                                                                                                 
  3     2    a                                                                                                                   
  3     1    b                                                                                                                   
  3     2    b                                                                                                                   
  4     2    b                                                                                                                   
                                                                                                                                 
/*                                                                                                                               
 _ __  _ __ ___   ___ ___  ___ ___                                                                                               
| `_ \| `__/ _ \ / __/ _ \/ __/ __|                                                                                              
| |_) | | | (_) | (_|  __/\__ \__ \                                                                                              
| .__/|_|  \___/ \___\___||___/___/                                                                                              
|_|                                                                                                                              
*/                                                                                                                               
                                                                                                                                 
* delete want dataset;                                                                                                           
proc datasets lib=work nolist;                                                                                                   
 delete want;                                                                                                                    
run;quit;                                                                                                                        
                                                                                                                                 
* delete v5 transport file it it exists;                                                                                         
%utlfkil(d:/xpt/want.xpt);                                                                                                       
                                                                                                                                 
                                                                                                                                 
* need resolve to remove /* */ comments before R execution;;                                                                     
%utl_submit_r64(resolve('                                                                                                        
                                                                                                                                 
library(haven);                                                                                                                  
library(data.table);                                                                                                             
library(SASxport);                                                                                                               
library(modeest);                                                                                                                
library(dplyr);                                                                                                                  
                                                                                                                                 
/* convert sas table to R data table */                                                                                          
have<-data.table(read_sas("d:/sd1/have.sas7bdat"));                                                                              
                                                                                                                                 
/* replace SAS missing char values with R missings */                                                                            
have<-have %>% mutate_all(na_if,"");                                                                                             
                                                                                                                                 
/* function to get the modes */                                                                                                  
myFun <- function(x) {                                                                                                           
    x[is.na(x)] <- mfv(x, na_rm = TRUE);                                                                                         
    x;                                                                                                                           
  };                                                                                                                             
                                                                                                                                 
/* apply the function */                                                                                                         
want<-have[, lapply(.SD, myFun)];                                                                                                
                                                                                                                                 
/* R data table to SAS V5 transport file */                                                                                      
write.xport(want,file="d:/xpt/want.xpt");                                                                                        
'));                                                                                                                             
                                                                                                                                 
* convert transport file to sas dataset;                                                                                         
libname xpt xport "d:/xpt/want.xpt";                                                                                             
data want ;                                                                                                                      
  set xpt.want;                                                                                                                  
run;quit;                                                                                                                        
libname xpt clear;                                                                                                               
                                                                                                                                 
/*                                                                                                                               
| | ___   __ _                                                                                                                   
| |/ _ \ / _` |                                                                                                                  
| | (_) | (_| |                                                                                                                  
|_|\___/ \__, |                                                                                                                  
         |___/                                                                                                                   
*/                                                                                                                               
                                                                                                                                 
> library(haven);                                                                                                                
library(data.table);                                                                                                             
library(SASxport);                                                                                                               
library(modeest);                                                                                                                
library(dplyr);                                                                                                                  
have<-data.table(read_sas("d:/sd1/have.sas7bdat"));                                                                              
have<-have %>% mutate_all(na_if,"");                                                                                             
myFun <- function(x) {    x[is.na(x)] <- mfv(x, na_rm = TRUE);    x;  };                                                         
want<-have[, lapply(.SD, myFun)];                                                                                                
write.xport(want,file="d:/xpt/want.xpt");                                                                                        
>                                                                                                                                
NOTE: 3 lines were written to file PRINT.                                                                                        
NOTE: 2 records were read from the infile RUT.                                                                                   
      The minimum record length was 2.                                                                                           
      The maximum record length was 320.                                                                                         
NOTE: DATA statement used (Total process time):                                                                                  
      real time           5.57 seconds                                                                                           
      user cpu time       0.01 seconds                                                                                           
      system cpu time     0.11 seconds                                                                                           
      memory              316.06k                                                                                                
      OS Memory           23800.00k                                                                                              
      Timestamp           06/26/2020 12:11:25 PM                                                                                 
      Step Count                        382  Switch Count  0                                                                     
                                                                                                                                 
                                                                                                                                 
MPRINT(UTL_SUBMIT_R64):   filename rut clear;                                                                                    
NOTE: Fileref RUT has been deassigned.                                                                                           
MPRINT(UTL_SUBMIT_R64):   filename r_pgm clear;                                                                                  
NOTE: Fileref R_PGM has been deassigned.                                                                                         
MPRINT(UTL_SUBMIT_R64):   * use the clipboard to create macro variable;                                                          
SYMBOLGEN:  Macro variable RETURNVAR resolves to N                                                                               
MLOGIC(UTL_SUBMIT_R64):  %IF condition %upcase(%substr(&returnVar.,1,1)) ne N is FALSE                                           
MLOGIC(UTL_SUBMIT_R64):  Ending execution.                                                                                       
6920  * convert transport file to sas dataset;                                                                                   
6921  libname xpt xport "d:/xpt/want.xpt";                                                                                       
NOTE: Libref XPT was successfully assigned as follows:                                                                           
      Engine:        XPORT                                                                                                       
      Physical Name: d:\xpt\want.xpt                                                                                             
6922  data want;                                                                                                                 
6923    set xpt.want;                                                                                                            
6924  run;                                                                                                                       
                                                                                                                                 
NOTE: There were 4 observations read from the data set XPT.WANT.                                                                 
NOTE: The data set WORK.WANT has 4 observations and 3 variables.                                                                 
NOTE: DATA statement used (Total process time):                                                                                  
      real time           0.05 seconds                                                                                           
      user cpu time       0.00 seconds                                                                                           
      system cpu time     0.01 seconds                                                                                           
      memory              483.78k                                                                                                
      OS Memory           23800.00k                                                                                              
      Timestamp           06/26/2020 12:11:25 PM                                                                                 
      Step Count                        383  Switch Count  0                                                                     
                                                                                                                                 
                                                                                                                                 
                                                                                                                                 
                                                                                                                                 
