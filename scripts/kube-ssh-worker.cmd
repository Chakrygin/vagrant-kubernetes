@echo off

wt new-tab -d "%~dp0.." cmd /C vagrant ssh "kube-worker-1" -c "mc"
