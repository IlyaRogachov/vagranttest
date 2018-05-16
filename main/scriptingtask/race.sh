#erated code below aims at helping you parse
# the standard input according to the problem statement.

read N
if [[ -n ${N//[0-9]/} ]]; then
	    echo "Not integer number"
	    exit 1
fi
ARRpi=()
for (( i=0; i<N; i++ )); do
    read Pi
    if [[ -n ${Pi//[0-9]/} ]]; then
       echo "Not integer number"
       exit 1
    fi
    ARRpi[i]=$Pi
done

sortedARRpi=( $( printf "%s\n" "${ARRpi[@]}" | sort -n ) )

minum=100000000
for ((i=N-1; i>0; i--)); do
	whoisbetter=$(( ${sortedARRpi[$i]} - ${sortedARRpi[$i-1]} ))
	if [[ $whoisbetter -lt $minum ]]; then
            minum=$whoisbetter
        fi
done

echo $minum

# Write an action using echo
# To debug: echo "Debug messages..." >&2

#echo "answer"
