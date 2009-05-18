#!/usr/bin/env ruby
#
#
require 'net/http'
require 'uri'
require 'iconv'
require 'rubygems'
require 'mechanize'

icons = ['png-0901.png', 'png-0902.png', 'png-0903.png', 'png-0904.png', 'png-0905.png', 'png-0906.png', 'png-0907.png', 'png-0908.png', 'png-1009.png']
iconno = rand(icons.length)
$notifyargs = "notify-send -t 5000 -i ~/.icons/%s" %icons[iconno]

def translate(string)
    translation = IO.popen(%Q{sdcv -u 朗道英汉字典5.0 -n "%s"} % string).readlines
    for line in translation
        translation.shift
        break if line =~ /^-->#{string}$/
    end
    translation.shift
    if translation
        system(%Q{%s "%s的意思是：" "%s"} % [$notifyargs, string,translation] )
        system(%Q{espeak %s} %string)
    else
        text = %Q{<span size="13000" color="brown" weight="bold">%s</span>} \
            % "\n\n  没有查到%s这个词" %string 
        system("%s '很抱歉：' '%s'" % [$notifyargs, text] )
    end
end

def ipLookup(string)
    res = Net::HTTP.post_form(URI.parse("http://ipseeker.cn/index.php"),
            {'B1'=>Iconv.iconv("GB2312","UTF-8",'查询'), 'job'=>'search','search_ip'=>string})
    page = Iconv.iconv("UTF-8","GB2312",res.body).join
    address = page.scan(/查询结果二.*#{string}.*?-&nbsp;\s+(.*?)<\/span/)[0][0]
    text = %Q{<span size="13000" color="red" weight="bold">%s</span>} \
            % ("\n"+ address.sub(" ", "\n\n    ") )
    system("%s '%s地址在：' '%s'" % [$notifyargs,string,text] )
end

def phoneLookup(string)
    #手机号查询
    res = Net::HTTP.post_form(URI.parse("http://flash.chinaren.com/ip/mobile.php"),
                              {'mobile'=>string,'step'=>'2'})
    page = Iconv.iconv("UTF-8","GBK",res.body).join
    result = page.scan(/tdc2>(.*?)<\/TD>/)
    text = %Q{<span size="13000" color="red" weight="bold">%s</span>} \
            % ("\n"+result[1][0].sub('&nbsp;', '')+"\n\n"+result[2][0])
    system %Q{%s '%s机主在：' '%s'} % [$notifyargs,string,text] 
end 

def pasteSelection(string)
    #上传选中内容
    agent = WWW::Mechanize.new
    agent.max_history = 1
    agent.user_agent_alias= 'Windows IE 7'
    begin
        page = agent.get("http://paste.ubuntu.org.cn/")
    rescue Timeout::Error
        text = %Q{<span size="14000" color="red" weight="bold">\n\n无法连接paste.ubuntu.org.cn</span>}
        system "#{$notifyargs} 'Ooops...'  '#{text}'"
        exit
    end
    form = page.form('editor')
    form.field('poster').value = 'roylez'
    form.field('code2').value = string
    npage = form.submit( form.button('paste') )
    nurl = npage.uri.to_s
    system "echo '#{nurl}'|xclip -i -selection primary"
    system "echo '#{nurl}'|xclip -i -selection clipboard"
    text = %Q{<span size="14000" color="green" weight="bold">\n\n请直接粘贴URL</span>} 
    system "#{$notifyargs} '上传成功：'  '#{text}'"
end

if __FILE__==$0
    string = `xclip -o`
    string = ARGV[0] if ARGV.length == 1

    puts string
    if string =~ /^[a-zA-Z]+$/
        #单词查询
        translate( string)
    elsif string =~ /^(\d{1,3}\.){3}\d{1,3}$/
        #ip查询
        ipLookup( string )
    elsif string =~ /^1(\d){10}$/
        #手机号查询
        phoneLookup( string )
    elsif string.strip =~ /^(https?|ftp):\/\/[\-\.\,\/%~_:?\#a-zA-Z0-9=&\;]+$/
        #打开网页
        system("$HOME/bin/firefox '%s' &" %string.strip)
    elsif string =~ /^((.*?)\n)+.*$/
        ##上传选中内容
        pasteSelection( string )
    else
        text = %Q{<span size="13000" color="red" weight="bold">%s</span>} \
            % "\nThou must give me a command!"
        system %Q{%s '咦？' '%s'} % [$notifyargs,text]
    end
end
