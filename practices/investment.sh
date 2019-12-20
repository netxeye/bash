#! /usr/bin/env bash
URL='https://www.etf.com/'
KEYWORDS_RATING=('MSCI ESG Rating' 'MSCI ESG Quality Score' 'Global Percentile Rank')
KEYWORDS_DATA=('Expense Ratio' 'Price / Earnings Ratio' 'Distribution Yield' 'Net Asset Value')
declare -A ETFs
ETFs=( ['Consumer']='XLP VDC' ['Utilities']='XLU VPU FXU' ['HealthCare']='VHT XLV'
['China']='MCHI ASHR FXI KWEB' ['SP500']='SPHD IVV SPY' )
PATHs='/home/tao.lu/git/ETFs'
GIT_PATH=${PATHs}

function fetch_data () {
        echo "## ${2}" | tee -a ${1}/${2}.md | tee -a ${PATHs}/ETFs.md
        echo '----' | tee -a ${1}/${2}.md | tee -a ${PATHs}/ETFs.md
				DATA=`curl -sL ${URL}/${2}#overview`
}

function create_Rating () {
        echo "### RATING" | tee -a ${1}/${2}.md | tee -a ${PATHs}/ETFs.md
        echo "" | tee -a ${1}/${2}.md | tee -a ${PATHs}/ETFs.md
				echo  "|Rating|Result|" | tee -a ${1}/${2}.md | tee -a ${PATHs}/ETFs.md
				echo  "|:----:|:---:|" | tee -a ${1}/${2}.md | tee -a ${PATHs}/ETFs.md
				for ((i = 0; i < ${#KEYWORDS_RATING[@]}; i++))
				do
								case ${KEYWORDS_RATING[${i}]} in
												'MSCI ESG Rating' )
																value=`grep -A3 "${KEYWORDS_RATING[${i}]}" <<< ${DATA} | egrep \
																       -o 'MSCI_ESG_[A-Z]*' | cut -d '_' -f 3`
																;;
												* )
															  value=`grep -A3 "${KEYWORDS_RATING[${i}]}" <<< ${DATA} | egrep \
																			 -o '[0-9]+\.[0-9]+(\s*/\s*[0-9]+)?'`
																;;
								esac
								echo  "|${KEYWORDS_RATING[${i}]}|$value|" | tee -a ${1}/${2}.md | tee \
								        -a ${PATHs}/ETFs.md
				done
        echo "" | tee -a ${1}/${2}.md | tee -a ${PATHs}/ETFs.md
}

function create_Data () {
        echo "### DATA" | tee -a ${1}/${2}.md | tee -a ${PATHs}/ETFs.md
        echo "" | tee -a ${1}/${2}.md | tee -a ${PATHs}/ETFs.md
				echo  "|Data|Result|" | tee -a ${1}/${2}.md | tee -a ${PATHs}/ETFs.md
				echo  "|:----:|:---:|" | tee -a ${1}/${2}.md | tee -a ${PATHs}/ETFs.md
				for ((i = 0; i < ${#KEYWORDS_DATA[@]}; i++))
				do
								value=`grep -A3 "${KEYWORDS_DATA[${i}]}"<<<${DATA} | egrep -o \
												'\\$?[0-9]+\.[0-9]+%?' | uniq`
								echo "|${KEYWORDS_DATA[${i}]}|${value}|" | tee -a ${1}/${2}.md | tee \
												-a ${PATHs}/ETFs.md
				done
        echo "" | tee -a ${1}/${2}.md | tee -a ${PATHs}/ETFs.md
}

function git_Update () {
				git --git-dir=${1} add .
				git --git-dir=${1} commit -a -m `data +%F update`
				git --git-dir=${1} push
}

function clean_Up () {
				rm -rf ${1}/*
}


echo "Mike's Investment" | tee -a ${PATHs}/ETFs.md
echo "----" | tee -a ${PATHs}/ETFs.md
echo "" | tee -a ${PATHs}/ETFs.md
echo "***" | tee -a ${PATHs}/ETFs.md
echo "## Contents" | tee -a ${PATHs}/ETFs.md

for type_etf in "${!ETFs[@]}"
do
				echo "* [${type_etf}](#${type_etf})" | tee -a ${PATHs}/ETFs.md
done

for type_etf in "${!ETFs[@]}"
do
				if [ ! -d ${PATHs}/${type_etf} ]; then
								mkdir -p ${PATHs}/${type_etf}
				fi
				echo "# ${type_etf}" | tee -a ${PATHs}/ETFs.md
				echo "----" | tee -a ${PATHs}/ETFs.md
				echo "" | tee -a ${PATHs}/ETFs.md
				for ETF in ${ETFs[${type_etf}]}
				do
                fetch_data ${PATHs}/${type_etf} $ETF
                create_Rating ${PATHs}/${type_etf} $ETF
                create_Data ${PATHs}/${type_etf} $ETF
				done
				echo "" | tee -a ${PATHs}/ETFs.md
done

git_Update ${GIT_PATH}
clean_Up ${PATHs}
