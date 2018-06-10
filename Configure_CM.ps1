$DOMAIN_ROOT         = "LDAP://DC=lab,DC=local";
$CM_SITE_CODE        = "LAB";
$CM_SITE_CODE_DRIVE  = "LAB:\";
$CM_MODULE_LOCATION  = "C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1";

Function import_CM_Module() {
    import-module $CM_MODULE_LOCATION;
}

Function connect_To_CM_Drive() {
    cd $CM_SITE_CODE_DRIVE;
}

Function setup_SCCM_Service_Account($username, $password) {
    $password = ConvertTo-SecureString $password -AsPlainText -Force;
    New-CmAccount -Password $password -Username "LAB\$username" -SiteCode "LAB";
}

Function setup_Discovery_Method_System($siteCode, $deltaDiscoveryMinutes, $ldapSearchScope) {
    $Schedule = New-CMSchedule -RecurInterval Minutes -Start "2012/10/20 00:00:00" -End "2099/10/20 00:00:00" -RecurCount 10
    Set-CMDiscoveryMethod -ActiveDirectorySystemDiscovery `
                      -SiteCode $siteCode `
                      -Enabled $true `
                      -PollingSchedule $Schedule `
                      -EnableDeltaDiscovery $true `
                      -DeltaDiscoveryMins $deltaDiscoveryMinutes `
                      -ActiveDirectoryContainer $ldapSearchScope `
                      -Recursive `
                      -IncludeGroup
}


Function setup_Discovery_Method_User($siteCode, $deltaDiscoveryMinutes, $ldapSearchScope) {
    $Schedule = New-CMSchedule -RecurInterval Minutes -Start "2012/10/20 00:00:00" -End "2099/10/20 00:00:00" -RecurCount 10
    Set-CMDiscoveryMethod -ActiveDirectoryUserDiscovery `
                      -SiteCode $siteCode `
                      -Enabled $true `
                      -PollingSchedule $Schedule `
                      -EnableDeltaDiscovery $true `
                      -DeltaDiscoveryMins $deltaDiscoveryMinutes `
                      -ActiveDirectoryContainer $ldapSearchScope `
                      -Recursive `
                      -IncludeGroup
}

Function setup_Discovery_Method_Group($siteCode, $deltaDiscoveryMinutes, $ldapSearchScope) {
    $Schedule = New-CMSchedule -RecurInterval Minutes -Start "2012/10/20 00:00:00" -End "2099/10/20 00:00:00" -RecurCount 10
    Set-CMDiscoveryMethod -ActiveDirectoryGroupDiscovery `
                      -SiteCode $siteCode `
                      -Enabled $true `
                      -PollingSchedule $Schedule `
                      -EnableDeltaDiscovery $true `
                      -DeltaDiscoveryMins $deltaDiscoveryMinutes `
                      -ActiveDirectoryContainer $ldapSearchScope `
                      -Recursive `
                      -IncludeGroup
}

Function setup_Boundaries() {

}

Function setup_Boundary_Groups() {

}


#import_CM_Module;
#connect_To_CM_Drive;
#setup_SCCM_Service_Account "ConfigUser" "Password1";
setup_Discovery_Method_System $CM_SITE_CODE "30" $DOMAIN_ROOT;
setup_Discovery_Method_User   $CM_SITE_CODE "30" $DOMAIN_ROOT;
setup_Discovery_Method_Group  $CM_SITE_CODE "30" $DOMAIN_ROOT;


<#
Set-CMDiscoveryMethod -ActiveDirectorySystemDiscovery [-SiteCode <string>] [-Enabled <bool>] [-PollingSchedule <IResultObject#SMS_ScheduleToken>] [-EnableDeltaDiscovery <bool>] 
    [-DeltaDiscoveryMins <int>] [-AddAdditionalAttribute <string[]>] [-RemoveAdditionalAttribute <string[]>] [-EnableFilteringExpiredLogon <bool>] [-TimeSinceLastLogonDays <int>] 
    [-EnableFilteringExpiredPassword <bool>] [-TimeSinceLastPasswordUpdateDays <int>] [-ActiveDirectoryContainer <string[]>] [-Recursive] [-IncludeGroup] [-ClearActiveDirectoryContainer] 
    [-RemoveActiveDirectoryContainer <string[]>] [-AddActiveDirectoryContainer <string[]>] [-PassThru] [-DisableWildcardHandling] [-ForceWildcardHandling] [-WhatIf] [-Confirm]  
    [<CommonParameters>]

    $Schedule = New-CMSchedule -RecurInterval Minutes -Start "2012/10/20 00:00:00" -End "2013/10/20 00:00:00" -RecurCount 10

#>
