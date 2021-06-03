#!/bin/bash
#=====
declare -i rows=6
declare -i cols=7
declare -i puissance=4
#=====

declare -i win=0 # if 1 >> one player won >> stops the game
declare -i winner=0 # The winner, player 1 or player 2
declare -i joueur=1 # First player to play = player 1
declare -A whole_tab # The board
declare -A position_carres # Position des carres

#=====================================
# FUNCTION draw_board()
# variables ::
# ---------
# $1 = column
# $2 = ligne
# $3 = player
# ---------
function draw_board(){

	columns=$(tput cols)
	lines=$(tput lines)

	#BUILD the size of a square/pawn
	largeur_carre=$((columns/25))
	if [ $((largeur_carre % 2)) -ne 0 ]
	then
		((largeur_carre=largeur_carre+1))
	fi
	((hauteur_carre=largeur_carre/2))
	#BUILD the size of a gaps between the squares/pawns
	((gap_largeur=largeur_carre/4))
	if [ $((gap_largeur / 2)) -eq 0 ]
	then
		gap_largeur=1
	fi

	if [ $((gap_largeur%2)) -eq 0 ]
	then
		((gap_hauteur=gap_largeur/2))
	else
		((gap_hauteur=(gap_largeur/2) + 1))
	fi

	#BUILD larger and height of the board
	largeur_board=$(((cols*largeur_carre) + ((cols*gap_largeur)+gap_largeur)))
	hauteur_board=$(((rows*hauteur_carre) + ((rows*gap_hauteur)+gap_hauteur)))

	#BUILD border/marge left and right, around the board
	border_left=$(((columns-largeur_board)/2))
	if [ $((columns % 2)) -eq 0 ]
	then
		border_right=$border_left
	else
		((border_right=border_left+1))
	fi

	# Start position board
	start_position_x=$border_left
	((start_position_x=start_position_x-1))

	demie_ligne=$((lines-hauteur_board))
	if [ $((demie_ligne % 2)) -ne 0 ]
	then
		((demie_ligne=demie_ligne+1))
	fi
	start_position_y=$((((demie_ligne)/2)+hauteur_board))
	((start_position_y=start_position_y-1))
	tput clear
	tput civis
	blue=$(tput setab 4)
	red=$(tput setab 1)
	yellow=$(tput setab 3)
	white_char=$(tput setaf 7)

        # ========== BUILD POSITION OF EACH SQUARE ==========

	((start_pos_y=start_position_y-2-gap_hauteur))
       	for((jj=0;jj<rows;jj++))
       	do
        	((start_pos_x=border_left-largeur_carre))
               	for((kk=0;kk<cols;kk++))
               	do
                	((start_pos_x=start_pos_x+gap_largeur+largeur_carre))
                       	position_carres[$jj,$kk]=$start_pos_y,$start_pos_x
			#echo ${position_carres[$jj,$kk]} y = $start_pos_y x = $start_pos_x
			#sleep 3
               	done
               	((start_pos_y=start_pos_y-hauteur_carre-gap_hauteur))
       	done

	start_position_y_bis=$start_position_y
	((start_position_y_bis=start_position_y_bis-1)) # Pour les numéros

#=================== BOARD ========================
#=================== BOARD ========================
		# Placement des numéros
		placement=$((((largeur_carre/2) -1) + 1 + border_left - largeur_carre))
		tput cup $start_position_y_bis $placement
		((placement=largeur_carre+gap_largeur-1))
		for((jj=0;jj<cols;jj++))
		do
			printf "%*s$((jj+1))" "$placement"
		done
		printf "%*s" "$border_right"

		# Premier bord du bas (commence par le bas)
		((start_position_y_bis=start_position_y_bis-1))

		for ((jj=0;jj<gap_hauteur;jj++))
		do
			tput cup $start_position_y_bis 0
			printf "%*s" "$border_left"
			echo -n $blue
			printf "%*s" "$largeur_board"
			tput sgr0
			tput civis
			printf "%*s" "$border_right"
			((start_position_y_bis=start_position_y_bis-1))
		done
# ============== Une ligne de carres ========================
		for ((jj=0;jj<rows;jj++))
		do
			for((kk=0;kk<hauteur_carre;kk++))
			do
				tput cup $start_position_y_bis 0
				printf "%*s" "$border_left"
				for((ll=0;ll<cols;ll++))
				do
					echo -n $blue
					printf "%*s" "$gap_largeur"
					tput sgr0
					tput civis
					printf "%*s" "$largeur_carre"
				done
				echo -n $blue
				printf "%*s" "$gap_largeur"
				tput sgr0
				((start_position_y_bis=start_position_y_bis-1))
				tput civis
			done
			printf "%*s" "$border_right"
			#============ LIGNE GAP =============
			for ((mm=0;mm<gap_hauteur;mm++))
			do
				tput cup $start_position_y_bis 0
				printf "%*s" "$border_left"
				echo -n $blue
				printf "%*s" "$largeur_board"
				tput sgr0
				printf "%*s" "$border_right"
				((start_position_y_bis=start_position_y_bis-1))
				tput civis
			done
			#============ LIGNE GAP =============
		done
# ============== Une ligne de carres ========================
#=================== BOARD ========================

	tput cup $lines 0
	tput cnorm
}

