##Installing packages as root user

echo "Given mode:${1}"

#initializing variables

# QIIME_INSTALL_DIR="/home/galaxy/ext_tools/qiime"
# QIIME_REPO_SCRIPTS_DIR="/home/HELIOS/avaradha/dev_home/qiime"
# QIIME_REPO_TOOLS_DIR="/home/HELIOS/avaradha/dev_home/qiime/tools"
# GALAXY_DIR="/home/galaxy/galaxy-dist"
# TEMP_DIR="/tmp/qiime_tmp"

# R_LIB_PATH="${HOME}/tool_libs/R_libs"
# QIIME_DEPLOY_LOG="${TEMP_DIR}/qiime-deploy.log"
# QIIME_SOFTWARE_DIR="${QIIME_INSTALL_DIR}/qiime_software"


sudo sh install_packages_qiime.sh

# Reloadin shared libraries
sudo /sbin/ldconfig

# Quit the script if the user failed to provide the right password
# if [ $? -ne 0 ] ; then
  # echo "Script is exiting because you failed to give a valid password"
  # echo "Failed installing required packages"
  # exit 1
# fi

##Installing QIIME as  Galaxy user 
sudo -u galaxy sh integrate_qiime.sh ${1}

# # Quit the script if the user failed to provide the right password
# if [ $? -ne 0 ] ; then
  # echo "Script is exiting because you failed to give a valid password"
  # exit 1
# fi

















