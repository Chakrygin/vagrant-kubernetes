@echo off

wt new-tab -d "%~dp0.." cmd /C vagrant ssh "kube-master" -c "sudo mc"
