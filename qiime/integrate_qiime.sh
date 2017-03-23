#initializing variables
TEMP_DIR="/tmp/qiime_tmp"
QIIME_INSTALL_DIR="/home/galaxy/ext_tools/qiime"
QIIME_REPO_SCRIPTS_DIR="/home/HELIOS/avaradha/dev_home/qiime"
QIIME_REPO_TOOLS_DIR="/home/HELIOS/avaradha/dev_home/qiime/tools"
QIIME_SOFTWARE_DIR="${QIIME_INSTALL_DIR}/qiime_software"
GALAXY_DIR="/home/galaxy/galaxy"
R_LIB_PATH="${HOME}/tool_libs/R_libs"
QIIME_DEPLOY_LOG="${TEMP_DIR}/qiime-deploy.log"

LOCAL_PYTHON_LINK_PATH="/home/galaxy/ext_tools/python"
QIIME_WRAPPERS="${GALAXY_DIR}/tools/qiime1.8.0"
QIIME_SCRIPT_PATH="${QIIME_SOFTWARE_DIR}/qiime-1.8.0-release/bin"
QIIME_GALAXY_SCRIPT_PATH="${QIIME_INSTALL_DIR}/qiime-galaxy/scripts"

install_qiime(){
	
	echo "Inside install_qiime function"
	
	## making directory for qiime installation
	mkdir -p "${QIIME_INSTALL_DIR}"
	cd ${QIIME_INSTALL_DIR}
	# Overriding existing pythonpath to none. (previous path disturbing the installation)
	echo -e '\n##Overriding existing pythonpath to none. (previous path disturbing the installation)' >> $HOME/.bashrc
	echo 'export PYTHONPATH=' >> $HOME/.bashrc
	echo -e '\n##Qiime' >> $HOME/.bashrc 
	echo '#open-mpi path' >> $HOME/.bashrc
	echo 'export PATH=/usr/lib64/mpi/gcc/openmpi/bin:$PATH' >> $HOME/.bashrc
	echo 'export LD_LIBRARY_PATH=/usr/lib64/mpi/gcc/openmpi/lib64:$LD_LIBRARY_PATH' >> $HOME/.bashrc
	source $HOME/.bashrc
	
	## creating personal library for R

	mkdir -p ${R_LIB_PATH}
	echo '#R personal Library' >> $HOME/.bashrc
	echo 'export R_LIBS='${R_LIB_PATH}'' >> $HOME/.bashrc
	source $HOME/.bashrc
	
	

	##### make sure qiime deploy config file is modified properly
	cp -R ${QIIME_REPO_SCRIPTS_DIR}/qiime-deploy-conf/ ${QIIME_INSTALL_DIR}/
	
	##modify config file for qiime-deploy tool with path where all the tools are stored
	sed -i "s|<TOOLS_DIR>|${QIIME_REPO_TOOLS_DIR}|g" ${QIIME_INSTALL_DIR}/qiime-deploy-conf/qiime.conf

	## qiime deploy
	cp -R ${QIIME_REPO_SCRIPTS_DIR}/qiime-deploy ${QIIME_INSTALL_DIR}/
	cd ${QIIME_INSTALL_DIR}/qiime-deploy
	
	##removing existing qiime software directory 
	## rm -rf ${QIIME_SOFTWARE_DIR}
	
	python qiime-deploy.py ${QIIME_SOFTWARE_DIR}/ -f ${QIIME_INSTALL_DIR}/qiime-deploy-conf/qiime.conf --force-remove-failed-dirs >> ${QIIME_DEPLOY_LOG}
	source $HOME/.bashrc
	
	cat ${QIIME_DEPLOY_LOG}
	

} 

create_python_links(){

	#creating python links
	echo "Inside create_python_links function"
	mkdir -p ${LOCAL_PYTHON_LINK_PATH}
	ln -s /usr/bin/python ${LOCAL_PYTHON_LINK_PATH}/python2.6.8
	ln -s ${LOCAL_PYTHON_LINK_PATH}/python2.6.8 ${LOCAL_PYTHON_LINK_PATH}/python2.6
	
	ln -s ${QIIME_SOFTWARE_DIR}/python-2.7.3-release/bin/python ${LOCAL_PYTHON_LINK_PATH}/python2.7.3
	ln -s ${LOCAL_PYTHON_LINK_PATH}/python2.7.3 ${LOCAL_PYTHON_LINK_PATH}/python2.7
	
	#default
	ln -s ${LOCAL_PYTHON_LINK_PATH}/python2.6 ${LOCAL_PYTHON_LINK_PATH}/python
	
	echo '#Python Binary path' >> $HOME/.bashrc
	echo 'export PATH='${LOCAL_PYTHON_LINK_PATH}':$PATH' >> $HOME/.bashrc
	source $HOME/.bashrc
	
	

}

