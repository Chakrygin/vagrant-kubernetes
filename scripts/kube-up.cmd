@echo off

pushd "%~dp0.."

vagrant up

if errorlevel 1 (
    exit 1
)

if not exist ".kube\config" (
    echo File ".kube\config" not found!
)

if not exist "%UserProfile%\.kube\" (
    mkdir "%UserProfile%\.kube\"
)

echo Copying ".kube\config" to "%UserProfile%\.kube\config"
copy ".kube\config" "%UserProfile%\.kube\config"

if not exist "%UserProfile%\YandexDisk\.kube\" (
    mkdir "%UserProfile%\YandexDisk\.kube\"
)

echo Copying ".kube\config" to "%UserProfile%\YandexDisk\.kube\config"
copy ".kube\config" "%UserProfile%\YandexDisk\.kube\config"

popd
