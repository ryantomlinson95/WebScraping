require 'mechanize'

# Authors: Ryan Tomlinson, Crystal Ceballos, Tammy Joseph, Ziming Gong
# Group name: Gem
# Project 3, WebScraping

# Use Mechanize gem to activate the web site for scraping
mechanize = Mechanize.new
page = mechanize.get('https://www.jobsatosu.com/postings/search')

# Create and open a new file to place the search results
file = File.open("JobPostings.html", 'w')

# Format the search results file for viewing in web browser
# Uses OSU branded styling--colors and font-family
file.write("<!DOCTYPE html>\n")
file.write("<html lang=\"en\">\n")
file.write("<head>\n")
file.write("\t<meta charset=\"utf-8\">\n")
file.write("\t<title>Jobs</title>\n")
file.write("\t<style type='text/css'>\n")
file.write("\t\tbody {\n\t\t\tfont-family: Gill, Helvetica, sans-serif;\n\t\t\tbackground-color: lightgray;\t\n\t\t}\n")
file.write("\t\t.content {\n\t\t\tfont-family: Gill, Helvetica, sans-serif;\n\t\t\tmargin-left: 40px;\n\t\t}\n")
file.write("\t\th1 {\n\t\t\tcolor: lightgray;\n\t\t\tfont-family: Gill, Helvetica, sans-serif;\n\t\t\tfont-style: bold;\n\t\t\tbackground-color: darkred;\n\t\t\tmargin-top: 0;\n\t\t\tpadding: 20px 20px 20px 40px;}\n")
file.write("\t\t.jobTitle {\n\t\t\tfont-weight: bold;\n\t\t}\n")
file.write("\t</style>\n")
file.write("</head>\n")


file.write("<body>\n")
file.write("<h1>Job Search Results<br></h1>\n")
check = "y"
keywords = []

file.write("<div class=\"content\">\n")

# Check == 'y' continues to prompt the user for a keyword to search
while check == "y"
    
    # Asks for the keyword to search
    system "clear"
    puts "Enter a keyword for a job search:"
    keyword = gets.chomp!
    keywords << keyword
    puts "Searching..."

    # Goes to the first form, query box, then enters keyword
    page.forms[0]["query"] = keyword
    # Submits the form and creates a new page called formSubmitPage
    formSubmitPage = page.forms[0].submit
     
    jobLinks = []
    jobTitles = []
    # Clicks on the details of each posting
    formSubmitPage.links_with(:text => 'View Details').each do |link|
        jobPage = link.click
        jobLinks << link.href
        jobTitles << jobPage.title
    end
    puts "Done.\n"
    # Print the results to the file if there are any
    file.write("Results for <span class=\"jobTitle\">#{keyword}:</span><br><br>\n") if jobLinks.size > 0
    file.write("No Results for <span class=\"jobTitle\">#{keyword}</span><br>\n") if jobLinks.size <= 0
    
    # Printing each job listing title to the file 
    (0...jobLinks.size).each { |i| file.write("\t<a href=\"https://www.jobsatosu.com/#{jobLinks[i]}\">#{jobTitles[i]}</a><br>\n") }
    puts "\nWould you like search for another keyword? [y/n]"
    check = gets.downcase.chomp!

    file.write("<br>")
end


puts "Finalizing Web Page...\n"

# Check for a multi-word keyword search
if (keywords.length > 1) 
    page.forms[0]["query"] = keywords.join " "
    formSubmitPage = page.forms[0].submit

    jobLinks = []
    jobTitles= []
    # Submit multi-word keyword for searching
    formSubmitPage.links_with(:text => 'View Details').each do |link|
        jobPage = link.click
        jobLinks << link.href
        jobTitles << jobPage.title
    end
    # Print the results of the job search to the job results page
    file.write("Results for <span class=\"jobTitle\">#{keywords.join " & "}:</span><br><br>\n") if jobLinks.size > 0
    file.write("No results for <span class=\"jobTitle\">#{keywords.join " & "}</span><br>\n") if jobLinks.size <= 0

    (0...jobLinks.size).each { |i| file.write("\t<a href=\"https://www.jobsatosu.com/  #{jobLinks[i]}\">#{jobTitles[i]}</a><br>\n") }
end

file.write("</div><br>\n")
file.write("</body>\n")
file.write("</html>\n")

puts "Done.\n"

file.close
# Open the web page in Firefox to show the search results
system("firefox JobPostings.html")
