'onboot.bas

CLS
Print
WEB NTP -5
Print "--------------------"
Print "Current Date and Time"
Print Date$ ; "@" ; Time$
Print "--------------------"
Print "Current IP Address"
Print MM.Info(IP Address)
Print "--------------------"
Drive "b:"
Print "Defaulting to B: drive"
Print "--------------------"
