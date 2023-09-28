require "uri"

module Invidious::Frontend::Pagination
  extend self

  private def previous_page(str : String::Builder, locale : String?, url : String)
    # Link
    str << %(<a href=") << url << %(" class="pure-button pure-button-secondary">)

    if locale_is_rtl?(locale)
      # Inverted arrow ("previous" points to the right)
      str << translate(locale, "Previous page")
      str << "&nbsp;&nbsp;"
      str << %(<i class="icon ion-ios-arrow-forward"></i>)
    else
      # Regular arrow ("previous" points to the left)
      str << %(<i class="icon ion-ios-arrow-back"></i>)
      str << "&nbsp;&nbsp;"
      str << translate(locale, "Previous page")
    end

    str << "</a>"
  end

  private def next_page(str : String::Builder, locale : String?, url : String)
    # Link
    str << %(<a href=") << url << %(" class="pure-button pure-button-secondary">)

    if locale_is_rtl?(locale)
      # Inverted arrow ("next" points to the left)
      str << %(<i class="icon ion-ios-arrow-back"></i>)
      str << "&nbsp;&nbsp;"
      str << translate(locale, "Next page")
    else
      # Regular arrow ("next" points to the right)
      str << translate(locale, "Next page")
      str << "&nbsp;&nbsp;"
      str << %(<i class="icon ion-ios-arrow-forward"></i>)
    end

    str << "</a>"
  end

  def nav_numeric(locale : String?, *, base_url : String | URI, current_page : Int, show_next : Bool = true)
    return String.build do |str|
      str << %(<div class="h-box">\n)
      str << %(<div class="page-nav-container flexible">\n)

      str << %(<div class="page-prev-container flex-left">)

      if current_page > 1
        params_prev = URI::Params{"page" => (current_page - 1).to_s}
        url_prev = HttpServer::Utils.add_params_to_url(base_url, params_prev)

        self.previous_page(str, locale, url_prev.to_s)
      end

      str << %(</div>\n)
      str << %(<div class="page-next-container flex-right">)

      if show_next
        params_next = URI::Params{"page" => (current_page + 1).to_s}
        url_next = HttpServer::Utils.add_params_to_url(base_url, params_next)

        self.next_page(str, locale, url_next.to_s)
      end

      str << %(</div>\n)

      str << %(</div>\n)
      str << %(</div>\n\n)
    end
  end

  def nav_ctoken(locale : String?, *, base_url : String | URI, ctoken : String?, cctoken : String?, prev : String?)
    return String.build do |str|
      str << %(<div class="h-box">\n)
      str << %(<div class="page-nav-container flexible">\n)

      str << %(<div class="page-prev-container flex-left">)

      if !prev.nil?
        prev_copy = Array(String).from_json(prev)
	if prev_copy.size == 1
	  previous_ctoken = prev_copy.pop
          params_prev = URI::Params{"continuation" => previous_ctoken}
	else
          previous_ctoken = prev_copy.pop
          prev_before = prev_copy.to_json
          params_prev = URI::Params{"continuation" => previous_ctoken, "prev" => prev_before}
        end
        url_prev = HttpServer::Utils.add_params_to_url(base_url, params_prev)

        self.previous_page(str, locale, url_prev.to_s)
      end

      if prev.nil? && !cctoken.nil?
        self.previous_page(str, locale, base_url)
      end

      str << %(</div>\n)

      str << %(<div class="page-next-container flex-right">)

      if !ctoken.nil? && !prev.nil? && !cctoken.nil?
        prev_copy1 = Array(String).from_json(prev)
        prev_copy1.push(cctoken)
	prev_after = prev_copy1.to_json
        params_next = URI::Params{"continuation" => ctoken, "prev" => prev_after}
        url_next = HttpServer::Utils.add_params_to_url(base_url, params_next)

        self.next_page(str, locale, url_next.to_s)
      end

      if !ctoken.nil? && prev.nil? && !cctoken.nil?
        prev_copy1 = Array(String).new
	prev_copy1.push(cctoken)
        prev_after = prev_copy1.to_json
        params_next = URI::Params{"continuation" => ctoken, "prev" => prev_after}
        url_next = HttpServer::Utils.add_params_to_url(base_url, params_next)

        self.next_page(str, locale, url_next.to_s)
      end

      if !ctoken.nil? && prev.nil? && cctoken.nil?
        params_next = URI::Params{"continuation" => ctoken}
        url_next = HttpServer::Utils.add_params_to_url(base_url, params_next)

        self.next_page(str, locale, url_next.to_s)
      end

      str << %(</div>\n)

      str << %(</div>\n)
      str << %(</div>\n\n)
    end
  end
end
