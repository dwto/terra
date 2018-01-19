$cert = az keyvault certificate show --vault-name dwto-dev-vault --name wincert

foreach ($line in $cert){
    if ($line -like "*x509ThumbprintHex*") {
        $hex = (($line.split(":")[1]).Replace("`"","")).trim()
    }

    if ($line -like "*sid*") {
        $ver = (($line.split("/")[-1]).Replace("`"","").Replace(",","")).trim()
    }
}

write-output "{ `"thumbprint`" : `"$hex`", `"version`" : `"$ver`" }"