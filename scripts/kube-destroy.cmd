@echo off

pushd "%~dp0.."

vagrant destroy -f

if exist ".kube" (
    rmdir /s /q ".kube"
)

if exist ".tmp" (
    rmdir /s /q ".tmp"
)

popd
