##################################################################################################
### These are the default values for this script. Uncomment and change
### them according to your needs. This is a powershell code.
##################################################################################################
### The warning_time and error_time values are used for interpreting eventlogs as follows:
### error_time=3 -> Eventlog error entries withing 1 day are treated as errors. If there are
### error eventlog entries older than 1 day are not counted as errors.
### warning_time=3 -> Eventlog warning entries withing 3 days are treated as warnings. If there are
### warning eventlog entries older than 3 days are not counted as warnings.
### The format of error and warning times is
### 1) If the value is a number, then it is the number of days.
### 2) If the value is of the form d:hh:mm, then it is d days hh hours mm minutes.
############################################################################################################
#$error_time="1:00"
#$warning_time="1:00"
##################################################################################################
