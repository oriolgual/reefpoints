module ::Middleman::Blog::BlogArticle
  def legacy_category
    data['legacy_category']
  end

  def shallow?
    !!data['shallow']
  end
end

module LegacyCategory
  def self.registered(app)
    ::Middleman::Blog::BlogData.send(:prepend, ::LegacyCategory::BlogData)
  end

  module BlogData
    def manipulate_resource_list(resources)
      @_articles = []
      used_resources = []

      resources.each do |resource|
        if resource.path =~ path_matcher
          resource.extend Middleman::Blog::BlogArticle

          # Skip articles that are not published (in non-development environments)
          next unless @app.environment == :development || resource.published?

          # compute output path:
          #   substitute date parts to path pattern
          if resource.shallow?
            permalink = ":title.html"
          else
            permalink = options.permalink
          end

          if resource.legacy_category
            permalink = "#{resource.legacy_category}/#{permalink}"
          end
          resource.destination_path = permalink.
            sub(':year', resource.date.year.to_s).
            sub(':month', resource.date.month.to_s.rjust(2,'0')).
            sub(':day', resource.date.day.to_s.rjust(2,'0')).
            sub(':title', resource.slug)

          resource.destination_path = Middleman::Util.normalize_path(resource.destination_path)

          @_articles << resource

        elsif resource.path =~ @subdir_matcher
          match = $~.captures

          article_path = options.sources.
            sub(':year', match[@matcher_indexes["year"]]).
            sub(':month', match[@matcher_indexes["month"]]).
            sub(':day', match[@matcher_indexes["day"]]).
            sub(':title', match[@matcher_indexes["title"]])

          article = @app.sitemap.find_resource_by_path(article_path)
          raise "Article for #{resource.path} not found" if article.nil?
          article.extend BlogArticle

          # Skip files that belong to articles that are not published (in non-development environments)
          next unless @app.environment == :development || article.published?

          # The subdir path is the article path with the index file name
          # or file extension stripped off.
          resource.destination_path = options.permalink.
            sub(':year', article.date.year.to_s).
            sub(':month', article.date.month.to_s.rjust(2,'0')).
            sub(':day', article.date.day.to_s.rjust(2,'0')).
            sub(':title', article.slug).
            sub(/(\/#{@app.index_file}$)|(\.[^.]+$)|(\/$)/, match[@matcher_indexes["path"]])

          resource.destination_path = Middleman::Util.normalize_path(resource.destination_path)
        end

        used_resources << resource
      end

      used_resources
    end
  end
end

::Middleman::Extensions.register(:legacy_category , ::LegacyCategory)