# ======= Will draw a square yellow or red ===========
#=====================================================

function draw_carre(){

        IFS=',' read -ra my_pos <<< ${position_carres[$1,$2]}
        x=$((${my_pos[1]}))
        y=$((${my_pos[0]}))
	if [ $3 -eq 1 ]
	then
		echo -n $red
	else
		echo -n $yellow
	fi
	for((qq=0;qq<hauteur_carre;qq++))
	do
		tput cup $y $x
		printf "%*s" "$largeur_carre"
		((y=y-1))
	done
	tput sgr0
	tput civis
}
#=====================================
# FUNCTION check_win()
# Check if the player just won or not
# variables ::
# ---------
# $1 = column
# $2 = ligne
# $3 = player
# ---------
function check_win(){
	local -i count=0 # will count if we reach the 4 (variable $puissance)
	local -i reset_count=0 # =1 Means that we found an adversary pawn, so we stop counting
	local -i colonne=$1
	local -i ligne=$2
	#--------------------
	# CHECK VERTICAL => |
	#--------------------
	# Check on the same column, from last row played, then decrase row and count++ if match
	# reset_count = means that we found an adversary pawn, so we stop counting
	for((jj=$2;jj>=0;jj--))
	do
		if [ $((whole_tab[$1,$jj])) -eq $(($3)) ] && [ $reset_count -eq 0 ]
		then
			((count=count+1))
			if [ $count -eq $puissance ]
			then
				win=1
				winner=$3
				return $win
			fi
		else
			reset_count=1
		fi
	done
	#------------------------
	# CHECK HORIZONTAL ==> --
	#------------------------
	# Check on the same row, from the last column played, then increase column and count++ if match
	# To the right, then to the left
	# reset_count = means that we found an adversary pawn, so we stop counting
	###### To the right -->
	count=0
	reset_count=0
	for((jj=$1;jj<$cols;jj++))
	do
		if [ $((whole_tab[$jj,$2])) -eq $(($3)) ] && [ $reset_count -eq 0 ]
		then
			((count=count+1))
			if [ $count -eq $puissance ]
			then
				win=1
				winner=$3
				return $win
			fi
		else
			reset_count=1
		fi
	done
	###### To the left <--
	reset_count=0
	for((jj=$((colonne-1));jj>=0;jj--))
	do
		if [ $((whole_tab[$jj,$2])) -eq $(($3)) ] && [ $reset_count -eq 0 ]
		then
			((count=count+1))
			if [ $count -eq $puissance ]
			then
				win=1
				winner=$3
				return $win
			fi
		else
			reset_count=1
		fi
	done
	#---------------------------------
	# CHECK BLACK SLASH DIAGONAL ==> \
	#---------------------------------
	# reset_count = means that we found an adversary pawn, so we stop counting
	###### To the right -->
	count=0
	reset_count=0
	for((jj=$1,zz=$2;jj<$cols,zz>=0;jj++,zz--))
	do
		if [ $((whole_tab[$jj,$zz])) -eq $(($3)) ] && [ $reset_count -eq 0 ]
		then
			count=$((count+1))
			if [ $count -eq $puissance ]
			then
				win=1
				winner=$3
				return $win
			fi
		else
			reset_count=1
		fi
	done
	###### To the left <--
	reset_count=0
	for((jj=$((colonne-1)),zz=$((ligne+1));jj>=0,zz<$rows;jj--,zz++))
	do
		if [ $((whole_tab[$jj,$zz])) -eq $(($3)) ] && [ $reset_count -eq 0 ]
		then
			((count=count+1))
			if [ $count -eq $puissance ]
			then
				win=1
				winner=$3
				return $win
			fi
		else
			reset_count=1
		fi
	done
	#---------------------------
	# CHECK SLASH DIAGONAL ==> /
	#---------------------------
	# reset_count = means that we found an adversary pawn, so we stop counting
	###### To the right -->
	count=0
	reset_count=0
	for((jj=$1,zz=$2;jj<$cols,zz<$rows;jj++,zz++))
	do
		if [ $((whole_tab[$jj,$zz])) -eq $(($3)) ] && [ $reset_count -eq 0 ]
		then
			((count=count+1))
			if [ $count -eq $puissance ]
			then
				win=1
				winner=$3
				return $win
			fi
		else
			reset_count=1
		fi
	done
	###### To the left <--
	reset_count=0
	for((jj=$((colonne-1)),zz=$((ligne-1));jj>=0,zz>=0;jj--,zz--))
	do
		if [ $((whole_tab[$jj,$zz])) -eq $(($3)) ] && [ $reset_count -eq 0 ]
		then
			((count=count+1))
			if [ $count -eq $puissance ]
			then
				win=1
				winner=$3
				return $win
			fi
		else
			reset_count=1
		fi
	done
}
#=====================================

