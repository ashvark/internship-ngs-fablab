#check and install packages

function zypper_checkInstall {

    ZYPPER_TOOL_VAR=$1
    
    if [ ! "`zypper --gpg-auto-import-keys se --match-exact $ZYPPER_TOOL_VAR | grep -w "package" | cut -f1 -d "|"`" = "i " ] ;
    then
        echo "Installing $ZYPPER_TOOL_VAR ..."
        zypper -n install $ZYPPER_TOOL_VAR
        echo "tool $ZYPPER_TOOL_VAR installed..."
    else
        echo "tool $ZYPPER_TOOL_VAR already exist..."
    fi
	
}
## Installing with force resolution option
function zypper_checkInstall_fc {

    ZYPPER_TOOL_VAR=$1
    
    if [ ! "`zypper --gpg-auto-import-keys se --match-exact $ZYPPER_TOOL_VAR | grep -w "package" | cut -f1 -d "|"`" = "i " ] ;
    then
        echo "Installing $ZYPPER_TOOL_VAR ..."
        zypper -n install --force-resolution $ZYPPER_TOOL_VAR
        echo "tool $ZYPPER_TOOL_VAR installed..."
    else
        echo "tool $ZYPPER_TOOL_VAR already exist..."
    fi
	
}

function zypper_repo_checkInstall {
	
	ZYPPER_TOOL_REPO_LINK=$1
    ZYPPER_TOOL_VAR=$2
	   
    if [ ! "`zypper --gpg-auto-import-keys se --match-exact $ZYPPER_TOOL_VAR | grep -w "package" | cut -f1 -d "|"`" = "i " ] ;
    then
        echo "Installing $ZYPPER_TOOL_VAR ..."
        zypper -n --gpg-auto-import-keys -p $ZYPPER_TOOL_REPO_LINK -v install $ZYPPER_TOOL_VAR
        echo "tool $ZYPPER_TOOL_VAR installed..."
    else
        echo "tool $ZYPPER_TOOL_VAR already exist..."
    fi
}

##installing with force resolution option
function zypper_repo_checkInstall_fc {
	
	ZYPPER_TOOL_REPO_LINK=$1
    ZYPPER_TOOL_VAR=$2
	   
    if [ ! "`zypper --gpg-auto-import-keys se --match-exact $ZYPPER_TOOL_VAR | grep -w "package" | cut -f1 -d "|"`" = "i " ] ;
    then
        echo "Installing $ZYPPER_TOOL_VAR ..."
        zypper -n --gpg-auto-import-keys -p $ZYPPER_TOOL_REPO_LINK -v install --force-resolution $ZYPPER_TOOL_VAR
        echo "tool $ZYPPER_TOOL_VAR installed..."
    else
        echo "tool $ZYPPER_TOOL_VAR already exist..."
    fi
}



#Basic library installation
zypper -n in -t pattern sdk_c_c++
zypper -n in -t pattern Basis-Devel
zypper_checkInstall ant
#zypper -n in libgfortran43 libgfortran45
zypper_checkInstall gcc
zypper_checkInstall gcc43-fortran
zypper_checkInstall gcc-fortran
zypper_checkInstall java-1_7_0-ibm-devel
zypper_checkInstall freetype 
zypper_checkInstall freetype-tools 
zypper_checkInstall freetype2
zypper_checkInstall freetype2-devel
zypper_checkInstall zlib
zypper_checkInstall zlib-devel
zypper_checkInstall mpich
zypper_checkInstall mpich-devel
zypper_checkInstall readline-devel
zypper_checkInstall gsl
zypper_checkInstall gsl-devel
zypper_checkInstall libxslt
zypper_checkInstall libpng-devel
zypper_checkInstall libpng12-0
zypper_checkInstall mysql
zypper_checkInstall mysql-tools
zypper_checkInstall libmysqlclient-devel
zypper_checkInstall xorg-x11-libXt
zypper_checkInstall xorg-x11-libXt-devel
zypper_checkInstall xorg-x11-libX11
zypper_checkInstall xorg-x11-libX11-devel
zypper_checkInstall libxml2
zypper_checkInstall xorg-x11-server
zypper_checkInstall dejavu
zypper_checkInstall python-devel
zypper_checkInstall sqlite3
zypper_checkInstall libsqlite3-0
zypper_checkInstall sqlite3-devel
zypper_checkInstall libncurses5
zypper_checkInstall ncurses-devel
zypper_checkInstall libbz2-devel
zypper_checkInstall libbz2-1
zypper_checkInstall git
zypper_checkInstall librdmacm
zypper_checkInstall liblapack3
zypper_checkInstall_fc blas
zypper_checkInstall_fc libblas3
zypper_checkInstall librdmacm-devel
zypper_checkInstall openmpi
zypper_checkInstall openmpi-devel
zypper_checkInstall xmlstarlet



zypper_repo_checkInstall http://download.opensuse.org/repositories/home:/fengshuo:/zeromq/SLE_11_SP1/ zeromq 
zypper_repo_checkInstall http://download.opensuse.org/repositories/home:/fengshuo:/zeromq/SLE_11_SP1/ zeromq-devel
zypper_repo_checkInstall http://download.opensuse.org/repositories/devel:/languages:/haskell/SLE_11_SP1/ ghc
zypper_repo_checkInstall http://download.opensuse.org/repositories/home:/repabuild/SLE_11_SP1/ libatlas3-devel 
# zypper_repo_checkInstall http://download.opensuse.org/repositories/home:/repabuild/SLE_11_SP1/ libblas3
# zypper_repo_checkInstall http://download.opensuse.org/repositories/home:/repabuild/SLE_11_SP1/ blas-devel  
zypper_repo_checkInstall http://download.opensuse.org/repositories/home:/repabuild/SLE_11_SP1/ liblash1
zypper_repo_checkInstall http://download.opensuse.org/repositories/home:/repabuild/SLE_11_SP1/ liblapack3
#zypper_repo_checkInstall http://download.opensuse.org/repositories/home:/repabuild/SLE_11_SP1/ lapack-devel


