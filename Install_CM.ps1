
$CM_SETUP_EXE_LOCATION    = "C:\SC_Configmgr_SCEP_1802\smssetup\bin\X64\setup.exe";
$CM_SETUP_SCRIPT_LOCATION = "C:\SC_Configmgr_SCEP_1802\ConfigMgrAutoSave.ini";
$CM_MODULE_SETUP_LOCATION = "C:\SC_Configmgr_SCEP_1802\ConfigMgr2012PowerShellCmdlets.msi";


Function install_CM($setupFile, $scriptFile) {
    cmd.exe /c $CM_SETUP_EXE_LOCATION /SCRIPT $CM_SETUP_SCRIPT_LOCATION;
}

Function install_CM_Module() {
    cmd.exe /c msiexec.exe /i $CM_MODULE_SETUP_LOCATION /qn;
}

install_CM $CM_SETUP_EXE_LOCATION $CM_SETUP_SCRIPT_LOCATION;
install_CM_Module;