#==============================
#INITIALISATION (all cases @ 0)
#==============================
for((ii=0;ii<cols;ii++))
do
	for((jj=0;jj<rows;jj++))
	do
		whole_tab+=([$ii,$jj]=0)
	done
done

function start_game(){
#==============================
######################
#  START GAME (win==0)
######################
while [ $((win)) == 0 ]
do
	get_out=0
	#echo player $joueur to play :
	read -sN1 touche
	# below, I had to this, because I found a "bug" in bash, or a miss-use from my side
	if [ ${#touche} -lt 2 ]
	then
		((touche=touche-1))
	else
		touche=-1
	fi

	# Check if we selected an existing column
	if [ $touche -ge 0 ] && [ $touche -lt $cols ]
	then
		for((ii=0;ii<rows;ii++))
		do
			if [ $((whole_tab[$touche,$ii])) -eq 0 ] && [ $((get_out)) -eq 0 ]
			then
				whole_tab+=([$touche,$ii]=$joueur) # OK it found the first available empty case in the column
				draw_carre $ii $touche $joueur
				check_win $touche $ii $joueur #### >> CALL function to check if it is a win
				if [ $joueur -eq 1 ] # Change player number
				then
					joueur=2
				else
					joueur=1
				fi
				get_out=1 # Get out, of the FOR the loop, because we placed the pawn
			fi
		done
	#else
	#	echo pas bonne touche
	fi
done
######################
#    END GAME (win==1)
######################
}

#trap draw_board WINCH

draw_board
start_game

echo BRAVOOOOOO player $winner
