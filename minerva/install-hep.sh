#!/bin/bash
#-------------------------------------------------------------|
#                                                             |
#     Installation script for Standalone SPUtils              |
#     Satyajit Jena -- s****a@gmail.com                       |
#     www.satyajitjena.in                                     |
#     https://github.com/dsjena                               |
#     3rd May 2020                                            |
#                                                             |
#     Inspired by Dario Berzano's scripts                     |
#     at dberzano/cern-alice-setup/                           | 
#                                                             |
#-------------------------------------------------------------|
export MNVPATH="${HOME}"
export MNVSOFT="mnv"
export NCORE="4"
export MNVSRC="source"
export MNVBUILD="build"
export SWALLOW_LOG=""
export MNVBASE="${HOME}/heptool"
export ERR=""
export OUT=""
export OS=""
export CMAKEVERSION_REQUIRED="3.0.0"
export ENVFILE="test.sh"
export CErr=$( echo -e "\033[31m" )
export CHig=$( echo -e "\033[33m" )
export CWar=$( echo -e "\033[36m" )
export CEmp=$( echo -e "\033[35m" )
export COff=$( echo -e "\033[m" )
export CTt=$( echo -e "\033[36m" )

# Make little beutifull 
#s--------------------------------- 1
function SetEnvFile() {
  MnvS "Setting Env files"
  MnvS "${MNVBASE}"
  dname="$(date +'%d-%b-%Y-%H%M%S')"
  dname1="$(date +'%d-%b-%Y-%H:%M:%S')"
  if [[ -f ${MNVBASE}/mnv-env.sh ]]
  then
    MnvS "Env file exixsts, let's create one and keep the backup"
	  mv ${MNVBASE}/mnv-env.sh ${MNVPATH}/tmp/${dname}-old-mnv-env.sh
  	touch ${MNVBASE}/mnv-env.sh
  else
    MnvS "File doesn't exists, let's create one!"
  	touch ${MNVBASE}/mnv-env.sh
  fi
  ENVFILE=${MNVBASE}/mnv-env.sh
  echo "#!/bin/bash" >> ${ENVFILE}
  echo "# Auto-generated source file! Don't edit it " >> ${ENVFILE}
  echo "# Created on: ${dname1} " >> ${ENVFILE}
  echo "" >> ${ENVFILE}
}
#a--------------------------------- A2
function MnvS() {
  #echo ""
  echo -e '\033[33m'"$1"'\033[m'
}
#t--------------------------------- T3
function WrnA() {
  #echo ""
  echo -e '\033[35m'"$1"'\033[m'
}

#y--------------------------------- Y4
function SetT() {
  #
  echo -e '\033[32m'"$1"'\033[m'
}

#a--------------------------------- A5
function FatY() {
  #echo ""
  echo -e '\033[31m'"Fatal Error: $1"'\033[m'
}
#j--------------------------------- J6
function AskA() {
  #echo ""
  echo -e '\033[34m'"$1"'\033[m'
}
#i--------------------------------- I7
function CalJ() {
  printf '\033[44m'$1'\033[m''\033[5m :\033[m'
}

#t--------------------------------- T8
# Returns date in current timezone in a compact format
function DatI() {
  date +%Y%m%d-%H%M%S
}

#s--------------------------------- S9
# Prints the time given in seconds in hours, minutes, seconds
function NicT() {
  local SS HH MM STR
  SS="$1"

  let "HH=SS / 3600"
  let "SS=SS % 3600"
  [ $HH -gt 0 ] && STR=" ${HH}h"

  let "MM=SS / 60"
  let "SS=SS % 60"
  [ $MM -gt 0 ] && STR="${STR} ${MM}m"

  [ $SS -gt 0 ] && STR="${STR} ${SS}s"
  [ "$STR" == "" ] && STR="0s"

  echo $STR

  #printf "%02dh %02dm %02ds" $HH $MM $SS
}
#a--------------------------------- A10
# Check if ROOT has a certain feature (case-insensitive match)
function RootConfiguredWithFeature() {
  if [[ -x "${ROOTSYS}/bin/root-config" ]] ; then
    "${ROOTSYS}/bin/root-config" --features | grep -qi "$1"
    return $?
  fi
  "$(dirname "$ROOTSYS")"/build/bin/root-config --features | grep -qi "$1"
}

#t--------------------------------- T11
function IsAvailable() {
  # very important function 
  local swhat=$1
  answer=$(which ${swhat})
  if [ "${answer}" != "" ];
  then
    sno=$(which ${swhat} | grep -c 'no' )
    sno_o=$(which ${swhat} | grep -c "no ${swhat}")
    if [ "${sno}" != "0" -o "${sno_o}" != "0" ];
    then
      answer=""
    fi
  fi
  if [ "$answer" != "" ];
  then
    return 1
  else
    return 0
  fi
}

