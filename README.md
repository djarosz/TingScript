# TingScript
Bash script for filling the TING pen with audio books under Linux, which have to be downloaded

## Requirements ##
- TING pen with USB cable
- bash as shell (maybe other can run well, but can't be guaranteed)

## Before using the script
- turn TING pen on
- touch marker on book you want to upload with your TING pen
- put in the USB cable into the TING pen and connnec it to your computer
- wait untill pen is detected and mounted (or when it is detected mount it your self) 

## Usage of the script
```bash
./ting.sh
```
For auto detection of Ting folder over mount point and TBD.TXT/tbd.txt filename.

## Usage if auto detection fails
Check in which folder the $ting folder shows up, where the TBD.TXT file is
```shell
./ting.sh <pathOfFolderWhere$tingIs>
```
For example ./ting.sh /media/Ting if the /media/Ting includes the folder $ting in which the TBD.TXT file is

## Contributors
- Ralf Meyer https://github.com/ralfdonald
- Bernd Wurst https://github.com/bwurst
- Stefan Dangl https://github.com/stangls
- frog23 https://github.com/frog23
