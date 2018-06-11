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
    $Schedule = New-CMSchedule -RecurInterval Minutes -Start "2012/10/20 00:00:00" -End "2099/10/20 00:00:00" -RecurCount $deltaDiscoveryMinutes
    $ADGroupDiscoveryScope = New-CMADGroupDiscoveryScope -Name "Domain Root" -LdapLocation $ldapSearchScope -RecursiveSearch $false;
    Set-CMDiscoveryMethod -ActiveDirectoryGroupDiscovery `
                          -SiteCode $siteCode `
                          -Enabled $true `
                          -AddGroupDiscoveryScope $ADGroupDiscoveryScope `
                          -PollingSchedule $Schedule;
}

Function clear_All_Discovery_Methods($ldapSearchScope) {
    Set-CMDiscoveryMethod -ActiveDirectorySystemDiscovery -RemoveActiveDirectoryContainer $ldapSearchScope -Enabled $false;
    Set-CMDiscoveryMethod -ActiveDirectoryUserDiscovery -RemoveActiveDirectoryContainer $ldapSearchScope -Enabled $false;
    
    <# Delete all location data for AD Group Discovery Method #>
    $propertyLists = (Get-CMDiscoveryMethod | Select *).PropLists;
    foreach ($propList in $propertyLists) {
        if ($propList.PropertyListName -like "*:*") {
            $discoveryGroupScopeName = ($propList.PropertyListName -split ":")[1]
        }
    }
    
    Set-CMDiscoveryMethod -ActiveDirectoryGroupDiscovery -RemoveGroupDiscoveryScope $discoveryGroupScopeName -Enabled $false;
}

Function create_IP_Subnet_Boundary($boundaryName, $boundaryNetworkID) {
    New-CMBoundary -Name $boundaryName -Type IPSubnet -value $boundaryNetworkID;
}

Function create_Site_System_Server($siteSystemServerName, $accountToCreateServer) {
    New-CMSiteSystemServer -SiteCode $CM_SITE_CODE -SiteSystemServerName $siteSystemServerName -PublicFqdn $siteSystemServerName -AccountName $accountToCreateServer;
}

Function add_Distribution_Point($dpName, $boundaryGroupName) {
    $DP = (Get-CMSiteSystemServer | where { $_.NetworkOSPath -like "*$dpName*"; })
    $Date = [DateTime]::Now.AddYears(31)
    Add-CMDistributionPoint -InputObject $DP `
                            -InstallInternetServer `
                            -ClientConnectionType "Intranet" `
                            -Description "Main Headquarters DP" `
                            -EnableAnonymous `
                            -EnablePxe `
                            -AllowPxeResponse `
                            -EnableUnknownComputerSupport `
                            -CertificateExpirationTimeUtc $Date `
                            -AddBoundaryGroupName $boundaryGroupName;
}

Function setup_Boundary_Groups($boundaryGroupName, $boundaryGroupDescription, $siteSystemServer) {
     New-CMBoundaryGroup -Name $boundaryGroupName `
                         -Description $boundaryGroupDescription `
                         -DefaultSiteCode $CM_SITE_CODE `
                         -AddSiteSystemServer $siteSystemServer;
}

Function create_Application($appName, $appDescription, $appPublisher, $appVersion) {
    New-CMApplication -Name $appName `
                      -Description $appDescription `
                      -Publisher $appPublisher `
                      -SoftwareVersion $appVersion;
}

Function create_Deployment_Type_MSI($applicationName, $msiLocation) {
   Add-CMDeploymentType -MsiInstaller `
                        -ApplicationName $applicationName `
                        -AutoIdentifyFromInstallationFile `
                        -ContentLocation $msiLocation `
                        -InstallationBehaviorType "InstallForSystem";
}

import_CM_Module;
connect_To_CM_Drive;
#setup_SCCM_Service_Account "ConfigUser" "Password1";
#setup_Discovery_Method_System $CM_SITE_CODE "30" $DOMAIN_ROOT;
#setup_Discovery_Method_User   $CM_SITE_CODE "30" $DOMAIN_ROOT;
#setup_Discovery_Method_Group  $CM_SITE_CODE "30" $DOMAIN_ROOT;
#clear_All_Discovery_Methods $DOMAIN_ROOT;
create_Application "Google Chrome" "The best browser" "Gewgol" "6.9"
create_Deployment_Type_MSI "Google Chrome" "\\sccm\c$\_Content\_Apps\_Chrome\GoogleChromeStandaloneEnterprise64.msi"