#y--------------------------------- Y12
# Prints the command name when it is started.
#  - $1: command description
function SwallowStart() {
  local MSG OP

  OP="$1"
  shift

  MSG='*** ['"$(DatI)"'] BEGIN OP='"$OP"' CWD='"$PWD"' CMD='"$@"' ***'
  echo -e "\n\n$MSG" >> "$OUT"
  echo -e "\n\n$MSG" >> "$ERR"

  if [[ $DebugSwallow == 1 ]] ; then
    echo
    echo -e "\033[35m CWD:>\033[34m $PWD\033[m"
    for ((i=1 ; i<=$# ; i++)) ; do
      if [[ $i == 1 ]] ; then
        echo -e "\033[35m CMD:>\033[34m ${!i}\033[m"
      else
        echo -e "\033[35m $(printf '% 3u' $((i-1))):>\033[34m   ${!i}\033[m"
      fi
    done
  fi
  echo -en "[....] $OP..."

}

#a--------------------------------- A13
# Prints command's progress with percentage and time.
#  - $1: command description
#  - $2: current percentage
#  - $3: start timestamp (seconds)
function SwallowStep() {
  local TS_START OP MSG PCT PCT_FMT MODE

  if [ "$1" == '--pattern' ] || [ "$1" == '--percentage' ] ; then
    MODE="$1"
    shift
  fi

  OP="$1"
  PCT=$2
  TS_START=${3}

  let TS_DELTA=$(date +%s)-TS_START

  # Prints progress
  echo -ne '\r                                                  \r'
  if [ "$MODE" == '--pattern' ] ; then
    #local PROG_PATTERN=( '.   ' '..  ' '... ' '....' ' ...' '  ..' '   .' '    ' )
    local PROG_PATTERN=(   \
      'o...' 'O...' 'o...' \
      '.o..' '.O..' '.o..' \
      '..o.' '..O.' '..o.' \
      '...o' '...O' '...o' \
      '..o.' '..O.' '..o.' \
      '.o..' '.O..' '.o..' \
    )
    local PROG_IDX=$(( $PCT % ${#PROG_PATTERN[@]} ))
    echo -ne "[\033[34m${PROG_PATTERN[$PROG_IDX]}\033[m] $OP \033[36m$(NicT $TS_DELTA)\033[m"
  else
    PCT_FMT=$( printf "%3d%%" $PCT )
    echo -ne "[\033[34m$PCT_FMT\033[m] $OP \033[36m$(NicT $TS_DELTA)\033[m"
  fi
}


#a--------------------------------- A14
# Prints the command with its exit status (OK or FAILED) and time taken.
#  - $1: command description
#  - $2: the exit code of command
#  - $3: start timestamp (seconds) (optional)
#  - $4: end timestamp (seconds) (optional)
#  - $@: the command (from $5 on)
function SwallowEnd() {

  local TS_END TS_START OP MSG RET

  OP="$1"
  FATAL=$2
  RET=$3
  TS_START=${4-0}  # defaults to 0
  TS_END=${5-0}

  # After this line, $@ will contain the command
  shift 5

  let TS_DELTA=TS_END-TS_START

  # Prints success (green OK) or fail (red FAIL). In case FATAL=0
  # prints a warning (yellow SKIP) instead of an error
  echo -ne '\r'
  if [ $RET == 0 ]; then
    echo -ne '[ \033[32mOK\033[m ]'
  elif [ $FATAL == 0 ]; then
    echo -ne '[\033[33mSKIP\033[m]'
  else
    echo -ne '[\033[31mFAIL\033[m]'
  fi
  echo -ne " ${OP}"

  # Prints time only if greater than 1 second
  if [ $TS_DELTA -gt 1 ]; then
    echo -e " \033[36m$(NicT $TS_DELTA)\033[m"
  else
    echo "   "
  fi

  # On the log files (out, err)
  MSG='*** ['"$(DatI)"'] END OP='"$OP"' CWD='"$PWD"' ERR='"$RET"' CMD='"$@"' ***'
  echo -e "$MSG" >> "$OUT"
  echo -e "$MSG" >> "$ERR"

  return $RET
}


#a--------------------------------- A15
function fileNotFound {
    pack=$1
    shift
    files=$*
    retval=0
    for file in $files;do
      if [ -e $file ];     
      then 
        MnvS "*** Package $pack is OK ***" 
        return 1
      fi
    done
    return 0
}

#a--------------------------------- A16
# Logging all the outputs 
function Swallow() {

  local MSG ERRMSG RET TSSTART TSEND DELTAT FATAL OP

  # Options given?
  FATAL=0
  ERRMSG=''
  OKMSG=''
  while [[ "${1:0:1}" == '-' ]] ; do
    case "$1" in
      -f|--fatal)
        FATAL=1
      ;;
      --error-msg)
        ERRMSG="$2"
        shift
      ;;
      --success-msg)
        OKMSG="$2"
        shift
      ;;
    esac
    shift
  done

  OP="$1"
  shift

  SwallowStart "$OP" "$@"
  TSSTART=$(date +%s)

  "$@" >> "$OUT" 2>> "$ERR"
  RET=$?

  TSEND=$(date +%s)
  SwallowEnd "$OP" $FATAL $RET $TSSTART $TSEND "$@"

  if [[ $RET != 0 && $FATAL == 1 ]]; then
    if [[ "$ERRMSG" != '' ]] ; then
      # Produce a custom error message instead of log output
      echo
      echo -e "\033[31m${ERRMSG}\033[m"
      echo
    else
      LastLogLines -e "$OP"
    fi
    exit 1
  elif [[ $RET == 0 && "$OKMSG" != '' ]]; then
    echo
    echo -e "\033[32m${OKMSG}\033[m"
    echo
  fi

  return $RET
}

#a--------------------------------- A17
# Prints the last lines of both log files
function LastLogLines() {
  local LASTLINES=20
  local ISERROR=0

  if [ "$1" == "-e" ]; then
    echo ""
    echo -e "\033[41m\033[1;37mOperation \"$2\" ended with errors\033[m"
  fi

  echo ""
  echo -e "\033[33m=== Last $LASTLINES lines of stdout -- $SWALLOW_LOG.out ===\033[m"
  tail -n$LASTLINES "$SWALLOW_LOG".out
  echo ""
  echo -e "\033[33m=== Last $LASTLINES lines of stderr -- $SWALLOW_LOG.err ===\033[m"
  tail -n$LASTLINES "$SWALLOW_LOG".err
  echo ""
  echo -e "\033[31m=== Possible errors ===\033[m"
  cat "$SWALLOW_LOG".err | grep -B 2 'error:' --color
  echo ""

  [ "$1" == "-e" ] && ShowBugReportInfo
}

#a--------------------------------- A18
# Get file size - depending on the operating system
function GetFileSizeBytes() {(
  V=$( wc -c "$1" | awk '{ print $1 }' )
  echo $V
)}

#a--------------------------------- A18
# Shows a message reminding user to send the log files when asking for support
function ShowBugReportInfo() {
  echo ""
  echo -e "\033[41m\033[1;37mWhen asking for support, please send an email attaching the following file(s):\033[m"
  echo ""
  [ -s "$ERR" ] && echo "  $ERR"
  [ -s "$OUT" ] && echo "  $OUT"
  echo ""
  echo -e "\033[41m\033[1;37mNote:\033[m should you be concerned about private information contained"
  echo "      in the logs, you can edit them before sending."
  echo ""
}

#a--------------------------------- A19
# Progress with moving dots
function SwallowProgress() {
  local BkgPid Op Fatal TsStart TsEnd Size OldSize Ret ProgressCount

  if [ "$1" == '-f' ] ; then
    Fatal=1
    shift
  else
    Fatal=0
  fi

  if [ "$1" == '--pattern' ] || [ "$1" == '--percentage' ] ; then
    Mode="$1"
    shift
  fi

  Op="$1"
  shift

  SwallowStart "$Op" "$@"
  TsStart=$( date +%s )

  "$@" >> "$OUT" 2>> "$ERR" &
  BkgPid=$!

  Size=0
  ProgressCount=-1

  while kill -0 $BkgPid > /dev/null 2>&1 ; do
    if [ "$Mode" == '--pattern' ] ; then
      # Based on output size
      OldSize="$Size"
      Size=$( GetFileSizeBytes "$OUT" )
      if [ "$OldSize" != "$Size" ] ; then
        let ProgressCount++
      fi
    else
      # Based on the percentage (default)
      ProgressCount=$( tail -n10 "$OUT" | grep -Eo '[0-9]{1,3}([,\.][0-9])?%' | tail -n1 | tr -d '%' )
      ProgressCount=${ProgressCount%%,*}
      ProgressCount=${ProgressCount%%.*}
      ProgressCount=$((ProgressCount+0))
    fi
    SwallowStep $Mode "$Op" $ProgressCount $TsStart
    sleep 1
  done

  wait $BkgPid
  Ret=$?

  TsEnd=$( date +%s )
  SwallowEnd "$Op" $Fatal $Ret $TsStart $TsEnd "$@"

  if [[ $Ret != 0 && $Fatal == 1 ]]; then
    LastLogLines -e "$Op"
    exit 1
  fi

  return $Ret
}

#a--------------------------------- A20
function InstallCmake() {
    local module="cmake"
    local ForceCleanSlate="$1"
    MnvS "Installing ${module}..."

    local mgit="${MNVSRC}/${module}"
    local mbuild="${MNVBUILD}/${module}/build"
    local minstall="${MNVBUILD}/${module}/install"
    local mGitUrl='https://github.com/dsjena/CMake'

    SetT " Working dir: ${MNVPATH} \n Root Base: ${mgit} \n ROOTSYS: ${minstall}"
    MnvS "Configuring ${module} directory"
    local DO_IT_NOW=0
    if [[ ! -e "${mgit}/.git" ]] ; then
	      mkdir -p "${mgit}"
        cd "${mgit}"
        DO_IT_NOW=1
        MnvS "Downloading ${module} latest.. It will take some time"
        SwallowProgress -f --pattern 'Cloning '${module}'....' \
            git clone "${mGitUrl}" .
    else
        cd "${mgit}"
              SwallowProgress -f --pattern 'Updating '${module}'....' \
                  git pull
        if [ ${ForceCleanInstall} == 1 ]
        then
          rm -rf "${mbuild}"
          DO_IT_NOW=1
        else
          DO_IT_NOW=0
        fi
    fi
    if [ ${DO_IT_NOW} == 1 ] 
    then 
    	mkdir -p "${mbuild}" 
    	cd "${mbuild}"

      #echo " 
      ## Disable Java capabilities; we don't need it and on OS X might miss the
      ## required /System/Library/Frameworks/JavaVM.framework/Headers/jni.h.
      #SET(JNI_H FALSE CACHE BOOL "" FORCE)
      #SET(Java_JAVA_EXECUTABLE FALSE CACHE BOOL "" FORCE)
      #SET(Java_JAVAC_EXECUTABLE FALSE CACHE BOOL "" FORCE)
      ## SL6 with GCC 4.6.1 and LTO requires -ltinfo with -lcurses for link to succeed,
      ## but cmake is not smart enough to find it. We do not really need ccmake anyway,
      ## so just disable it.
      #SET(BUILD_CursesDialog FALSE CACHE BOOL "" FORCE)
      #" > build-flags.cmake

      SwallowProgress -f --pattern 'Building '${module}': configuring' \
          ${mgit}/bootstrap --prefix=${minstall} 
          #                     --init=build-flags.cmake
      SwallowProgress -f --pattern 'Building '${module}': compiling' \
          make
      SwallowProgress -f --pattern 'Building'${module}': Installing' \
          make install

    else
        MnvS "${module} is installed or folder is existing.."
   fi	
   # ALWAYS Create the source file
   echo "# CMAKE Variables" >> ${ENVFILE} 
   echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:${minstall}/lib" >> ${ENVFILE}
   echo "export DYLD_LIBRARY_PATH=\$DYLD_LIBRARY_PATH:${minstall}/lib" >> ${ENVFILE}
   echo "export PATH=\$PATH:${minstall}/bin" >> ${ENVFILE}
   export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${minstall}/lib
   export DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH:${minstall}/lib
   export PATH=$PATH:${minstall}/bin
   echo "" >> ${ENVFILE}
}

#a--------------------------------- A21
function Help() {
  local Cmd='bash <(curl -fsSL http://satyajitjena.in)'
  cat <<_EoF_
${CTt}install-mnv.sh${COff} -- by S. Jena <www.satyajitjena.in>
_EoF_
}

function Logo() {
echo -e ' \033[36m
------------------------------------------------------------------
              _   _  ___________ _____ _____  _____ _     
             | | | ||  ___| ___ \_   _|  _  ||  _  | |    
             | |_| || |__ | |_/ / | | | | | || | | | |    
             |  _  ||  __||  __/  | | | | | || | | | |    
             | | | || |___| |     | | \ \_/ /\ \_/ / |____
             \_| |_/\____/\_|     \_/  \___/  \___/\_____/
                                                                           
         --> Wecome to Installer script to install heptool <---   
      --> CMAKE, ROOT, BOOST, Send me request to include more <--
------------------------------------------------------------------
\033[m'
}
#a--------------------------------- A21
function InstallBoost() {
  local module="boost"
  local ForceCleanInstall="$1"

  MnvS "Installing ${module}..."
  local mgit="${MNVSRC}/${module}"
  local mbuild="${MNVBUILD}/${module}/build"
  local minstall="${MNVBUILD}/${module}/install"

  #local mGitUrl='https://github.com/dsjena/boost'
  local mGitUrl='https://github.com/boostorg/boost.git'

  SetT " Working dir: ${MNVPATH} \n Root Base: ${mgit} \n ROOTSYS: ${minstall}"

  MnvS "Configuring ${module} directory"
  local DO_IT_NOW=0
  if [[ ! -e "${mgit}/.git" ]] ; then
	    mkdir -p "${mgit}"
      cd "${mgit}"
      DO_IT_NOW=1
      MnvS "Downloading ${module} latest.. It will take some time"
      SwallowProgress -f --pattern 'Cloning '${module}'....' \
          git clone --recurse-submodules "${mGitUrl}" .
  else
      cd "${mgit}"
            SwallowProgress -f --pattern 'Updating '${module}'....' \
                git pull
      if [ ${ForceCleanInstall} == 1 ]
      then
        rm -rf "${mbuild}"
        DO_IT_NOW=1
      else
        DO_IT_NOW=0
      fi
  fi
  if [ ${DO_IT_NOW} == 1 ] 
  then 
  	mkdir -p "${mbuild}" 
  	cd "${mbuild}"
  	rsync -a ${mgit}/ ${mbuild}/
  	#echo " 
  	## Disable Java capabilities; we don't need it and on OS X might miss the
  	## required /System/Library/Frameworks/JavaVM.framework/Headers/jni.h.
  	#SET(JNI_H FALSE CACHE BOOL "" FORCE)
  	#SET(Java_JAVA_EXECUTABLE FALSE CACHE BOOL "" FORCE)
  	#SET(Java_JAVAC_EXECUTABLE FALSE CACHE BOOL "" FORCE)
  	## SL6 with GCC 4.6.1 and LTO requires -ltinfo with -lcurses for link to succeed,
  	## but cmake is not smart enough to find it. We do not really need ccmake anyway,
  	## so just disable it.
  	#SET(BUILD_CursesDialog FALSE CACHE BOOL "" FORCE)
  	#" > build-flags.cmake
  	SwallowProgress -f --pattern 'Building '${module}': configuring' \
   	    ${mbuild}/bootstrap.sh  
       #                     --init=build-flags.cmake
  	SwallowProgress -f --pattern 'Building '${module}': compiling' \
  	    ./b2 install --prefix=${minstall}
  	SwallowProgress -f --pattern 'Building '${module}': Installing' \
      ./b2 headers install
  else
       MnvS "${module} is installed or folder is existing.."
  fi	
  # ALWAYS Create the source file
  echo "# BOOST Variables" >> ${ENVFILE} 
  echo "export BOOSTDIR=${minstall}" >> ${ENVFILE}
  echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:${minstall}/lib">> ${ENVFILE}
  echo "export DYLD_LIBRARY_PATH=\$DYLD_LIBRARY_PATH:${minstall}/lib">> ${ENVFILE}
  echo "export PATH=\$PATH:${minstall}/bin">> ${ENVFILE}
  export BOOSTDIR=${minstall}
  export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${minstall}/lib
  export DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH:${minstall}/lib
  echo "" >> ${ENVFILE}
  cd ${MNVBASE}
}

#a--------------------------------- A22
function InstallBoostTag() {
  local module="boost"
  local ForceCleanInstall="$1"
  MnvS "Installing ${module}..." 
  local mgit="${MNVSRC}/${module}"
  local mbuild="${MNVBUILD}/${module}/build"
  local minstall="${MNVBUILD}/${module}/install"
  #local mGitUrl='https://github.com/dsjena/boost'
  local tag="boost_1_72_0"
  local mGitUrl='https://dl.bintray.com/boostorg/release/1.72.0/source/'${tag}'.tar.gz'
  SetT " Working dir: ${MNVPATH} \n Root Base: ${mgit} \n ROOTSYS: ${minstall}"
  MnvS "Configuring ${module} directory"
  local DO_IT_NOW=0
  if [[ ! -e "${mgit}/boost_1_72_0.tar.gz" ]] ; then
	    mkdir -p "${mgit}"
      cd "${mgit}"
      DO_IT_NOW=1
      MnvS "Downloading ${module} latest.. It will take some time"
      SwallowProgress -f --pattern 'Downloading '${module}'....' \
          wget "${mGitUrl}"  
      SwallowProgress -f --pattern 'UnTar '${module}'....' \
          tar -zxvf ${tag}.tar.gz
      #SwallowProgress -f --pattern 'moving it to proper places'${module}'....' \    
      #    rsync -av ${tag}/* .
  else
      cd "${mgit}"
      SwallowProgress -f --pattern 'Updating '${module}'....' \
        tar -zxvf ${tag}.tar.gz 
      #SwallowProgress -f --pattern 'moving it to proper places'${module}'....' \    
      #  rsync -av ${tag}/* .
      if [ ${ForceCleanInstall} == 1 ]
      then
        rm -rf "${mbuild}"
        DO_IT_NOW=1
      else
        DO_IT_NOW=0
      fi
  fi
  if [ ${DO_IT_NOW} == 1 ] 
  then 
  	mkdir -p "${mbuild}" 
  	cd "${mbuild}"
  	rsync -a ${mgit}/${tag}/ ${mbuild}/
  	#echo " 
  	## Disable Java capabilities; we don't need it and on OS X might miss the
  	## required /System/Library/Frameworks/JavaVM.framework/Headers/jni.h.
  	#SET(JNI_H FALSE CACHE BOOL "" FORCE)
  	#SET(Java_JAVA_EXECUTABLE FALSE CACHE BOOL "" FORCE)
  	#SET(Java_JAVAC_EXECUTABLE FALSE CACHE BOOL "" FORCE)
  	## SL6 with GCC 4.6.1 and LTO requires -ltinfo with -lcurses for link to succeed,
  	## but cmake is not smart enough to find it. We do not really need ccmake anyway,
  	## so just disable it.
  	#SET(BUILD_CursesDialog FALSE CACHE BOOL "" FORCE)
  	#" > build-flags.cmak
  	SwallowProgress -f --pattern 'Building '${module}': configuring' \
   	    ${mbuild}/bootstrap.sh  
       #                     --init=build-flags.cmake
  	SwallowProgress -f --pattern 'Building '${module}': compiling' \
  	    ./b2 --prefix=${minstall}
  	SwallowProgress -f --pattern 'Building '${module}': Installing' \
      ./b2 headers install
  else
       MnvS "${module} is installed or folder is existing.."
  fi	
  # ALWAYS Create the source file
  echo "# BOOST Variables" >> ${ENVFILE} 
  echo "export BOOSTDIR=${minstall}" >> ${ENVFILE}
  echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:${minstall}/lib">> ${ENVFILE}
  echo "export DYLD_LIBRARY_PATH=\$DYLD_LIBRARY_PATH:${minstall}/lib">> ${ENVFILE}
  echo "export PATH=\$PATH:${minstall}/bin">> ${ENVFILE}
  export BOOSTDIR=${minstall}
  export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${minstall}/lib
  export DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH:${minstall}/lib
  echo "" >> ${ENVFILE}
  cd ${MNVBASE}
}



#a--------------------------------- A23
function InstallRoot() {
  local module="root"
  local ForceCleanInstall="$1"
  MnvS "Installing ${module}..."
  local mgit="${MNVSRC}/${module}"
  local mbuild="${MNVBUILD}/${module}/build"
  local minstall="${MNVBUILD}/${module}/install"
  #local mGitUrl='https://github.com/dsjena/boost'
  #local mGitUrl='https://github.com/dsjena/root.git'
  local mGitUrl='https://github.com/root-project/root.git'
  SetT " Working dir: ${MNVPATH} \n Root Base: ${mgit} \n ROOTSYS: ${minstall}"
  MnvS "Configuring ${module} directory"
  local DO_IT_NOW=0
  if [[ ! -e "${mgit}/.git" ]] ; then
	    mkdir -p "${mgit}"
      cd "${mgit}"
      DO_IT_NOW=1
      MnvS "Downloading ${module} latest.. It will take some time"
      SwallowProgress -f --pattern 'Cloning '${module}'....' \
          git clone "${mGitUrl}" .
  else
      cd "${mgit}"
            SwallowProgress -f --pattern 'Updating '${module}'....' \
                git pull
      if [ ${ForceCleanInstall} == 1 ]
      then
        rm -rf "${mbuild}"
        DO_IT_NOW=1
      else
        DO_IT_NOW=0
      fi
  fi
  if [ ${DO_IT_NOW} == 1 ] 
  then 
  	mkdir -p "${mbuild}" 
  	cd "${mbuild}"
  	#echo " 
  	## SL6 with GCC 4.6.1 and LTO requires -ltinfo with -lcurses for link to succeed,
  	## but cmake is not smart enough to find it. We do not really need ccmake anyway,
  	## so just disable it.
  	#SET(BUILD_CursesDialog FALSE CACHE BOOL "" FORCE)
    SwallowProgress -f --pattern 'Building '${module}': configuring' \
      cmake "${mgit}"
    SwallowProgress -f --pattern 'Building '${module}': compiling' \
        cmake --build . -- -j${NCORE}
    SwallowProgress -f --pattern 'Building '${module}': Installing' \
        cmake -DCMAKE_INSTALL_PREFIX=${minstall} -P cmake_install.cmake
  else
      MnvS "${module} is installed or folder is existing.."
  fi	
  # ALWAYS Create the source file
  echo "# ROOT Variables" >> ${ENVFILE} 
  echo "# There are two ways to do it, one you call through autogenerated script" >> ${ENVFILE} 
  echo "# other fix path, we use auto-generated script" >> ${ENVFILE} 
  echo "source ${minstall}/bin/thisroot.sh">> ${ENVFILE} 
  source ${minstall}/bin/thisroot.sh
  echo "" >> ${ENVFILE}

  cd ${MNVBASE}
}


#a--------------------------------- A23
function InstallRooUnfold() {
  local module="RooUnfold"
  local ForceCleanInstall="$1"
  MnvS "Installing ${module}..."
  local mgit="${MNVSRC}/${module}"
  local mbuild="${MNVBUILD}/${module}/build"
  local minstall="${MNVBUILD}/${module}/install"
  #local mGitUrl='https://github.com/dsjena/boost'
  local mGitUrl='https://github.com/dsjena/RooUnfold.git'
  SetT " Working dir: ${MNVPATH} \n Root Base: ${mgit} \n ROOTSYS: ${minstall}"
  MnvS "Configuring ${module} directory"
  local DO_IT_NOW=0
  if [[ ! -e "${mgit}/.git" ]] ; then
	    mkdir -p "${mgit}"
      cd "${mgit}"
      DO_IT_NOW=1
      MnvS "Downloading ${module} latest.. It will take some time"
      SwallowProgress -f --pattern 'Cloning '${module}'....' \
          git clone "${mGitUrl}" .
  else
      cd "${mgit}"
        SwallowProgress -f --pattern 'Updating '${module}'....' \
          git pull
      if [ ${ForceCleanInstall} == 1 ]
      then
        rm -rf "${mbuild}"
        DO_IT_NOW=1
      else
        DO_IT_NOW=0
      fi
  fi
  if [ ${DO_IT_NOW} == 1 ] 
  then 
  	mkdir -p "${mbuild}" 
  	cd "${mbuild}"
  	#echo " 
  	## SL6 with GCC 4.6.1 and LTO requires -ltinfo with -lcurses for link to succeed,
  	## but cmake is not smart enough to find it. We do not really need ccmake anyway,
  	## so just disable it.
  	#SET(BUILD_CursesDialog FALSE CACHE BOOL "" FORCE)
    SwallowProgress -f --pattern 'Building '${module}': configuring' \
      cmake "${mgit}"
    SwallowProgress -f --pattern 'Building '${module}': compiling' \
      make -j${NCORE}
    #SwallowProgress -f --pattern 'Building '${module}': compiling' \
    #    cmake --build . -- -j${NCORE}
    #SwallowProgress -f --pattern 'Building '${module}': Installing' \
    #    cmake -DCMAKE_INSTALL_PREFIX=${minstall} -P cmake_install.cmake
  else
      MnvS "${module} is installed or folder is existing.."
  fi	
  # ALWAYS Create the source file
  echo "# RooUnfold" >> ${ENVFILE} 
  echo "source ${mbuild}/setup.sh">> ${ENVFILE} 
  source ${mbuild}/setup.sh
  echo "" >> ${ENVFILE}
  cd ${MNVBASE}
}


#a--------------------------------- A24
function InstallSPU() {
    local module="SPUtils"
    local ForceCleanInstall="$1"
    MnvS "Installing ${module}..."

    local mgit="${MNVSRC}/${module}"
    local mbuild="${MNVBUILD}/${module}/build"
    local minstall="${MNVBUILD}/${module}/install"
    #local mGitUrl='https://github.com/dsjena/boost'
    local mGitUrl='https://github.com/dsjena/SPUtils.git'

    SetT " Working dir: ${MNVPATH} \n Root Base: ${mgit} \n ROOTSYS: ${minstall}"
    MnvS "Configuring ${module} directory"
    local DO_IT_NOW=0
    if [[ ! -e "${mgit}/.git" ]] ; then
	      mkdir -p "${mgit}"
        cd "${mgit}"
        DO_IT_NOW=1
        MnvS "Downloading ${module} latest.. It will take some time"
        SwallowProgress -f --pattern 'Cloning '${module}'....' \
            git clone "${mGitUrl}" .
    else
        cd "${mgit}"
        SwallowProgress -f --pattern 'Updating '${module}'....' \
          git pull
        if [ ${ForceCleanInstall} == 1 ]
        then
          rm -rf "${mbuild}"
          DO_IT_NOW=1
        else
          DO_IT_NOW=0
        fi
    fi
    if [ ${DO_IT_NOW} == 1 ] 
    then 
    	mkdir -p "${mbuild}" 
    	cd "${mbuild}"
      SwallowProgress -f --pattern 'Building '${module}': configuring' \
          cmake "${mgit}"
      SwallowProgress -f --pattern 'Building '${module}': compiling' \
          cmake --build . -- -j${NCORE}
      SwallowProgress -f --pattern 'Building '${module}': Installing' \
          cmake -DCMAKE_INSTALL_PREFIX=${minstall} -P cmake_install.cmake
   else
        MnvS "${module} is installed or folder is existing.."
   fi	
   # ALWAYS Create the source file
   echo "# PlotUtils Variables " >> ${ENVFILE} 
   echo "export SPUTILS=${minstall}">> ${ENVFILE}
   echo "export PLOTUTILSROOT=${minstall}">> ${ENVFILE}
   echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:${minstall}/lib">> ${ENVFILE}
   echo "export DYLD_LIBRARY_PATH=\$DYLD_LIBRARY_PATH:${minstall}/lib">> ${ENVFILE}
   echo "export PATH=\$PATH:${minstall}/bin">> ${ENVFILE}
   export SPUTILS=${minstall}
   export PLOTUTILSROOT=${minstall}
   export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${minstall}/lib
   export DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH:${minstall}/lib
   export PATH=$PATH:${minstall}/bin
   echo "" >> ${ENVFILE}
   cd ${MNVBASE}
}

#a--------------------------------- A25
function InstallDPU() {
    
    InstallRooUnfold 1

    local module="DPUtils"
    local ForceCleanInstall="$1"
    MnvS "Installing ${module}..."

    local mgit="${MNVSRC}/${module}"
    local mbuild="${MNVBUILD}/${module}/build"
    local minstall="${MNVBUILD}/${module}/install"
    #local mGitUrl='https://github.com/dsjena/boost'
    local mGitUrl='https://github.com/dsjena/SPUtils.git'

    SetT " Working dir: ${MNVPATH} \n Root Base: ${mgit} \n ROOTSYS: ${minstall}"
    MnvS "Configuring ${module} directory"
    local DO_IT_NOW=0
    if [[ ! -e "${mgit}/.git" ]] ; then
	      mkdir -p "${mgit}"
        cd "${mgit}"
        DO_IT_NOW=1
        MnvS "Downloading ${module} latest.. It will take some time"
        SwallowProgress -f --pattern 'Cloning '${module}'....' \
            git clone "${mGitUrl}" .
    else
        cd "${mgit}"
        SwallowProgress -f --pattern 'Updating '${module}'....' \
          git pull
        if [ ${ForceCleanInstall} == 1 ]
        then
          rm -rf "${mbuild}"
          DO_IT_NOW=1
        else
          DO_IT_NOW=0
        fi
    fi
    if [ ${DO_IT_NOW} == 1 ] 
    then 
    	mkdir -p "${mbuild}" 
    	cd "${mbuild}"
      SwallowProgress -f --pattern 'Configuring '${module}': configuring' \
          cmake "${mgit}" -DCMAKE_INSTALL_PREFIX=${minstall}
      SwallowProgress -f --pattern 'Building '${module}': compiling' \
          make 
      SwallowProgress -f --pattern 'Installing '${module}': Installing' \
          make install

      #SwallowProgress -f --pattern 'Configuring '${module}': configuring' \
      #    cmake "${mgit}"
      #SwallowProgress -f --pattern 'Building '${module}': compiling' \
      #    cmake --build . -- -j${NCORE}
      #SwallowProgress -f --pattern 'Installing '${module}': Installing' \
      #    cmake -DCMAKE_INSTALL_PREFIX=${minstall} -P cmake_install.cmake
   else
        MnvS "${module} is installed or folder is existing.."
   fi	
   # ALWAYS Create the source file
   echo "# PlotUtils Variables" >> ${ENVFILE} 
   echo "export DPUTILS=${minstall}">> ${ENVFILE}
   echo "export PLOTUTILSROOT=${minstall}">> ${ENVFILE}
   echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:\${DPUTILS}/lib">> ${ENVFILE}
   echo "export DYLD_LIBRARY_PATH=\$DYLD_LIBRARY_PATH:\${DPUTILS}/lib">> ${ENVFILE}
   echo "export PATH=\$PATH:${minstall}/bin">> ${ENVFILE}
   export DPUTILS=${minstall}
   export PLOTUTILSROOT=${minstall}
   export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${minstall}/lib
   export DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH:${minstall}/lib
   export PATH=$PATH:${minstall}/bin
   echo "" >> ${ENVFILE}
   cd ${MNVBASE}
}

#a--------------------------------- A18
function DownloadSPU() {
    local module="SPUtils"
    MnvS "Installing ${module}..."

    local mgit="${MNVSRC}/${module}"
    local mbuild="${MNVBUILD}/${module}/build"
    local minstall="${MNVBUILD}/${module}/install"
    local mGitUrl='https://github.com/dsjena/SPUtils.git'

    if [[ ! -e "${mgit}/.git" ]] ; then
	    mkdir -p "${mgit}"
        cd "${mgit}"
        MnvS "Downloading ${module} latest.. It will take some time"
        SwallowProgress -f --pattern 'Cloning '${module}'....' \
            git clone "${mGitUrl}" .
    else
        cd "${mgit}"
        SwallowProgress -f --pattern 'Updating '${module}'....' \
            git pull
    fi
    cd ${MNVBASE}
}
#a--------------------------------- A18
function DownloadDPU() {
  local module="DPUtils"
  MnvS "Installing ${module}..."
  local mgit="${MNVSRC}/${module}"
  local mbuild="${MNVBUILD}/${module}/build"
  local minstall="${MNVBUILD}/${module}/install"
  local mGitUrl='https://github.com/dsjena/DPUtils.git'
  if [[ ! -e "${mgit}/.git" ]] ; then
	  mkdir -p "${mgit}"
      cd "${mgit}"
      MnvS "Downloading ${module} latest.. It will take some time"
      SwallowProgress -f --pattern 'Cloning '${module}'....' \
          git clone "${mGitUrl}" .
  else
      cd "${mgit}"
      SwallowProgress -f --pattern 'Updating '${module}'....' \
          git pull
  fi
  cd ${MNVBASE}
}
#a--------------------------------- A18
function FurnishRequirement() {

  MnvS 'Checking prerequisites...'
  MnvS '---------------------------------------------------'
  SetT '---> This is a contineously Developing Project <---'
  SetT '--->     We are Adding Functionality slowly    <---'
  SetT '--->      Auto System Chack Will be added!     <---'
  MnvS '---------------------------------------------------'
  local KernelName=`uname -s`
  local VerFile='/etc/lsb-release'
  local OsName
  local OsVer

  case "$(uname -s)" in
    Linux)  OS=linux;;
    Darwin) OS=darwin;;
    *_NT-*) OS=windows;;
  esac

  #SetT ${KernelName}
  #SetT ${VerFile}

  if [[ $(uname) == Darwin ]]; then
    #"xcode-select" "--print-path"
    [ -d /Library/Developer/CommandLineTools ]
  fi
}

