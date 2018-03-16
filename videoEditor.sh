#!/bin/bash
#dependancy
#sudo apt-get install gpac
#usage: bash videoEditor {NAME OF SHOW}
bumpers="./BUMPERS/QUICKREVIEW";
gameplayFolder="./GAMEPLAY";
finalFolder="./FINAL";
quickReviewFolder="/QUICKREVIEW";
archiveFolder="/PROCESSED_VIDEOS";
finishedFolder="/FINISHED VIDEOS/QUICKREVIEW";
#replace spaces with underlines
#find /edit/ -name "* *" | rename 's/ /_/g'
find $quickReviewFolder -name "* *" | rename 's/ /_/g';
#if bumpers are not ts yet
#avconv -i $introBumper ./intro.ts;
#avconv -i $outroBumper ./outro.ts;

for f in $quickReviewFolder/*.mp4
do
	#prepare file names
	filename=$(basename "$f" .mp4);
	newFileName=${filename^^};
	thumbName=$(echo "$newFileName" | sed 's/_/ /g');
	
	#MAKE GAME FINAL FOLDER
	mkdir -p $finalFolder/$newFileName;
	
	#get duration of video
	duration="$(ffmpeg -i  $quickReviewFolder/$filename.mp4 2>&1 | grep Duration | awk '{print $2}' | tr -d ,)";
	
	#convert gamplay file to ts file (mp4 does not merge)
	avconv -i $quickReviewFolder/$filename.mp4 $gameplayFolder/$newFileName.ts;
	
	#get random transition
	randomTransition="$(ls -1 ./TRANSITIONS/TS/| sort -R|head -1)";
	transition="./TRANSITIONS/TS/$randomTransition";	
	
	#MERGE IT INTO FINAL FORM.
	cat $bumpers/intro.ts $transition $gameplayFolder/$newFileName.ts $bumpers/outro.ts > $finalFolder/$newFileName/$newFileName.ts;
	
	##GET THUMB FROM VIDEO
	ffmpeg -ss 3 -i $quickReviewFolder/$filename.mp4 -vf "select=gt(scene\,0.4)" -frames:v 5 $finalFolder/$newFileName/rawthumb.png

	#create youtube thumbnail
	
	#should create a batch of "finished" thumbs and you can choose the best ytthumb manually
	convert $finalFolder/$newFileName/rawthumb.png -resize %222 $finalFolder/$newFileName/thumb_bg.jpeg;
	
	convert $finalFolder/$newFileName/thumb_bg.jpeg -gravity Center -crop 1280x720+0+0 +repage $finalFolder/$newFileName/thumb_bg.jpeg;	
	
	convert $finalFolder/$newFileName/thumb_bg.jpeg ./TEMPLATES/overlay1280.png -gravity center -composite $finalFolder/$newFileName/ytThumbFinal.jpeg;
	
	width=`identify -format %w $finalFolder/$newFileName/ytThumbFinal.jpeg`;
	convert -background '#0008' -fill white -gravity center -size ${width}x300 caption:$newFileName $finalFolder/$newFileName/ytThumbFinal.jpeg +swap -gravity north -composite  $finalFolder/$newFileName/ytThumbFinal.jpeg
	
done

#clean up! move file so it does not get processed again
#Move proccess batch into finished folder
mv -f $finalFolder/* $finishedFolder
#delete working folders
rm -rf $gameplayFolder/*;

