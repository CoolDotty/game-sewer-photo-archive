@echo off
setlocal enabledelayedexpansion

:mainloop
set count=0
set "hasMore="

for /f "delims=" %%f in ('git ls-files -m -o --exclude-standard') do (
  if !count! lss 25 (
    echo Adding: "%%f"
    git add -- "%%f"
    set /a count+=1
  ) else (
    set "hasMore=1"
  )
)

if %count%==0 (
  echo No changes to commit. Done.
  endlocal
  exit /b 0
)

echo Committing %count% file(s)...
git commit -m "Auto commit: staged %count% files"
if errorlevel 1 (
  echo Commit failed. Aborting.
  git status --porcelain
  endlocal
  exit /b 1
)

echo Pushing...
git push
if errorlevel 1 (
  echo Push failed. Aborting.
  endlocal
  exit /b 1
)

if defined hasMore (
  echo More files remain. Repeating...
  goto mainloop
)

echo All changes processed.
endlocal
exit /b