#a--------------------------------- A18
function InitialWord() {
  echo -e "
  Note that this is an automated script you can usethis script , and  
  Manual method of installation. This installer can be used to install 
  ROOT, BOOST CMAKE all of them or one of them depending what are you 
  setting during the installation process. If your instllation somehow 
  crashes, please send me a mail with two files it prompted for you to 
  send, so that I will be able to fix some issues. I am not currently 
  adding any dependecnies to this instllation, you can always follow 
  the dependencies (system level in the help page)
"                            
}
#a--------------------------------- A18
function finalWord() {
  echo -e '\033[35m'"

  Please load your mnv-env.sh script everytime you open the your 
  terminal or you can add this script to the bashscript.
"'\033[m'
echo -e '\033[36m'"
        source ${HOME}/mnv-env.sh
"'\033[m'

}

#a--------------------------------- A18
function ShowWarning() {
   echo ""
   WrnA "---------------******* Warning  ********  ----------------------"
   WrnA "SPUTils is currently in private GIT hub, so, you need to provide"
   WrnA "passward. During instllation process to download these packages"
   WrnA "and work it properly thus please provide login and passwrd when "
   WrnA "github ask same to do..... Once we make this public, then it is "
   WrnA "not needed anymore. To make you not to wait for very long time, "
   WrnA "I set the downloading as first stage of the code."
   AskA "Please enter any key once you finish reading it"
   read -t 30 -n 1 -s -r -p "It will proceed in 30 seconds.."

   echo ""

}
#a--------------------------------- A18
function SetPath() {
  Logo
  MnvS "Setting Path for instllation..."
  local dpath=${PWD}
  SetT "We are currently at ${PWD}"
  AskA "Would you linke to install at ${PWD}"
  printf "Enter [y/n]"
  read ans
  case ${ans:=y} in 
    [yY]*)  
      MnvS "Answer is Yes"
      dpath=${PWD}
    ;; 
    [nN]*)  
        flag=1
        while [ ${flag} -eq 1 ]
        do
          read -p "Provide full path: "bg
          if [[ ${bg:0:1} == "/" ]] 
          then
            flag=0
            dpath=${bg}
          else 
            SetT "Provide and absolute path like ${HOME}/path/to/software"
          fi
        done
    ;;
    *) 
    exit 
    ;; 
  esac

  #echo "do the rest to INSTALL"
  #read -p " We are currently at 
  #${PWD}
  #would you like to install the software at 
  #${PWD} ? [Yn] :" choice
  #if [ ${choice} -eq 'n' || ${choice} -eq 'N' ]; then
  #  read -p "Provide the full path:" dpath
  #else
  #  dpath=${PWD}
  #fi
  SetT "User Home       :${MNVPATH}"
  SetT "Base            :${dpath}"
  MNVBASE=${dpath}
  MNVPATH=${dpath}/${MNVSOFT}
  SetT "Installation DIR:${MNVPATH}"
  MNVSRC="${MNVPATH}/source"
  MNVBUILD="${MNVPATH}/sw"
  SetEnvFile

  #SetT "Software installation prefix (nothing will be installed outside it):
  #${CTt}${ALICE_PREFIX}${COff}

  mkdir -p "${MNVPATH}/tmp"
  [[ "$SingleLogPerUser" == 1 ]] && \
      SWALLOW_LOG="${MNVPATH}/tmp/sj-mnv-${USER}" || \
      SWALLOW_LOG="${MNVPATH}/tmp/sj-mnv-${USER}-${$}"
  ERR="${SWALLOW_LOG}.err"
  OUT="${SWALLOW_LOG}.out"
  cd ${MNVBASE}
}
#a--------------------------------- A18
WaitAndEnjoy(){
    [[ -z $1 ]] && exit  # on empty param...

    percent=$1
    completed=$(( $percent / 1 ))
    remaining=$(( 50 - $completed ))

    echo -ne "\r $remaining ["
    printf "%0.s." `seq $completed`
    echo -n "o"
    [[ $remaining != 0 ]] && printf "%0.s." `seq $remaining`
    echo -n "]"
}

