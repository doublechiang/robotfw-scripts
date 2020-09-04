*** Settings ***
Documentation    BMC updating Test cases
Library          OperatingSystem
Library          Process
Library		BuiltIn
# Library		 SSHLibrary

*** Variables ***
${BMCIP}	10.16.1.149
${USER}		root
${PASS}		db9b3748e18a
${YafuPath}	Yafuflash2_v4.16.21/linuxflash/Linux_x86_64/Yafuflash2
${UUTHOST}	10.16.8.72
${sshuser}	test
${sshpass}	password


*** Test Cases ***

Up/Downgrade BMC OOB
	[Setup]	
	[Documentation] 	BMC update via http interface
	FOR	${index}	IN RANGE 	100
		${output}=	upgrade 4.98
		${output}=	upgrade 4.97
		log		${output}
	END
		

*** Keywords ***
upgrade 4.98
	${rc}	${output}=	Run And Return Rc And Output	bash -x ./BMC_update.sh ${BMCIP} ${USER} ${PASS} s5bx_s5sxv4980A${/}rom.ima_enc
	log		${output}
	Should Be Equal As Integers		${rc}	0
	sleep	120s
	# enable web & kvm services.
	Run		ipmitool -H ${BMCIP} -U ${USER} -P ${PASS} raw 0x32 0x6a 0x1 0x0 0x0 0x0 0x1 0x46 0x46 0x46 0x46 0x46 0x46 0x46 0x46 0x46 0x46 0x46 0x46 0x46 0x46 0x46 0x46 0x0 0x50 0x0 0x0 0x0 0xbb 0x1 0x0 0x0 0x8 0x7 0x0 0x0 0x0 0x0 
	sleep	2s
	Run		ipmitool -H ${BMCIP} -U ${USER} -P ${PASS} raw 0x32 0x6a 0x2 0x0 0x0 0x0 0x1 0x46 0x46 0x46 0x46 0x46 0x46 0x46 0x46 0x46 0x46 0x46 0x46 0x46 0x46 0x46 0x46 0x0 0x9a 0x1d 0x0 0x0 0x9e 0x1d 0x0 0x0 0x8 0x7 0x0 0x0 0x0 0x0
	sleep	2s
	# ebay default set to web & kvm disable, wait 2 minutes for the httpd service started.
	sleep	120s
	[return]	${output}

upgrade 4.97
	${rc}	${output}=	Run And Return Rc And Output	bash -x ./BMC_update.sh ${BMCIP} ${USER} ${PASS} s5bx_s5sxv4970A${/}rom.ima_enc
	log		${output}
	Should Be Equal As Integers		${rc}	0
	# 4.97 has won't reset bug, you need to wait 600s to get the BMC watchdog reset the system.
	sleep	600s
	# enable web & kvm services.
	${output}=	Run		ipmitool -H ${BMCIP} -U ${USER} -P ${PASS} raw 0x32 0x6a 0x1 0x0 0x0 0x0 0x1 0x46 0x46 0x46 0x46 0x46 0x46 0x46 0x46 0x46 0x46 0x46 0x46 0x46 0x46 0x46 0x46 0x0 0x50 0x0 0x0 0x0 0xbb 0x1 0x0 0x0 0x8 0x7 0x0 0x0 0x0 0x0 
	sleep	2s
	${output}=	Run		ipmitool -H ${BMCIP} -U ${USER} -P ${PASS} raw 0x32 0x6a 0x2 0x0 0x0 0x0 0x1 0x46 0x46 0x46 0x46 0x46 0x46 0x46 0x46 0x46 0x46 0x46 0x46 0x46 0x46 0x46 0x46 0x0 0x9a 0x1d 0x0 0x0 0x9e 0x1d 0x0 0x0 0x8 0x7 0x0 0x0 0x0 0x0
	sleep	2s
	# ebay default set to web & kvm disable, wait 2 minutes for the httpd service started.
	sleep	120s
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
		
	

