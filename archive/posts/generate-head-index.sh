#!/bin/bash

lmeta=( $(ls *.json | sort -rg) )
lpost=( $(ls *.md | sort -rg) )
older=( $(ls *.json | sort) )
older+=( $(ls *.md | sort) )

rm -f ../index.jade 2> /dev/null
rm -f head.jade 2> /dev/null

incr=0
declare -a posts
for post in "${lpost[@]}"
do
	meta="${lmeta[$incr]}"

	card_type=`jq -r '.card_type' $meta`
	card_size=`jq -r '.card_size' $meta`
	subtext=`jq -r ".subtext" $meta`

	pref_size=4
	if [[ "$card_type" == "picture" ]] ; then
		if [[ "$card_size" == "large" ]] ; then
			pref_size=12
		elif [[ "$card_size" == "medium-large" ]] ; then
			pref_size=8
		elif [[ "$card_size" == "medium" ]] ; then
			pref_size=7
		elif [[ "$card_size" == "medium-small" ]] ; then
			pref_size=5
		else
			pref_size=4
		fi
	else
		if [[ ${#subtext} -gt 125 ]] ; then
			pref_size=12
		elif [[ ${#subtext} -gt 100 ]] ; then
			pref_size=8
		elif [[ ${#subtext} -gt 50 ]] ; then
			pref_size=7
		elif [[ ${#subtext} -gt 25 ]] ; then
			pref_size=5
		else
			pref_size=4
		fi
	fi

	posts[$incr]=$pref_size
	let "incr++"
done

declare -a lock
new_row=true
incr=0
for post in "${posts[@]}"
do
	let "incr++"
	if [ $incr -le 3 ] ; then
		if $new_row ; then
			lock[$incr]=$post
			new_row=false
		else
			if (( $post + ${lock[$incr - 1]} <= 14 )) ; then
				lock[$incr]=$((12-${lock[$incr - 1]}))
				new_row=true
			else
				lock[$incr - 1]=12
				lock[$incr]=$post
				new_row=false
			fi
		fi
	else
		if $new_row ; then
			if [[ $post -le 5 && ${posts[$incr - 1]} -eq 4 && ${lock[$incr - 2]} -eq 4 ]] ; then
				lock[$incr - 2]=4
				lock[$incr - 1]=4
				lock[$incr]=4
				new_row=true
			else
				lock[$incr]=$post
				new_row=false
			fi
		else
			if (( $post + ${lock[$incr - 1]} <= 14 )) ; then
				lock[$incr]=$((12-${lock[$incr - 1]}))
				new_row=true
			else
				lock[$incr - 1]=12
				lock[$incr]=$post
				if [ ${lock[$incr]} -eq ${lock[$incr - 2]} ] ; then
					if [[ $(($incr % 2)) -eq 1 && ${lock[$incr]} -ne 4 ]] ; then
						let "lock[$incr]=${lock[$incr]} - 1"
					else
						let "lock[$incr]=${lock[$incr]} + 1"
					fi
				fi
				new_row=false
			fi
		fi
	fi
done

if [[ "$new_row" == "false" ]] ; then
	lock[$incr]=12
fi

i=0
for post in "${lpost[@]}"
do
	meta="${lmeta[i]}"

	id=`jq -r ".id" $meta`
	titletext=`jq -r ".titletext" $meta`
	subtext=`jq -r ".subtext" $meta`
	month=`jq -r '.timestamp.month' $meta`
	day=`jq -r '.timestamp.day' $meta`
	year=`jq -r '.timestamp.year' $meta`
	readbl=`echo $month $day, $year`
	card_size=`jq -r '.card_size' $meta`
	card_type=`jq -r '.card_type' $meta`
	image=`jq -r '.image' $meta`
	comments=`jq -r '.comments' $meta`
	related=`jq -r '.related' $meta`
	explicit=`jq -r '.explicit' $meta`

	let "i++"

	# printouts
	echo ".mdl-card.mdl-cell.mdl-cell--8-col.mdl-cell--${lock[$i]}-col-desktop
  .mdl-card__title.mdl-color-text--grey-50(style=\"background-image: url('../images/bgs/$image');\")
    h3
      a(href='posts/$id') $titletext" >> head.jade
        if [ "$explicit" == "true" ] ; then
		echo "      img.explicit-label.explicit-label-home(src=\"/images/stock/explicit/explicit-label.png\",alt=\"EXPLICIT CONTENT\")" >> head.jade
	fi
	if [[ "$card_type" == "picture" ]] ; then
		:
	else
		echo "  .mdl-card__supporting-text.mdl-color-text--grey-700 $subtext" >> head.jade
  	fi
	echo "  .mdl-card__supporting-text.meta.mdl-color-text--grey-700" >> head.jade
	echo "    .minilogo
    div
      strong TheHonestAtheist
      span $readbl" >> head.jade
done

mv head.jade ../index.jade
