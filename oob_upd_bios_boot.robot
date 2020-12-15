*** Settings ***
Documentation    OOB Update BIOS and Checki boot into default OS.
Library          OperatingSystem
Library          Process
Library		 BuiltIn
Library		 SSHLibrary

*** Variables ***
${BMCIP}	10.16.1.149
${USER}		root
${PASS}		db9b3748e18a
${YafuPath}			~/tools/Yafuflash2/linuxflash/Linux_x86_64/Yafuflash2
${ubios_oob.sh}		~/tools/Yafuflash2/ubios_oob.sh
${BIOS14Img}		2020WW15.4_3B14.EBY05/3B14.EBY05.BIN_enc
${BIOS17Img}	2020WW45.5_3B17.EBY01/3B17.EBY01.BIN_enc
${UUTHOST}	10.16.10.201
${sshuser}	test
${sshpass}	root


*** Test Cases ***

Update BIOS and check boot into OS
	[Setup]	
	[Documentation]		Update BIOS then SSH into host check if system boot into OS.
	FOR	${index}	IN RANGE 	40
		${output}=	update bios		${BIOS17Img}
		log		${output}
		${output}=	update bios		${BIOS14Img}
		log		${output}

	END
		

*** Keywords ***
update bios
	[Arguments]	${biosimg}
	power off host
	${output}=	Run		${ubios_oob.sh} ${BMCIP} ${USER} ${PASS} ${biosimg}
	log		${output}
	sleep	5s
	power on host
	# wait ssytem power on
	sleep	300s
	${output}=	Host logon check
	log		${output}


power off host
	Run	ipmitool -H ${BMCIP} -U ${USER} -P ${PASS} chassis power off
	Sleep	10s
power on host		
	Run	ipmitool -H ${BMCIP} -U ${USER} -P ${PASS} chassis power on
	Sleep	5s

upgrade bios		
	${output}=	Run	${YafuPath} -d 2 -nw -ip ${BMCIP} -u ${USER} -p ${PASS} ${EBY05Img}
	Log		${output}
	Sleep	2s
	[return]	${output}

downgrade bios		
	${output}=	Run	${YafuPath} -d 2 -nw -ip ${BMCIP} -u ${USER} -p ${PASS} ${EBY03Img}
	Log		${output}
	Sleep	2s
	[return]	${output}

host power status
	${output}=	Run	ipmitool -H ${BMCIP} -U ${USER} -P ${PASS} chassis power status
	[return]	${output}

Host logon check
	Open Connection		${UUTHOST}
	${output}=	Login			${sshuser} 	${sshpass}	
	[return]	${output}
		
	

