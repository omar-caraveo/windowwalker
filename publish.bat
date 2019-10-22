@echo off

set token=%1

pushd "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Auxiliary\Build"

call vcvarsall x86

popd

echo 'The current version on the server is '

Powershell.exe -executionpolicy remotesigned -File Deployment\GetVersion.ps1

set /p VERSION="Enter new version number you would like to publish:"

cd "Window Walker"

powershell -Command "(New-Object System.Net.WebClient).DownloadFile(\"https://dist.nuget.org/win-x86-commandline/latest/nuget.exe\", \".\nuget.exe\")"

.\nuget.exe restore "Window Walker.sln"

msbuild /target:publish /p:Configuration=Release /property:ApplicationVersion=%VERSION% /p:Platform="Any CPU" /property:PublishUrl=".\..\Deployment\Deployment\"

cd ..

IF EXIST .\Deployment\Deployment ( 
	rmdir /s .\Deployment\Deployment /Q
)

mkdir .\Deployment\Deployment

xcopy ".\Window Walker\Window Walker\bin\Release\app.publish\*" ".\Deployment\Deployment\" /y /s

echo %VERSION%>.\Deployment\Deployment\version.txt

cd .\Deployment

REM for /f %%i in ('now') do set uniqueurl=%%i

npm i -g now

now --token %token% .>temp.txt

set /p uniqueurl=<temp.txt

del temp.txt

now --token %token% alias %uniqueurl% download.windowwalker.com

git tag v%VERSION%

git push origin v%VERSION%

cd ..
