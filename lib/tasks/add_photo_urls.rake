task :add_photo_urls => :environment do
  add_urls
end

def add_urls
  LoanRequest.all.each do |loan|
    loan.update_attributes(image_url: DefaultImages.random)
    puts "Adding url to loan #{loan.title}"
  end
end
