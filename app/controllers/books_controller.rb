class BooksController < ApplicationController
  def index

  end
  def request_books
    i = 1
    # assigned_num = ENV['ORDER_NUM'].to_i
    while i < 6
      EnhancedWorker.perform_async(i)
      i = i + 1
      # assigned_num = assigned_num
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
    # isbn_list = []
    i = 0
    f = File.new("test3.csv", 'r')
    f.each_line do |line|
      buff_sleep = rand(1..2)
      formatted_isbn = line.strip
      puts formatted_isbn
      sleep(buff_sleep)
        # f.seek(-line.length, IO::SEEK_CUR)
        # # overwrite line with spaces and add a newline char
        # f.write('a' * (line.length - 1))
        # f.write("\n")
      search_form.searchTerm = formatted_isbn
      begin
        result_page = agent.submit(search_form)
      rescue Exception=>e
        fail_sleep = rand(5..10)
        puts 'sleeping for ' +  fail_sleep.to_s + 'sec cause I failed'
        sleep(fail_sleep)
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
        search_form.searchTerm = formatted_isbn
        retry
      end
      result_form = result_page.form_with(:name => 'DetailEmail')
      if result_form
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
        if !result_form['narrativeDescription'].strip.blank?
          b_description = result_form['narrativeDescription']
        elsif !result_form['ingramDescription'].strip.blank?
          b_description = result_form['ingramDescription']
        else
          b_description = ""
        end
        isbn_id = formatted_isbn
        if !b_title.blank?
          save_list << Book.new(:title => b_title, :author => author, :isbn => isbn_id, read: true, :description => b_description)
        end
      end
      if result_page
        search_form = result_page.form_with(:name => 'searchForm')
      end
      i = i + 1
      puts i
      if save_list.length > 199
        Book.import save_list
        save_list = []
      end
    end
  end

  def batch_books
    # i = 27
    # Book.where(batch: true).update_all(batch: false)
    # while i <= 34 do

    # File.delete('isbn13.txt') if File.exist?('batch.txt')
    # batch = Book.where(batch: false).limit(250000)
    # File.open("batch.txt", 'a+'){|f| f <<"title\tauthor\tdescription\tisbn\n"}
    # batch.each do |b|
    #   if !b.author
    #     author = "none"
    #   else
    #     author = b.author
    #   end
    #   if !b.description
    #     desc = "none"
    #   else
    #     desc = b.description
    #   end
    #   File.open("batch.txt", 'a+'){|f| f << b.title + "\t" + author + "\t" + desc + "\t" + b.isbn + "\n"}
    # end
    # batch.update_all(batch: true)
    # send_file 'batch.txt', :type=>"application/text", :x_sendfile=>true
      # i += 1
    # end
    i = 1
    j = 1
    k = 1
    Dir.mkdir('f1')
    f = File.new("isbn13.csv", 'r')
    f.each_line do |line|
      File.open("f" + i.to_s + "/sub" + j.to_s + ".csv", 'a+'){|f| f << line}
      if k == 100001
        j = j + 1
        k = 1
      end
      if j == 6
        j = 1
        i = i + 1
        Dir.mkdir('f' + i.to_s)
      end
      k = k + 1
    end
  end
end