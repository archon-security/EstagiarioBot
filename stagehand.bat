@echo off
rem This file was created by pub v2.19.2.
rem Package: stagehand
rem Version: 4.0.1
rem Executable: stagehand
rem Script: stagehand
if exist "C:\Users\Pedro SD\AppData\Local\Pub\Cache\global_packages\stagehand\bin\stagehand.dart-2.19.2.snapshot"                                                                                                                                                               (
  call dart "C:\Users\Pedro SD\AppData\Local\Pub\Cache\global_packages\stagehand\bin\stagehand.dart-2.19.2.snapshot"                                                                                                                                                               %*
  rem The VM exits with code 253 if the snapshot version is out-of-date.
  rem If it is, we need to delete it and run "pub global" manually.
  if not errorlevel 253 (
    goto error
  )
  call dart pub global run stagehand:stagehand %*
) else (
  call dart pub global run stagehand:stagehand %*
)
goto eof
:error
exit /b %errorlevel%
:eof
