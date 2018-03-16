#!/bin/bash/
#convert all transitions to ts
#avconv -i /QUICKREVIEW/*.mp4 ./gameplay.ts
dirTransitions='./TRANSITIONS'
for f in $dirTransitions/*.mp4
  do 	
	filename=$(basename "$f");
	extension="${filename##*.}";
	filename="${filename%.*}.$extension";
	newFileName=${filename^^};
  avconv -i $f ./TRANSITIONS/TS/$newFileName.ts;
done;
