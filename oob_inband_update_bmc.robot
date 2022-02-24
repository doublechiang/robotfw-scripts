*** Settings ***
Documentation    SSH into in-band OS to update the BMC
Library          OperatingSystem
Library          Process
Library		 BuiltIn
Library		 SSHLibrary

*** Variables ***
${BMCIP}	10.16.9.112
${bmcuser}		dropbox
${bmcpass}		hhnFlaw5
${UUTHOST}	10.16.7.210
${sshuser}	root
${sshpass}	root


*** Test Cases ***

Inband update BMC then test for OOB ipmitool command
	[Setup]	
	[Documentation]		SSH and intoBIOS then SSH into host check if system boot into OS.
	FOR	${index}	IN RANGE 	1
		ssh update bmc
		sleep	120s
		oob bmc getsysname
	END
		

*** Keywords ***
ssh update bmc
	${rc}	${output}=	Run And Return Rc And Output	sshpass -p root ssh root@${UUTHOST} 's5sfs5sgv37711/linux-pc.sh s5sfs5sgv37711/rom.ima_enc'
	log		${output}
	Should Be Equal as Integers		${rc}	0

oob bmc getsysname
	${rc}	${output}=	Run And Return Rc And Output		ipmitool -H ${BMCIP} -U ${bmcuser} -P ${bmcpass} mc getsysinfo system_name
	log		${output}
	Should Be Equal		${output}	RMManager
	Should Be Equal as Integers		${rc}	0

		
	

