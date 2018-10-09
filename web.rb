require 'bundler'
require 'sinatra'
require 'mechanize'
require 'rss'
require 'time'

get '/' do
  url = 'http://www.evernew.co.jp/outdoor/yamanoi/'
  agent = Mechanize.new
  if agent.get(url).code == '200'
    rss = RSS::Maker.make("2.0") do |maker|
      maker.channel.author = '山野井泰史'
      maker.channel.link = 'http://www.evernew.co.jp/outdoor/yamanoi/'
      maker.channel.about = 'http://yamanoi-signal.heroku.com/'
      maker.channel.title = '山野井通信'
      maker.channel.description = '山野井泰史ブログ'
      agent.page.parser.xpath('//section[@class="list"]').each do |entry|
        item = maker.items.new_item
        title_link = entry.at('div.title h2 a')
        item.title = title_link.text
        item.link = title_link.attributes['href']
        item.date = Time.parse(entry.at('div.title span.byline abbr').attributes['title'])
        item.description = entry.at('div.title').next_sibling.text.to_s.gsub(/^\n*(.+)\n*$/m, '\1')
      end
      maker.items.do_sort = true
    end
    rss.to_s
  else
    '?'
  end
end
