require 'json'
require 'csv'
require 'net/http'
require 'fileutils'

rows = JSON.load(open(ARGV[0] || File.join(File.dirname(__FILE__), "registry.json")).read.split("(")[1].strip[0...-1])

output_filename = ARGV[0].gsub(".json", ".csv") || "bluekai.csv"
open(output_filename, "w") # wipe it out

$imgs_path = File.join(File.dirname(__FILE__), "imgs")
FileUtils.mkdir_p($imgs_path)
def get_img_path(url)
  img_path = File.join($imgs_path, url.split("/").last)
  return img_path if File.exists?(img_path)
  img_data = Net::HTTP.get(URI(url))
  open(img_path, 'wb'){|f| f << img_data}
  img_path
end

def OLD_get_text(img_url) # this uses the rtesseract gem and it sucks
  img_path = get_img_path(img_url)
  img_txt_fn = img_path.gsub(".png", ".gt.txt")
  return open(img_txt_fn, 'r'){|f| f.read} if File.exists?(img_txt_fn)
  txt = RTesseract.read(img_path) do |img|
    img = img.white_threshold(245)
    img = img.quantize(256,Magick::GRAYColorspace)
    img
  end.to_s.strip
  open(img_txt_fn, 'w'){|f| f << txt }
  txt
end

def get_text(img_url)
  img_path = get_img_path(img_url)
  img_txt_fn = img_path.gsub(File.basename(img_path), File.basename(img_path).split(".", 2).first + ".txt")
  File.exists?(img_txt_fn) ? open(img_txt_fn, 'r'){|f| f.read } : "MISSING: #{img_path}"
end

CSV.open(output_filename, "a") do |csv|

  rows.each_slice(100) do |slice|
    slice.each do |row|
      img_text = get_img_path(row["img"]).strip
      fimg_text = get_img_path(row["fimg"]).strip
    end
  end  
  `cd ~/code/ocropy/; ./ocropus-rpred -n -m ~/code/ocropy/oracle-data-ocr-model-00160000.pyrnn.gz ../oracle_data_cloud/imgs/*.png`
  rows.each_slice(100) do |slice|
    slice.each do |row|
      # "img": "http://tags.bluekai.com/registry/png/75_58595b_FFFFFF_11.00_20_0.png",
      # "fimg": "http://tags.bluekai.com/registry/png/75_7d7d7d_FFFFFF_9.00_16_1.png",
      # "hv": "303327342",
      img_text = get_text(row["img"]).strip
      fimg_text = get_text(row["fimg"]).strip
      # puts "#{img_text}: #{fimg_text}"
      split_fimg = fimg_text.split(">").map(&:strip)
      csv << split_fimg + [""] * (9 - split_fimg.size) + [img_text, row["hv"]]
    end
    puts "downloaded and ocred several"
  end
end

