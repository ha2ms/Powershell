# Netscan

Script qui affiche en temps réel toutes les adresses IP connectées au réseau selon la plage qui lui est attribué.


https://github.com/ha2ms/Powershell/assets/134864738/e70a387f-477d-4332-b6a6-9160372ede82

(Fonctionne seulement sur le dernier octet, de 0 à 255) 

## Installation

Télechargez le script netscan.ps1 et placez-le par exemple dans le C: sous un dossier Script
<p align="center">
    <img src="http://93.90.205.194/github/netscan/netscan_location.png" />
</p>

#### Activer l'exécution de script:
Ouvrez Powerhsell en mode administrateur, puis exécutez la commande ci-dessous puis refermez-la.
```Powershell
  Set-ExecutionPolicy Unrestricted
```
#### Ajouter le raccourci "netscan" pour exécuter le script sur le terminal
Ouvrez Powershell normalement (pas en mode administrateur) sinon le raccourci du script ne sera accesible que dans la console administrateur, puis exécutez cette commande.
```Powershell
  "Set-Alias -Name 'netscan' -Value 'C:\Script\netscan.ps1'" >> $PROFILE
```
Si vous obtenez une erreur, verifiez que les dossiers présents dans le chemin d'accès contenu dans la variable $PROFILE existent bien dans l'explorateur de fichier. Si ce n'est pas le cas, créer les dossiers manquants, (la création du fichier quant à lui ne sera pas nécessaire). Puis relancer la commande précédente.

#### Afficher le chemin complet du PROFILE
```Powershell
  $PROFILE
```
Une fois terminé vous n'avez plus qu'à fermer puis réouvrir Powershell et de tester la commande netscan.
