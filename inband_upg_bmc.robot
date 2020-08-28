*** Settings ***
Documentation    Inband stress upgrade BMC.
Library          OperatingSystem
Library          Process
Library		 BuiltIn
# Library		 SSHLibrary

*** Variables ***
${BMCIP}	10.16.1.149
${USER}		root
${PASS}		db9b3748e18a
${YafuPath}	Yafuflash2_v4.16.21/linuxflash/Linux_x86_64/Yafuflash2
${EBY05Img}	2020WW15.4_3B14.EBY05/3B14.EBY05.BIN_enc
${EBY03Img}	S5B_3B14.EBY03_T8/S5B_3B14.EBY03_T8.BIN_enc
${UUTHOST}	10.16.8.72
${sshuser}	test
${sshpass}	password


*** Test Cases ***

Up/Downgrade BMC in-band
	[Setup]	
	[Documentation] 	upgrade/downgrade BMC inband and check free memory and return code.
	FOR	${index}	IN RANGE 	100
		${output}=	upgrade 4.96
		log		${output}
		${output}=	upgrade 4.97
		log		${output}
	END
		

*** Keywords ***
upgrade 4.96
	${output}=	Run	s5bx_s5sxv4960A${/}linux-pc.sh s5bx_s5sxv4960A${/}rom.ima_enc
	log		${output}
	${output}=	Run		free -m
	log		${output}
	sleep	240s
	[return]	${output}

upgrade 4.97
	${output}=	Run	s5bx_s5sxv4970A${/}linux-pc.sh s5bx_s5sxv4970A${/}rom.ima_enc
	log		${output}
	${output}=	Run		free -m
	log		${output}
	sleep	240s
	[return]	${output}



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

Host logon able
	Open Connection		${UUTHOST}
	Login			${sshuser} 	${sshpass}	
		
	