##Modify activate.sh file 
modify_activate_sh(){

	echo "Inside modify_activate_sh function"
	sed -i 's/export LD_LIBRARY_PATH=/export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/g' ${QIIME_SOFTWARE_DIR}/activate.sh
	source $HOME/.bashrc
}

##QIIME GALAXY INTEGRATION
integrate_on_galaxy(){

	echo "Inside integrate_on_galaxy function"
	cd ${QIIME_INSTALL_DIR}/
	#git clone https://github.com/qiime/qiime-galaxy.git
	cp -R ${QIIME_REPO_SCRIPTS_DIR}/qiime-galaxy/ ${QIIME_INSTALL_DIR}/
	cd ${QIIME_INSTALL_DIR}/qiime-galaxy
	echo '#qiime-galaxy path' >> $HOME/.bashrc
	echo 'export PATH='${QIIME_INSTALL_DIR}'/qiime-galaxy/scripts:$PATH' >> $HOME/.bashrc
	echo 'export PYTHONPATH='${QIIME_INSTALL_DIR}'/qiime-galaxy/lib:$PYTHONPATH' >> $HOME/.bashrc
	echo -e '\n' >> $HOME/.bashrc
	source $HOME/.bashrc
	${LOCAL_PYTHON_LINK_PATH}/python2.7.3 ${QIIME_INSTALL_DIR}/qiime-galaxy/scripts/integrate_on_galaxy.py -i ${QIIME_SCRIPT_PATH} -g ${GALAXY_DIR}/ -c ${QIIME_INSTALL_DIR}/qiime-galaxy/config_files/QIIME_1.8.0.conf --update_tool_conf
	
	## reformating tool_conf.xml 
	cp ${GALAXY_DIR}/tool_conf.xml ${TEMP_DIR}/
	xmllint --format ${TEMP_DIR}/tool_conf.xml > ${GALAXY_DIR}/tool_conf.xml

}

##QIIME CONNECTOR INTEGRATION
install_qiime_connector(){

	cp ${GALAXY_DIR}/tool_conf.xml ${TEMP_DIR}/
	x=`grep -c '<section.*id="qiime1.8.0".*' ${TEMP_DIR}/tool_conf.xml`
	y=`grep -c '<tool.*file="qiime_connector' ${TEMP_DIR}/tool_conf.xml`
	if [ ${x} -eq 0 ] 
		then
			echo "Qiime entry is not present in tool_conf.xml. Qiime connector installation failed"
			exit 1
		else
			if [ ${y} -eq 0 ]
				then
					echo "Qiime entry is present in tool_conf.xml. Adding Qiime Connector entry"
					sed '/<section id="qiime1.8.0"/a <tool file=\"qiime_connector/qiime_connector.xml\"/>' ${TEMP_DIR}/tool_conf.xml | xmllint --format - > ${GALAXY_DIR}/tool_conf.xml
					cp -R ${QIIME_REPO_SCRIPTS_DIR}/qiime_connector/ ${GALAXY_DIR}/tools/
					
				else
					echo "Qiime Connector entry is already present"
			fi
		fi

}

