@echo off

pushd "%~dp0.."

vagrant destroy -f

rmdir /s /q ".kube"
rmdir /s /q ".tmp"

popd
