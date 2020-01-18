#! /usr/bin/env bash
URL='https://www.etf.com/'
KEYWORDS_RATING=('MSCI ESG Rating' 'MSCI ESG Quality Score' 'Global Percentile Rank')
KEYWORDS_DATA=('Expense Ratio' 'Price / Earnings Ratio' 'Distribution Yield' 'Net Asset Value')
declare -A ETFs
ETFs=( ['Consumer']='XLP VDC' ['Utilities']='XLU VPU FXU' ['HealthCare']='VHT XLV'
['China']='MCHI ASHR FXI KWEB AIA FLXC' ['SP500']='SPHD IVV SPY' ['Bond']='IEF TLT'
['Gold']='GLD IAU DGL' )
PATHs='/home/tao.lu/git/ETFs'
GIT_PATH=${PATHs}
INVEST=2657
TOTAL=0
declare -A INVEST_PERCETAGE
#INVEST_PERCETAGE=(['XLP']=0.15 ['XLU']=0.2 ['MCHI']=0.06 ['ASHR']=0.04 ['XLV']=0.25
#['SPHD']=0.02 ['IVV']=0.13 ['IEF']=0.07 ['TLT']=0.15 ['IAU']=0.05)
INVEST_PERCETAGE=(['XLP']=0.15 ['XLU']=0.2 ['AIA']=0.1 ['XLV']=0.25
['SPHD']=0.02 ['IVV']=0.13 ['IEF']=0.07 ['TLT']=0.15 ['IAU']=0.05)

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
				git --git-dir=${1}/.git --work-tree=${1} add ${1}/
				git --git-dir=${1}/.git --work-tree=${1} commit -a -m "`date +%F` update"
				git --git-dir=${1}/.git --work-tree=${1} push
}

function clean_Up () {
				rm -rf ${1}/*
}

function calculate_Price () {
				if [ -n "${INVEST_PERCETAGE[${2}]}" ]
				then
                echo "### COST" | tee -a ${1}/${2}.md | tee -a ${PATHs}/ETFs.md
                echo "" | tee -a ${1}/${2}.md | tee -a ${PATHs}/ETFs.md
				        echo  "|Data|Result|" | tee -a ${1}/${2}.md | tee -a ${PATHs}/ETFs.md
				        echo  "|:----:|:---:|" | tee -a ${1}/${2}.md | tee -a ${PATHs}/ETFs.md
				        price=$(awk -F '|' '/Net Asset Value/{print $3}' ${1}/${2}.md | tr -d '$')
								stocks=$(echo ${INVEST}*${INVEST_PERCETAGE[${2}]}/${price} | bc)
								amount=$(echo ${stocks}*${price} | bc)
								printf '|Amount|%d|\n' ${stocks} | tee -a ${1}/${2}.md | tee \
												-a ${PATHs}/ETFs.md
								printf '|Cost|$%.2f|\n' ${amount} | tee -a ${1}/${2}.md | tee \
												-a ${PATHs}/ETFs.md
								TOTAL=$(echo ${TOTAL}+${amount} | bc)
				fi
}

function calulate_Percentage () {
      echo "## Percentage" | tee -a ${PATHs}/ETFs.md
      echo "" | tee -a ${PATHs}/ETFs.md
      echo  "|ETF|Percentage|Total Cost|" | tee -a ${PATHs}/ETFs.md
      echo  "|:---:|:---:|:---:|" | tee -a ${PATHs}/ETFs.md
      for etf in "${!ETFs[@]}"
			do
							total=0
							for cost in `awk -F '|' '/Cost/{print $3}'  ${PATHs}/${etf}/*.md | tr -d '$'`
							do
											total=$(echo "scale=2;${total}+${cost}" | bc)
							done
							percentage=$(echo "scale=2;${total}/${TOTAL}*100" | bc)
			        printf '|%s|%.2f%%|$%.2f|\n' ${etf} ${percentage} ${total}|  tee -a ${PATHs}/ETFs.md
			done
}

clean_Up ${PATHs}
echo "Mike's Investment" | tee -a ${PATHs}/ETFs.md
echo "----" | tee -a ${PATHs}/ETFs.md
echo "" | tee -a ${PATHs}/ETFs.md
echo "***" | tee -a ${PATHs}/ETFs.md
echo "## Contents" | tee -a ${PATHs}/ETFs.md

for type_etf in "${!ETFs[@]}"
do
				echo "* [${type_etf}](#${type_etf})" | tee -a ${PATHs}/ETFs.md
done
echo "* [Sumary](#Sumary)" | tee -a ${PATHs}/ETFs.md
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
                calculate_Price ${PATHs}/${type_etf} ${ETF}
				done
				echo "" | tee -a ${PATHs}/ETFs.md
done
echo "## Sumary" | tee -a ${PATHs}/ETFs.md
echo "" | tee -a ${PATHs}/ETFs.md
echo  "|Name|Value|" | tee -a ${PATHs}/ETFs.md
echo  "|:----:|:---:|" | tee -a ${PATHs}/ETFs.md
printf '|Total|$%.2f|\n' ${TOTAL}| tee -a ${PATHs}/ETFs.md
printf '|Diff|$%.2f|\n' $(echo ${INVEST}-${TOTAL} | bc)| tee -a ${PATHs}/ETFs.md
calulate_Percentage
git_Update ${GIT_PATH}
