if ($args.Length -lt 2) {
    Write-Host "Usage: netscan ip-min ip-max"
    Write-Host "Ex: netscan 192.168.0.1 192.168.0.100"
    Exit
}

$start = $args[0];
$end = $args[1];
$network = $args[0] -split "\.";
$network = "$($network[0]).$($network[1]).$($network[2])"
[int]$start = ($start -split "\.")[3];
[int]$end = ($end -split '\.')[3];
# Récupération du curseur console à sa position initiale
$ips = "";
$start_crs = $host.UI.RawUI.CursorPosition;
$current_crs = $host.UI.RawUI.CursorPosition;
while (1) {
    # Envoi asynchone de requêtes ICMP et Stockage des réponses dans un Array
    $cnt = $start;
    $pings = @();
    while ($cnt -le $end) {
        $ping = (New-Object System.Net.NetworkInformation.Ping).SendPingAsync("$network.$cnt");
        $pings += $ping;
        $cnt++;
	Start-Sleep -Milliseconds 1
    }

    # Analyse des réponses ICMP et ajout des Ping réuissi
    # Ajout Du constructeur (via Adresse Mac)
    $connected = @();
    foreach ($ping in $pings) {
        if (($ping.Result).Status -eq "Success") {
            $connected += ($ping.Result).Address.IPAddressToString;
        }
    }

    # Enlevement des Ip plus dispo de la liste d'Ip principal $ips (String)
    if ($ips.Length -gt 1) {
        $ips_tab = $ips -split "#"
        foreach ($ipt in $ips_tab) {
            if ($connected.IndexOf($ipt) -eq -1) {
                $ip_del_idx = $ips.IndexOf($ipt);
                #$ipt_end = 0;
                if ($ips[$ip_del_idx - 1] -eq "#") { $ipt = "#$ipt" }
                elseif ($ips[$ip_del_idx + $ipt.Length] -eq "#") { $ipt += "#" }
                #$ips = $ips.Substring($ip_del_idx, $ipt.Length + $ipt_end);
                $ips = $ips.Replace($ipt, "")
            }
        }    
    }

    # Ajout des nouvelles dispos pas encore presente dans la liste d'Ip Principal $ips (String)
    foreach ($cnd in $connected) {
        if ($ips.IndexOf($cnd) -eq -1) {
            $ips += "#$cnd";
        }
    }
    if ($ips[0] -eq "#") { $ips = $ips.Substring(1, $ips.Length - 1) }
    if ($ips[$ips.Length - 1] -eq "#") { $ips = $ips.Substring(0, $ips.Length - 2) }

    # Trier les ip dans l'ordre
    $ips_tab = $ips -split "#";
    if ($ips_tab[0].Length -gt 1) {
        $last_byte = 0;
        for ($i = $ips_tab[0].Length; $ips_tab[0][$i] -ne "."; $i--) { $last_byte = $i; }
        #$network = $ips_tab[0].Substring(0, $last_byte - 1);
        $ips_tab = $ips_tab.Replace("$network.", "") | Sort-Object {[int]$_} | ForEach-Object -Process { "$network.$_" };
    }

    #Ajout des noms d'hotes
    $dnsRes = @();
    foreach ($ipt in $ips_tab) {
        $dnsRes += [System.Net.Dns]::GetHostEntryAsync($ipt)
    }

    #$hostnames = $dnsRes.Result.HostName | ForEach { if ($_ -eq $null) { "..." }; else { $_ } } ;
    $hostnames = @()
    foreach ($dr in $dnsRes) {
        $hn = $dr.Result.HostName
        if (($hn -ne $null) -and ($hn.IndexOf(".") -ne -1)) { $hn = $hn.Substring(0, $hn.IndexOf(".")) }
        if ($hn -eq $null) { $hn = "..." }
        $hostnames += $hn
	Start-Sleep -Milliseconds 1
    }

    # Gestion de l'affichage
    $ip_length = ($ips_tab | Measure-Object -Maximum -Property Length).Maximum
    $host_length = ($hostnames | Measure-Object -Maximum -Property Length).Maximum
    # Titres
    $output =  "`n   Ip Connected      HostName`n ";
    # Lignes du Haut
    $output += ("-" * ($ip_length + 3)) + " " + ("-" * ($host_length + 3)) + "`n"
    # Ip + Host + Constructeur
    $i = 0;
    foreach ($ip in $ips_tab) {
        $output += "|  $ip" + (" " * (($ip_length + 2) - $ip.length)) + " " + $hostnames[$i] + (" " * (($host_length - $hostnames[$i].Length) + 2)) + "|`n ";
        $output +=  (" " * ($ip_length + 4)) + "`n"
        $i++;
    }

    # Ligne du bas
    if (($ips_tab.Length -gt 0) -and ($ips_tab[0].Length -ge 7)) {
        $output +=  " " + ("-" * ($ip_length + 3)) + " " + ("-" * ($host_length + 3)) + "`n"
        $del_crs = $start_crs;
        $del_string = "";
        while ($del_crs.Y -lt $current_crs.Y) {
            $del_string += "                                             `n";
            $del_crs.Y++;
        }
    
        $host.UI.RawUI.CursorPosition = $start_crs;
        Write-Host -n $del_string;
        $host.UI.RawUI.CursorPosition = $start_crs;
        Write-Host -n $output -ForegroundColor Yellow
            
    }
    $current_crs = $host.UI.RawUI.CursorPosition;
    Remove-Variable -Name "cnt"
    Remove-Variable -Name "pings"
    Remove-Variable -Name "ping"
    Remove-Variable -Name "connected"
    Remove-Variable -Name "ips_tab"
    Remove-Variable -Name "output"
    Remove-Variable -Name "dnsREs"
    Remove-Variable -Name "hostnames"
}

<#
foreach ($cnd in $connected) {
    Write-Host $cnd;
    Write-Host "----------------";
}
#>