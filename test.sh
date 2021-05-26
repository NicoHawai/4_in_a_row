i=0
j=0
z=0
k=0
a=0

while true
do
	i=$((i+2))
	j=$((j+3))
	z=$((z+4))
	k=$((k+5))
	a=$((a+6))
	read touche
	echo touche = $touche
	echo touche devient INT : $((touche))
	echo i=$i j=$j z=$z k=$k a=$a
	echo ========================
done
