$vault = "$ENV:TF_VAR_loc$ENV:TF_VAR_env" + "vault"
$name = "$ENV:TF_VAR_loc$ENV:TF_VAR_env" + "wincert"

$cert = az keyvault certificate show --vault-name $vault --name $name 

foreach ($line in $cert){
    if ($line -like "*x509ThumbprintHex*") {
        $hex = (($line.split(":")[1]).Replace("`"","")).trim()
    }

    if ($line -like "*sid*") {
        $ver = (($line.split("/")[-1]).Replace("`"","").Replace(",","")).trim()
    }
}

write-output "{ `"thumbprint`" : `"$hex`", `"version`" : `"$ver`" }"