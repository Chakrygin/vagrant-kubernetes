@echo off

pushd "%~dp0.."

vagrant up

xcopy /s /y ".kube" "%UserProfile%\.kube\"
xcopy /s /y ".kube" "%UserProfile%\YandexDisk\.kube\"

popd