Decide() {
    for p in $(seq 50); do
        WaitAndEnjoy $p
        # sleep 2
        # sleep .1
        sleep 0.2
    done
    echo
}

function CheckhEnv() {
  SwallowProgress -f --pattern 'Checking Environment...' \
  env
}

function Main() {
  MnvS "Starting the Instllation Process....."
  local ForceCleanSlate=0
  local SingleLogPerUser=0
  local DO_ROOT=0
  local DO_CMAKE=0
  local DO_BOOST=0

  local DO_REROOT=0
  local DO_RECMAKE=0
  local DO_REBOOST=0

  local DO_MNV=0
  local DO_MNV_GPVM=0
  local DO_MNV_SPU=0
  local DO_MNV_ALL=0
  local PARAM

  #for (( i=0 ; i<=$# ; i++ )) ; do
  #  if [[ ${!i} == '--verbose' ]] ; then
  #    DebugSwallow=1
  #    DebugDetectOs=1
  #  fi
  #done
  SetPath
  CheckhEnv
  MnvS "Checking with CMAKE Installation"
  IsAvailable cmake
  result=$?
  if [ "$result" = "0" ];
  then
    FatY "cmake not found in system"
    SetT 'Installer will Install the cmake, it will take some time to ' 
    SetT 'install. If you the cmake is installed in the system, check' 
    SetT 'it is sourced properly or set the cmake variable and restart '
    SetT 'installation!!!'
    SetT 'At this stage you need to stop the installation' 
    AskA "Do you want to install CMAKE? (N to stop instllation)"
    printf 'Enter [y/n]'
    read check
    case ${check:=y} in 
      [yY]*) 
        DO_CMAKE=1 ;; 
      [nN]*) 
        exit ;;
        *) echo "Please answer yes or no.";;
    esac
  else 
    cmake_version=$(cmake --version | head -n 1 | cut -c15-)
    cmake_version_check=$(echo $cmake_version | cut -c1)
    cmake_required=$(echo $CMAKEVERSION_REQUIRED | cut -c1)
    #echo $cmake_version
    #echo $cmake_version_check
    #echo $cmake_required
    if [ ${cmake_version_check} -lt ${cmake_required} ]; 
    then
      FatY 'Found cmake version ${cmake_version} which is older than the'
      FatY 'required version ${CMAKEVERSION_REQUIRED} in PATH.'
      SetT 'Installer will Install newer Version as an external package'
      DO_CMAKE=1
    else 
      MnvS "Found cmake version ${cmake_version} which is newer than the"
      MnvS "required version ${CMAKEVERSION_REQUIRED} in PATH. This version"
      MnvS "is okay. Don't install cmake as external package."
      DO_ROOT=0
      #AskA "Do you want to upgrade CMAKE in anycase?"
      #printf 'Enter [y/n] '
      #read ans
      #case ${ans:=y} in 
      #  [yY]*)
      #    MnvS "Great! CMAKE will be upgraded"
      #    DO_ROOT=1 ;;
      #  [nN]*)
      #    DO_ROOT=0 ;;
      #  *) echo "Please answer yes or no.";;
      #esac
    fi  
  fi

  AskA "Do you want to install ROOT ?"
  printf 'enter [y/n] '
  read ans
  case ${ans:=y} in 
    [yY]*)  
      MnvS "You choose installer to install ROOT"
      DO_ROOT=1
    ;; 
    [nN]*)
      if [[ ${ROOTSYS} != "" ]]; then
        AskA "ROOT is set to ${ROOTSYS}"
        if (fileNotFound root $ROOTSYS/bin/root.exe);
        then 
          AskA "ROOT is installed at ${ROOTSYS} and all okay"
          DO_ROOT=0
        else 
          FatY "ROOTSYS is declared but exe not found"
          SetT "ROOT is set to install"
          DO_ROOT=1
        fi
      else
        FatY "ROOT is not installed"
        SetT 'Installer will Install the ROOT, it will take some time to install' 
        SetT 'If you the ROOT is installed in the system, check it is soursed' 
        SetT 'properly or set the ROOTSYS variable and restart installation!!!'
        SetT 'at this stage you need to stop the installation'
        printf 'Do you want cancel [y/n]:'
        read check
        case ${check:=y} in 
          [yY]*) 
            exit ;; 
          [nN]*) 
            DO_ROOT=1 ;;
           *) echo "Please answer yes or no.";;
        esac
      fi  
      ;;
    *) 
    FatY "ROOT is not properly Set"
    exit;;
  esac
 
  echo ""  
  SetT "Boost must be there in the system, automatic script is not able" 
  SetT "to search boost instllation in your system, thus answer following"
  SetT "question, so that it will install a fresh copy or you can set the"
  SetT "path by yourself"

  AskA "Do you want to install BOOST ?"
  printf 'enter [y/n] '
  read ans
  case ${ans:=y} in 
    [yY]*)  
      MnvS "You choose installer to install BOOST"
      DO_BOOST=1
    ;; 
    [nN]*)
      MnvS "Make sure that you have set your export the \${BOOSTDIR} in your env"
      ;;
    *) 
    exit;;
  esac

