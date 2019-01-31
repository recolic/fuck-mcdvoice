#!/usr/bin/fish

set tmpFile (mktemp)
curl 'https://www.mcdvoice.com/' -vv -L > $tmpFile 2>&1
set cookie (grep 'Set-Cookie' -i $tmpFile | sed 's/^.*Set-Cookie: //g' | sed 's/path=\// /g' | sed 's/expires=.*;//g' | tr -d '\r\n')
set firstHop_postfix (grep 'action="Survey.aspx?c=' $tmpFile | sed 's/^.*Survey.aspx//g' | sed 's/".*$//g')
set firstHop "https://www.mcdvoice.com/Survey.aspx$firstHop_postfix"

echo "DEBUG: cookie=|$cookie|, firstHop |$firstHop|"
echo "DEBUG: tmpfile is $tmpFile"

set surveyCode $argv[1]
if [ "_$surveyCode" = "_" ]
    read -P 'Survey Code ? ' surveyCode
end

function surveyCodeToQueryStr
    set arr (string split '-' "$surveyCode")
    if [ (count $arr) != 6 ]
        echo 'Wrong Survey Code format!'
        return 1
    end
    echo "JavaScriptEnabled=1&FIP=True&CN1=$arr[1]&CN2=$arr[2]&CN3=$arr[3]&CN4=$arr[4]&CN5=$arr[5]&CN6=$arr[6]&NextButton=Start"
end

surveyCodeToQueryStr "$surveyCode"
####### First query
curl -vv "$firstHop" --cookie "$cookie" --data (surveyCodeToQueryStr "$surveyCode") > $tmpFile 2>&1
set cookieAspId (grep "Set-Cookie" -i $tmpFile | sed 's/^.*Set-Cookie: //g' | sed 's/path=\// /g' | tr -d '\r\n')
set cookie "$cookie ; $cookieAspId"
# try again with asp session id in cookie!
# I must follow its redirection and touch index.aspx once, then try once more
curl -vv "$firstHop" --cookie "$cookie" --data (surveyCodeToQueryStr "$surveyCode") -L > /dev/null 2>&1
curl -vv "$firstHop" --cookie "$cookie" --data (surveyCodeToQueryStr "$surveyCode") > $tmpFile 2>&1

set nextHop_postfix (grep 'action="Survey.aspx?c=' $tmpFile | sed 's/^.*Survey.aspx//g' | sed 's/".*$//g')
set -g nextHop "https://www.mcdvoice.com/Survey.aspx$nextHop_postfix"

echo "DEBUG: cookie = |$cookie|, nextHop |$nextHop|"

set TODO_DATA {"R004000=1&IoNF=5&PostedFNS=S000100%7CS000200%7CR004000","R001000=5&IoNF=6&PostedFNS=R001000","R000351=5&R028000=5&R007000=5&R011000=5&R008000=5&R006000=5&IoNF=14&PostedFNS=R000351%7CR028000%7CR007000%7CR011000%7CR008000%7CR006000","R005000=5&R009000=5&R015000=5&IoNF=18&PostedFNS=R005000%7CR009000%7CR015000","R000373=1&R000373Other=&IoNF=44&PostedFNS=R000365%7CR000228%7CR000368%7CR000364%7CR000369%7CR000367%7CR000371%7CR000363%7CR000361%7CR000362%7CR000366%7CR000373","R016000=2&IoNF=49&PostedFNS=R016000","R019000=5&R018000=5&IoNF=62&PostedFNS=R019000%7CR018000","S081000=&IoNF=65&PostedFNS=S081000","R000211=2&IoNF=69&PostedFNS=R000211","R000345=1&IoNF=71&PostedFNS=R000345","R000387=3&R000387Other=&IoNF=85&PostedFNS=R000387"}

for i in (seq (count $TODO_DATA))
    echo "DEBUG: Query $nextHop with data $TODO_DATA[$i]"
    curl -vv "$nextHop" --cookie "$cookie" --data "$TODO_DATA[$i]" > $tmpFile 2>&1
    # last query must return 302, others must return 200

    set nextHop_postfix (grep 'action="Survey.aspx?c=' $tmpFile | sed 's/^.*Survey.aspx//g' | sed 's/".*$//g')
    set -g nextHop "https://www.mcdvoice.com/Survey.aspx$nextHop_postfix"

    if grep '302 Found' $tmpFile > /dev/null
        #exit 0
    end
end

set finalHop_postfix (grep '"/Finish.aspx' $tmpFile | sed 's/^.*href="//g' | sed 's/".*$//g')
set finalHop "https://www.mcdvoice.com/Survey.aspx?$finalHop_postfix"
echo "$finalHop" | grep -v Finish > /dev/null; and echo 'Failed. The final optional sheet appears. (which is not implemented). Please try again.' ; and exit 2
echo "DEBUG: Query $finalHop"
set finalCookie (echo "$cookie" | sed 's/HttpOnly//g')
curl "$finalHop" --cookie "$finalCookie" -L > $tmpFile 2>&1

grep 'Validation Code' $tmpFile | sed 's/^.*ValCode">//g' | sed 's/<.*$//g'
rm $tmpFile



