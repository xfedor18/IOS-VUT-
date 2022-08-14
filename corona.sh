#!/bin/bash

fhelp() {
    echo "infected — spočítá počet nakažených."
    echo "merge — sloučí několik souborů se záznamy do jednoho, zachovávající původní pořadí (hlavička bude ve výstupu jen jednou)."
    echo "gender — vypíše počet nakažených pro jednotlivá pohlaví."
    echo "age — vypíše statistiku počtu nakažených osob dle věku (bližší popis je níže)."
    echo "daily — vypíše statistiku nakažených osob pro jednotlivé dny."      
    echo "monthly — vypíše statistiku nakažených osob pro jednotlivé měsíce."
    echo "yearly — vypíše statistiku nakažených osob pro jednotlivé roky."
    echo "countries — vypíše statistiku nakažených osob pro jednotlivé země nákazy (bez ČR, tj. kódu CZ)."
    echo "districts — vypíše statistiku nakažených osob pro jednotlivé okresy."
    echo "regions — vypíše statistiku nakažených osob pro jednotlivé kraje."
    echo "-a DATETIME — after: jsou uvažovány pouze záznamy PO tomto datu (včetně tohoto data). DATETIME je formátu YYYY-MM-DD."
    echo "-b DATETIME — before: jsou uvažovány pouze záznamy PŘED tímto datem (včetně tohoto data)."
    echo "-g GENDER — jsou uvažovány pouze záznamy nakažených osob daného pohlaví. GENDER může být M (muži) nebo Z (ženy)."
    echo "-s [WIDTH] u příkazů gender, age, daily, monthly, yearly, countries, districts a regions vypisuje data ne číselně, ale graficky v podobě histogramů. Nepovinný parametr WIDTH nastavuje šířku histogramů, tedy délku nejdelšího řádku, na WIDTH. Tedy, WIDTH musí být kladné celé číslo. Pokud není parametr WIDTH uveden, řídí se šířky řádků požadavky uvedenými níže."
}

while [ -n "$1" ]; do #a cycle that will go through all the parameters
    filename=$2 #read a file
    filename2=$3 #read a file
    case $1 in
        -h)
            fhelp;;
        -a)
            echo 'There is no data';;
        -b)
            echo 'There is no data';;
        -g) #outputs only the specified gender
            filename=$3
            shift
            case $1 in
                M)
                    awk -F, '$4 == "M"' "$filename";;
                Z)
                    awk -F, '$4 == "Z"' "$filename";; 
            esac
        ;;
        infected) #counts the number of all infected
        awk -F, '{if ($4 == "Z" || $4 == "M" ){count++}} END{print count}' "$filename";;
        merge)
            cat $filename2 >> $filename
            cat "$filename"
            ;;
        gender) #counts the number of infected by specific gender
            awk -F, '{
                if ($4 == "M"){
                    countM++
                }
                if ($4 == "Z"){
                countZ++
                }
                }END{
                print "M: " countM
                print "Z: " countZ
            }' "$filename";; 
        age) #calculates the number of infected by age
            awk -F, '{
                if  (($3 >= "0") && ($3 <= "5")){
                    count1++
                }if (($3 >= "6") && ($3 <= "15")){
                    count2++
                }if (($3 >= "16") && ($3 <= "25")){
                    count3++
                }if (($3 >= "26") && ($3 <= "35")){
                    count4++
                }if (($3 >= "36") && ($3 <= "45")){
                    count5++
                }if (($3 >= "46") && ($3 <= "55")){
                    count6++
                }if (($3 >= "56") && ($3 <= "65")){
                    count7++
                }if (($3 >= "66") && ($3 <= "75")){
                    count8++
                }if (($3 >= "76") && ($3 <= "85")){
                    count9++
                }if (($3 >= "86") && ($3 <= "95")){
                    count10++
                }if (($3 >= "96") && ($3 <= "105")){
                    count11++
                }if (($3 >= "105") && ($3 <= "1000")){
                    count12++
                }
                           
                }END{
                print "0-5   : " count1
                print "6-15  : " count2 
                print "16-25 : " count3
                print "26-35 : " count4
                print "36-45 : " count5
                print "46-55 : " count6
                print "56-65 : " count7
                print "66-75 : " count8
                print "76-85 : " count9
                print "86-95 : " count10
                print "96-105: " count11
                print ">105  : " count12
            }' "$filename";; 
        daily) #calculates the number of infected by day
            day=$( awk  -F, \
                '{
                    if($2 != "datum" ){
                        count[$2]++     
                    }
        
                }END{
                    for (item in count){
                    printf("%s: %d\n",item,count[item])
                }
            }' $filename) 
            echo "$day"   ;;
        monthly) # calculates the number of infected by month
            month=$( awk  -F, \
                '{
                    if($2 != "datum" ){
                        count[substr($2,1,7)]++     
                    }
        
                }END{
                    for (item in count){
                    printf("%s: %d\n",item,count[item])
                }
            }' $filename) 
            echo "$month";;
        yearly) #calculates the number of infected by year
            awk -F, '{
                if(($2 >= "2020-01-01") && ($2 <= "2020-12-31")){
                    count1++
                }
                if(($2 >= "2021-01-01") && ($2 <= "2021-12-31")){
                    count2++
                }
                if(($2 >= "2022-01-01") && ($2 <= "2022-12-31")){
                    count3++
                }
            } END{
                print "2020: " count1
                print "2021: " count2
                print "2022: " count3
            }' "$filename"
        ;;
        countries) #calculates the number of infected by countries
            c=$( awk  -F, \
                '{
                    if($8 != "nakaza_zeme_csu_kod" ){
                        count[$8]++     
                    }
        
                }END{
                    for (item in count){
                    printf("%s: %d\n",item,count[item])
                }
            }' $filename) 
            echo "$c"   ;;
        districts) #calculates the number of infected by districts
            b=$( awk  -F, \
                '{
                    if($6 != "okres_lau_kod" ){
                        count[$6]++     
                    }
        
                }END{
                    for (item in count){
                    printf("%s: %d\n",item,count[item])
                }
            }' $filename) 
            echo "$b"   ;;
            regions) #calculates the number of infected by regions
                a=$( awk  -F, \
                    '{
                        if($5 != "kraj_nuts_kod" ){
                            count[$5]++     
                        }
                    }END{
                        for (item in count){
                        printf("%s: %d\n",item,count[item])}
                    }' $filename) 
                echo "$a"   ;;
        -s)
            echo 'There is no data'
        ;;       

    esac

    shift

done
exit
