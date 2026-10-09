@echo off
set "PATH=%LOCALAPPDATA%\Programs\MinGit\cmd;%PATH%"
echo ========================================================
echo   Smart Student Planner - Push to GitHub
echo   Repository: https://github.com/kumarankit63839-netizen/smart_study_planner
echo ========================================================
echo.
echo Pushing branch 'main' to GitHub origin...
echo (When prompted for password, paste your GitHub Personal Access Token)
echo.
git push -u origin main
echo.
if %ERRORLEVEL% EQU 0 (
    echo ========================================================
    echo   SUCCESS! Pushed to https://github.com/kumarankit63839-netizen/smart_study_planner
    echo ========================================================
) else (
    echo ========================================================
    echo   Push failed. Please ensure you enter your GitHub Token.
    echo   To create a token: GitHub -> Settings -> Developer Settings -> Personal access tokens (classic) -> Generate token (repo scope)
    echo ========================================================
)
echo.
pause
