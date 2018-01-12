# Remove file from system.
find . -name apply_plsql_lab3_sh.log -exec rm -f {} \;
 
# Create log file with header information.
echo 'Log: apply_plsql_lab3_sh.log' >> apply_plsql_lab3_sh.log
echo '==========================================' >> apply_plsql_lab3_sh.log
 
# Call script file with a string less than 10 characters.
echo 'Test Case: Only number and string'          >> apply_plsql_lab3_sh.log
echo '------------------------------------------' >> apply_plsql_lab3_sh.log
sqlplus -s student/student @apply_plsql_lab3.sql 38 catch22 '' 2>/dev/null |
while IFS='\n' read msg; do
  echo $msg >> apply_plsql_lab3_sh.log
done
 
# Call script file with a string great than 10 characters.
echo '==========================================' >> apply_plsql_lab3_sh.log
echo 'Test Case: Valid number, string and date.'  >> apply_plsql_lab3_sh.log
echo '------------------------------------------' >> apply_plsql_lab3_sh.log
sqlplus -s student/student @apply_plsql_lab3.sql 41 aerodromes '13-OCT-1307' 2>/dev/null |
while IFS='\n' read msg; do
  echo $msg >> apply_plsql_lab3_sh.log
done
 
# Call script file with a null value.
echo '==========================================' >> apply_plsql_lab3_sh.log
echo 'Test Case: Bad DATE string'                 >> apply_plsql_lab3_sh.log
echo '------------------------------------------' >> apply_plsql_lab3_sh.log
sqlplus -s student/student @apply_plsql_lab3.sql '31-APR-2017' dagger 81 2>/dev/null |
while IFS='\n' read msg; do
  echo $msg >> apply_plsql_lab3_sh.log
done
echo '==========================================' >> apply_plsql_lab3_sh.log