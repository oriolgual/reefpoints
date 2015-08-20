xml.instruct!
xml.feed 'xmlns' => 'http://www.w3.org/2005/Atom' do
  site_url = 'https://dockyard.com/blog'
  xml.title 'DockYard blog'
  xml.id URI.join(site_url, blog.options.prefix.to_s)
  xml.link 'href' => URI.join(site_url, blog.options.prefix.to_s)
  xml.link 'href' => URI.join(site_url, 'blog/atom.xml'), 'rel' => 'self'
  xml.updated blog.articles.first.date.to_time.iso8601
  xml.author { xml.name 'DockYard' }

  blog.articles.select { |art| art.data.published }.each do |article|
    article_url = "#{site_url}#{article.url.sub(/.html\z/, '')}"
    xml.entry do
      xml.title article.title
      xml.link 'rel' => 'alternate', 'href' => article_url
      xml.id article_url
      article.tags.each do |tag|
        xml.category 'term' => tag.downcase.gsub(/\s+/, '-').underscore.dasherize, 'label' => tag
      end
      xml.published article.date.to_time.iso8601
      xml.updated File.mtime(article.source_file).iso8601
      xml.author { xml.name article.author }
      xml.summary article.summary
      xml.content article.body, 'type' => 'html'
    end
  end
end
