@echo off
cls
@pushd %~dp0

:: Path to Python 3.8 on both lab computers and VDI
set lab_path="C:\Program Files\Python38\python.exe"
set vdi_path="C:\Program Files\Python38\python.exe"

::Check which python location exists and then set python_path to that location
if exist %lab_path% (
    set python_path=%lab_path%
) else if exist %vdi_path% (
    set python_path=%vdi_path%
) else (
    echo Could not find python interpreter on computer
    echo Press any key to close . . .
    pause > nul
    exit 1
)

:: there are currently no command-line options for simulation
%python_path% synthesis.py

::Pause so students can see final output if they are not using the command line
:: use > nul to hide the pause output so we can print our own message
echo Press any key to close . . .
pause > nul

@popd