##modify wrappers to use python 2.7.3
modify_wrappers(){

	echo "Inside modify_wrappers function"

	if [ "$(ls -A ${QIIME_WRAPPERS})" ]
	then
	  for f in `ls ${QIIME_WRAPPERS}/*.xml`;
		do
			filename=`basename ${f} .xml`
			echo "Processing of  ${f} file with basename  ${filename}..."
			sed -i "s|${filename}.py|python2.7.3 ${QIIME_SCRIPT_PATH}/${filename}.py|g" ${f}
		done
		
		for f in `ls ${QIIME_GALAXY_SCRIPT_PATH}/*.py`;
		do
			echo "Replacing occurences of  ${f} file..."
			filename=`basename ${f}`
			filepath=`dirname ${f}`
			sed -i "s|${filename}|python2.7.3 ${filepath}/${filename}|g" ${QIIME_WRAPPERS}/*
		done
		
	else
	  echo "QIIME-GALAXY Integration failed. Cannot modify wrappers";
	fi
}


##Backup function before installing qiime
backUp() { 
	
	echo "Inside backUp function"	
	echo 'taking backup of important files'
	if [ ! -d "${TEMP_DIR}" ]; then
		mkdir -p ${TEMP_DIR}
	fi
	cp ${HOME}/.bashrc ${TEMP_DIR}/
	cp ${GALAXY_DIR}/tool_conf.xml ${GALAXY_DIR}/tool_conf.xml.qiime.bkp
  
}

##Rollback function if qiime installation failed
rollBack() {
	echo "Inside rollBack function"	
	echo 'rolling back !!!!!'
	cp ${TEMP_DIR}/.bashrc ${HOME}/.bashrc 
	rm -rf ${QIIME_INSTALL_DIR}
	rm -rf ${R_LIB_PATH}
	cp ${GALAXY_DIR}/tool_conf.xml.qiime.bkp ${GALAXY_DIR}/tool_conf.xml
	
	source $HOME/.bashrc
}

##Rollback function if qiime installation failed
check_qiime_install() {
	
	echo "Inside check_qiime_install function"	
	line_no=`sed -n "/Packages failed to deploy:/=" ${QIIME_DEPLOY_LOG}`
	failed_tools=`sed "$(($line_no+1)) q;d" ${QIIME_DEPLOY_LOG}`
	if [ "${failed_tools}" ];
	then
		echo 'Qiime Installation failed'
		echo 'Following dependent tools are failed during QIIME installation'
		echo ${failed_tools} 
		retval=0
	else
		echo 'Qiime Installed successfully'
		retval=1
	fi
	return ${retval}
}

## Removes unnecessary file after successfull qiime installation
remove_unwanted_files(){

	echo "Inside remove_unwanted_files function"

	echo "removing qiime-deploy-conf directory"
	rm -rf ${QIIME_INSTALL_DIR}/qiime-deploy-conf
	echo "removing qiime-deploy directory"
	rm -rf ${QIIME_INSTALL_DIR}/qiime-deploy
	echo "removing temp directory"
	rm -rf ${TEMP_DIR}

}

## calling backup function
backUp

#calling install_qiime function to install qiime tool
install_qiime

if [ "${1}" = "i" ]
then
	## Confirmation of installation process
	while true; do
		echo 'Please select the below option to continue'
		echo '1. QIIME INSTALLED SUCCESSFULLY. CONTINUE INTEGRATING QIIME AND GALAXY.'
		echo '2. QIIME INSTALLED SUCCESSFULLY. EXIT NOW !!'
		echo '3. QIIME INSTALLATION FAILED: REINSTALL QIIME'
		echo '4. QIIME INSTALLATION FAILED. ROLLBACK ANE EXIT !!!' 
		read -p "enter the option here -->" yn
		case $yn in
			[1]* ) 
				echo 'QIIME INSTALLED SUCCESSFULLY. CONTINUE INTEGRATING QIIME AND GALAXY.';
				create_python_links
				modify_activate_sh
				integrate_on_galaxy
				modify_wrappers				
				echo 'Integrated QIIME to GALAXY successfully';
				install_qiime_connector
				echo 'Qiime connecor installed successfully';
				break;;
			[2]* ) 
				echo 'QIIME INSTALLED SUCCESSFULLY. EXIT NOW !!';
				modify_activate_sh
				create_python_links
				echo 'EXITING NOW';
				break;;	
			[3]* )
				echo 'QIIME INSTALLATION FAILED: REINSTALL QIIME';
				rollBack
				install_qiime			
				continue;;
			[4]* ) 
				echo 'QIIME INSTALLATION FAILED. ROLLBACK ANE EXIT !!!';
				rollBack
				break;;        
			* ) echo "Please enter valid option";;
		esac
	done
else
	check_qiime_install
	retval=$?
	echo "returnValue from check Qiime Install:${retval}"
	if [ "${retval}" -eq 0 ]
	then
		echo "Qiime installation failed"
		echo "rolling back and exit ......"
		rollBack
	else
		echo "Qiime installed successfully"
		modify_activate_sh
		create_python_links		
		echo "Integrating Qiime and Galaxy......"
		integrate_on_galaxy		
		echo 'Integrated QIIME to GALAXY successfully';	
		modify_wrappers
		echo 'Qiime wrappers modified successfully';
		install_qiime_connector
		echo 'Qiime connecor installed successfully';
	fi
fi
remove_unwanted_files