#  DO_MNV_SPU=0
#  echo ""  
#  SetT "We are now ready to set the SPUtils for your system, you" 
#  SetT "must choose the version to install"
#  MnvS "  (a) -> It will install only PlotUtils part, "
#  MnvS "  (b) -> It will install everything (NSF and AnaUtils)"
#  MnvS "  (c) -> GPVM Installation... Not Activated now"
#  MnvS "  (n) -> Don't install PlotUtils"
#  MnvS "         see the readme for more detail about function"
#  AskA "Which verion you would like to install?"
#  printf 'enter [a/b/c/n] '
#  read ans
#  case ${ans:=a} in 
#    [aA]*)  
#      MnvS "You chosed option (a); it will install only PlotUtils Part"
#      DO_MNV_SPU=1
#    ;; 
#    [bB]*)
#      MnvS "You chosed option (b); it will install Everything"
#      DO_MNV_ALL=1
#      ;;
#    [cC]*)
#      MnvS "You chosed option (c); It is meant for GPVM instllation"
#      MnvS "Manual install is possible though."
#      MnvS "----- **** under development **** -----"
#      FatY " Sytem will exit"
#      exit
#      ;;
#    [nN]*)
#      MnvS "It will nto install PlotUtils"
#      DO_MNV_ALL=0
#      DO_MNV_SPU=0
#      ;;
#    *) 
#    exit;;
#  esac
#
#  ShowWarning
 
  echo ""
  WrnA "-- Summary of your instllation---"
  if [ $DO_CMAKE == 1 ] 
  then
    SetT " You chosed to install CMAKE: Yes"
  fi
  if [ $DO_BOOST == 1 ]
  then
    SetT " You chosed to install BOOST: Yes"
  fi
  if [ $DO_ROOT == 1 ]
  then 
    SetT " You chosed to install ROOT: Yes"
  fi
  if [ $DO_MNV_ALL == 1 ]
  then
    SetT " You chosed to install PlotUtils ALL: Yes"
  fi
  if [ $DO_MNV_SPU == 1 ]
  then 
    SetT " You chosed to install PlotUtils Small: Yes"
  fi
  echo ""
  
  echo -e '\033[31m'"You can still stop instllation by pressing Cntl + c "'\033[m'.. 
  echo -e '\033[31m'"Else don't do anything, sit back"'\033[m'
  Decide
  CheckhEnv
  [[ $DO_MNV_SPU == 1 ]] && DownloadSPU
  [[ $DO_MNV_ALL == 1 ]] && DownloadDPU
  echo ""
  MnvS 'Installation begins: go get some tea/coffee or do some timepasss'
  echo ""
  DO_REBOOST=1
  [[ $DO_CMAKE == 1 ]] && InstallCmake ${DO_RECMAKE}
  [[ $DO_BOOST == 1 ]] && InstallBoostTag ${DO_REBOOST}
  [[ $DO_ROOT == 1 ]] && InstallRoot ${DO_REROOT}
  [[ $DO_MNV_GPVM == 1 ]] && InstallGPVM 
  [[ $DO_MNV_SPU == 1 ]] && InstallSPU 1
  [[ $DO_MNV_ALL == 1 ]] && InstallDPU 1

  
  finalWord
  
  unset MNVPATH
  unset MNVSOFT
  unset NCORE
  unset MNVSRC
  unset MNVBUILD
  unset SWALLOW_LOG
  unset ERR
  unset OUT
  unset OS
  unset CMAKEVERSION_REQUIRED
}


































































































































































































Main "$@"
