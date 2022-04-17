@echo off
SET OLD_CLASSPATH=%CLASSPATH%
SET CLASSPATH=
for %%i in ("..\lib\*.jar") do call "add2cp.bat" %%i
FOR /D %%G in ("..\plugins\*") DO (FOR %%J in ("%%G\*jar") do call "add2cp.bat" %%J)
SET CLASSPATH=.;..\..\config\currencyConv;%CLASSPATH%
@echo on

java -Xmx512m com.axiomainc.portfolioprecision.XmlSolve %*

@echo off

SET CLASSPATH=%OLD_CLASSPATH%   