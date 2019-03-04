#!/usr/bin/fish

# php must check the format of $code to avoid shell-injection.
set code $argv[1]

while true
    set res (./fuck_mcd.fish "$code" | grep 'MSG-')
    if [ "$res" != '' ]
        echo "$res"
        break
    end
    echo 'Retrying...'
end


