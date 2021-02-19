@echo off

pushd "%~dp0.."

vagrant up

mkdir "%UserProfile%\.kube\"
copy ".kube\config" "%UserProfile%\.kube\config"

mkdir "%UserProfile%\YandexDisk\.kube\"
copy ".kube\config_external" "%UserProfile%\YandexDisk\.kube\config"

popd
