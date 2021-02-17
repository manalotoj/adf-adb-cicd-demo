param
(
    [parameter(Mandatory = $true)] [String] $commonRgName,
    [parameter(Mandatory = $true)] [String] $commonAdfName,
    [parameter(Mandatory = $true)] [String] $sharedIrName,
    [parameter(Mandatory = $true)] [String] $adfName,
    [parameter(Mandatory = $true)] [String] $rgName
)

function getSharedIr {
    return  get-AzDataFactoryV2IntegrationRuntime `
    -ResourceGroupName $commonRgName `
    -DataFactoryName $commonAdfName `
    -Name $sharedIrName
}

function getFactory {
    return get-AzDataFactoryV2 -ResourceGroupName $rgName -Name $adfName
}

write-host 'here we go'
$factory = getFactory
write-host $factory
$sharedIr = getSharedIr
write-host $sharedIr
write-host 'try to get role'
$role = get-azroleassignment -ObjectId $factory.Identity.PrincipalId -RoleDefinitionName 'Contributor' -Scope $sharedIr.Id
write-host $role
if (!$role) {
    write-host 'role does not exist. creat it.'
    new-azroleassignment -ObjectId $factory.Identity.PrincipalId -RoleDefinitionName 'Contributor' -Scope $SharedIr.Id
}
