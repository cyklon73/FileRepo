@echo off
setlocal enabledelayedexpansion

rem Define installation paths, URLs, and shortcut name
set "InstallPath=%LocalAppData%\CableTies"
set "DownloadUrl1=https://raw.githubusercontent.com/cyklon73/FileRepo/main/cableties/CableTies.zip"
set "DownloadUrl2=https://raw.githubusercontent.com/cyklon73/FileRepo/main/cableties/CableTies-binaries.zip"
set "ZipFile1=%InstallPath%\CableTies.zip"
set "ZipFile2=%InstallPath%\binaries.zip"
set "ShortcutName=Kabelbinder"

set "StartMenuPath=%AppData%\Microsoft\Windows\Start Menu\Programs"

set "ShortcutPath=%StartMenuPath%\%ShortcutName%.lnk"

echo %ShortcutPath%

rem Check if the installation folder already exists
if exist "%InstallPath%" (
    echo The folder "%InstallPath%" already exists.
    
    rem Check if the folder is empty
    dir /b "%InstallPath%" | findstr . >nul
    if %errorlevel% equ 0 (
        echo The folder is not empty and seems to be already installed.
        echo Wollen Sie die Installation abbrechen oder neu installieren?
        echo [A]bbrechen, [N]euinstallieren:
        set /p userChoice="Ihre Wahl: "

        rem Convert input to uppercase to handle case insensitivity
        set "userChoice=!userChoice:~0,1!"
        set "userChoice=!userChoice:A=a,N=n!"

        if /i "!userChoice!"=="A" (
            echo Installation is being canceled.
	    timeout 1
	    echo 3...
	    timeout 1
	    echo 2...
	    timeout 1
	    echo 1...
	    timeout 1
            goto end
        ) else if /i "!userChoice!"=="N" (
            echo Removing existing installation...
            
            rem Delete the installation folder
            rmdir /s /q "%InstallPath%"
            echo Installation folder has been deleted.
            
            rem Delete the shortcut
            if exist "%ShortcutPath%" (
                del "%ShortcutPath%"
                echo Shortcut "%ShortcutName%" in the Start Menu has been deleted.
            ) else (
                echo No shortcut found in the Start Menu.
            )
        ) else (
            echo Invalid input. Installation is being canceled.
            exit /b
        )
    ) else (
        echo The folder is empty. Installation can proceed.
    )
) else (
    echo The folder "%InstallPath%" does not exist. Installation can proceed.
)

rem Create installation folder
echo Creating installation folder...
mkdir "%InstallPath%"
echo Folder "%InstallPath%" has been created.

rem Step 1: Download the CableTies ZIP file
echo Downloading the CableTies ZIP file from %DownloadUrl1%...
bitsadmin /transfer CableTies /download /priority high "%DownloadUrl1%" "%ZipFile1%"
echo CableTies ZIP file has been downloaded.

rem Step 2: Extract the CableTies ZIP file
echo Extracting the CableTies ZIP file...
tar -xf "%ZipFile1%" -C "%InstallPath%"
if exist "%ZipFile1%" (
    del /f "%ZipFile1%"
    echo CableTies ZIP file has been extracted and deleted.
) else (
    echo Error extracting the CableTies ZIP file.
    exit /b 1
)

rem Step 3: Download the Binaries ZIP file
echo Downloading the Binaries ZIP file from %DownloadUrl2%...
bitsadmin /transfer CableTies-Binaries /download /priority high "%DownloadUrl2%" "%ZipFile2%"
echo Binaries ZIP file has been downloaded.

rem Step 4: Extract the Binaries ZIP file
echo Extracting the Binaries ZIP file...
tar -xf "%ZipFile2%" -C "%InstallPath%"
if exist "%ZipFile2%" (
    del /f "%ZipFile2%"
    echo Binaries ZIP file has been extracted and deleted.
) else (
    echo Error extracting the Binaries ZIP file.
    exit /b 1
)

rem Step 5: Move the "bin" folder into the "jre" folder
echo Moving the "bin" folder into the "jre" folder...
if exist "%InstallPath%\bin" (
    move "%InstallPath%\bin" "%InstallPath%\jre\"
    echo "bin" folder has been moved to the "jre" folder.
) else (
    echo "bin" folder not found in the extracted content of the Binaries ZIP file.
    exit /b 1
)

rem Step 6: Create shortcut to the start file
echo Creating shortcut "%ShortcutName%" in the Start Menu...

rem Create VBS script for shortcut creation
echo Set objShell = CreateObject("WScript.Shell") > "%temp%\createShortcut.vbs"
echo Set objShortcut = objShell.CreateShortcut("%ShortcutPath%") >> "%temp%\createShortcut.vbs"
echo objShortcut.Description = "Kabelbinder Spiel" >> "%temp%\createShortcut.vbs"
echo objShortcut.IconLocation = "%InstallPath%\icon.ico" >> "%temp%\createShortcut.vbs"
echo objShortcut.TargetPath = "%InstallPath%\start.bat" >> "%temp%\createShortcut.vbs"
echo objShortcut.WorkingDirectory = "%InstallPath%" >> "%temp%\createShortcut.vbs"
echo objShortcut.Save >> "%temp%\createShortcut.vbs"

cscript //nologo "%temp%\createShortcut.vbs"
del "%temp%\createShortcut.vbs"
echo Shortcut "%ShortcutName%" has been created.

rem Step 7: Run start.bat
echo Running start.bat...
start /B /D "%InstallPath%" "CableTies Installation" /wait "%InstallPath%\start.bat" -install

rem Installation process completed
echo Installation abgeschlossen.

echo Press any key to exit . . .
pause>nul