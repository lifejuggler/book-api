class BooksController < ApplicationController
  def index

  end
  def request_books
    i = 0
    request = "https://www.googleapis.com/books/v1/volumes?q="
    batch_list = []
    save_list = []
    File.open("test.csv", "r").each_line do |line|
      formatted_isbn = line.strip
      batch_list << formatted_isbn
      if i < 85
        request += "isbn:" + formatted_isbn + "+OR+"
        i += 1
      else
        request += "isbn:" + formatted_isbn
        i = 0
        puts request
        sleep 5
        response = open(request).read
        r_string = JSON.parse response
        request = "https://www.googleapis.com/books/v1/volumes?q="
        puts r_string
        if r_string['totalItems'].to_f > 0
          r_string['items'].each do |item|
            if item['volumeInfo'] && item['volumeInfo']['title']
              title = item['volumeInfo']['title']
            else
              title = ""
            end
            if item['volumeInfo'] && item['volumeInfo']['description']
              description = item['volumeInfo']['description']
            elsif item['searchInfo'] && item['searchInfo']['textSnippet']
              description = item['searchInfo']['textSnippet']
            else
              description = ""
            end
            if item['volumeInfo'] && item['volumeInfo']['authors']
              author = item['volumeInfo']['authors'].join(', ')
            else
              author = ""
            end
            if item['volumeInfo'] && item['volumeInfo']['industryIdentifiers']
              item['volumeInfo']['industryIdentifiers'].each do |ident|
                if ident['type'] == "ISBN_13"
                  save_list << Book.new(isbn: ident['identifier'], :title => title, :description => description, :author => author, read: true)
                end
              end
            end
          end
        end
        sleep 4
        if save_list.length > 100
          Book.import save_list
          save_list = []
        end
      end
    end
  end

  def check_books
    agent = Mechanize.new

    login_form = agent.get("https://ipage.ingramcontent.com/ipage/li001.jsp").form('login')
    search_page = agent.post('https://ipage.ingramcontent.com/ipage/administration/login.action', {
      token:login_form['token'],
      gotoPage:'',
      allow: 'Y',
      username:'msolomich',
      passwd:'tYXGxvp4'
    })
    search_form = search_page.forms.first
    save_list = []
    f = File.new("test.csv", 'r')
    f.each_line do |line|
      formatted_isbn = line.strip
      if Book.find_by(isbn: formatted_isbn)
        f.seek(-line.length, IO::SEEK_CUR)
        # overwrite line with spaces and add a newline char
        f.write('a' * (line.length - 1))
        f.write("\n")
      else
        search_form.searchTerm = formatted_isbn
        result_page = agent.submit(search_form)
        result_form = result_page.forms.second
        if result_form['title']
          b_title = result_form['title']
        else
          b_title = ""
        end
        b_author = []
        if result_form['ctbr1']
          b_author << result_form['ctbr1']
        end
        if result_form['ctbr2']
          b_author << result_form['ctbr2']
        end
        if result_form['ctbr3']
          b_author << result_form['ctbr3']
        end
        author = b_author.join(";")
        b_description = ""
        if result_form['narrativeDescription']
          b_description = result_form['narrativeDescription']
        end
        isbn_id = formatted_isbn
        if !b_title.blank?
          puts "title"
          puts b_title
          puts " author"
          puts author
          puts "desc"
          puts b_description
          puts 'is'
          puts isbn_id
        end
        save_list << Book.new(:title => b_title, :author => b_author, :isbn => isbn_id, read: true, :description => b_description)
      end
      search_form = result_page.forms.first
      if save_list.length > 999
        Book.import save_list
        save_list = []
      end
    end
  end

  def batch_books
    # i = 27
    # Book.where(batch: true).update_all(batch: false)
    # while i <= 34 do

    File.delete('batch.txt') if File.exist?('batch.txt')
    batch = Book.where(batch: false).limit(250000)
    File.open("batch.txt", 'a+'){|f| f <<"title\tauthor\tdescription\tisbn\n"}
    batch.each do |b|
      if !b.author
        author = "none"
      else
        author = b.author
      end
      if !b.description
        desc = "none"
      else
        desc = b.description
      end
      File.open("batch.txt", 'a+'){|f| f << b.title + "\t" + author + "\t" + desc + "\t" + b.isbn + "\n"}
    end
    batch.update_all(batch: true)
    send_file 'batch.txt', :type=>"application/text", :x_sendfile=>true
      # i += 1
    # end
  end
end