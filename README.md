README

this is all entirely experimental. and just for fun.


download your JSON: 
https://stags.bluekai.com/registry?js=1&fg=58595b&fpfg=7d7d7d&font=arial&size=11&fpfont=arial&fpsize=9&lo=1&jsonp=jQuery17205050282760755163_1506201903189&_=1506201903600


Run `to_csv.rb path_to_my.json` to download all the images. It won't produce the output yet, since you  haven't OCRed the images yet.

Then I OCR'ed all of the pngs to txt. `ocropus-rpred -n -m oracle-data-ocr-model-00160000.pyrnn.gz ../oracle_data_cloud/imgs/*.png` You should first download and get working Ocropus. (And you may want to either move the model's pyrnn.gz file to the ocropus directory or change the command to point it at the model in this dir.)

Then run `to_csv.rb path_to_my.json` again. This'll generate a CSV version of the data in the JSON file. It won't be perfect, but it'll be legible.

## model training

I hand-transcribed about 250 pngs. (In training data. I got some help from Tesseract, whose output sucks and is in the gt.txt files in imgs.)

Then trained a Ocropy model with `ocropus-rtrain --load en-default.pyrnn.gz -o oracle-data-ocr-model -N 160000 ../oracle_data_cloud/training_data/*.png` It took about a day to get to 160,000 lines. It defaults to doing a million and I didn't want my computer to spend a week or more training the model.
