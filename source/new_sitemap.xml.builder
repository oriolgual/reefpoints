xml.instruct!
xml.urlset 'xmlns' => "http://www.sitemaps.org/schemas/sitemap/0.9" do
  ['work', 'clients', 'process'].each do |landing|
    xml.url do
      xml.loc "http://dockyard.com/#{landing}"
      xml.lastmod Date.today.to_time.iso8601
      xml.changefreq 'weekly'
      xml.priority '0.6'
    end
  end
  ['learnivore', 'credit-card-reviews', 'scratch-wireless'].each do |work|
    xml.url do
      xml.loc "http://dockyard.com/work/#{work}"
      xml.lastmod Date.today.to_time.iso8601
      xml.changefreq 'weekly'
      xml.priority '0.7'
    end
  end
  ['social-platforms', 'user-research', 'mobile-web-applications', 'data-driven'].each do |capability|
    xml.url do
      xml.loc "http://dockyard.com/capability/#{capability}"
      xml.lastmod Date.today.to_time.iso8601
      xml.changefreq 'weekly'
      xml.priority '0.7'
    end
  end
  xml.url do
      xml.loc "http://dockyard.com/ember-consulting"
      xml.lastmod Date.today.to_time.iso8601
      xml.changefreq 'weekly'
      xml.priority '0.9'
    end
  sitemap.resources.select { |page| page.path =~ /\.html/ }.each do |page|
    xml.url do
      xml.loc "http://dockyard.com/blog#{page.url.sub(/.html/, '')}"
      xml.lastmod Date.today.to_time.iso8601
      xml.changefreq page.data.changefreq || 'daily'
      xml.priority page.data.priority || '0.5'
    end
  end
end
