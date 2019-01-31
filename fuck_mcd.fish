

set tmpFile (mktemp)
curl 'https://www.mcdvoice.com/' -vv -L > $tmpFile 2>&1
set cookie (grep 'Set-Cookie' -i $tmpFile | sed 's/^.*Set-Cookie: //g' | sed 's/path=\// /g' | tr -d '\r\n')
set firstHop_postfix (grep 'action="Survey.aspx?c=' $tmpFile | sed 's/^.*Survey.aspx//g' | sed 's/".*$//g')
set firstHop "https://www.mcdvoice.com/Survey.aspx$firstHop_postfix"

echo "DEBUG: cookie=|$cookie|, first |$firstHop|"

read -P 'Survey Code ? ' surveyCode

function surveyCodeToQueryStr
    set arr (string split '-' "$surveyCode")
    if [ (count $arr) != 6 ]
        echo 'Wrong Survey Code format!'
        return 1
    end
    echo "JavaScriptEnabled=1&FIP=True&CN1=$arr[1]&CN2=$arr[2]&CN3=$arr[3]&CN4=$arr[4]&CN5=$arr[5]&CN6=$arr[6]&NextButton=Start"
end

####### First query
curl -vv "$firstHop" -H "Cookie: $cookie" --data (surveyCodeToQueryStr "$surveyCode") -L > $tmpFile 2>&1

set cookieAspId (grep "Set-Cookie" -i $tmpFile | sed 's/^.*Set-Cookie: //g' | sed 's/path=\// /g' | tr -d '\r\n')
set cookie "$cookie ; $cookieAspId"
set nextHop_postfix (grep 'action="Survey.aspx?c=' $tmpFile | sed 's/^.*Survey.aspx//g' | sed 's/".*$//g')
set nextHop "https://www.mcdvoice.com/Survey.aspx$nextHop_postfix"

echo "DEBUG: new cookie = |$cookie|, next |$nextHop|"

