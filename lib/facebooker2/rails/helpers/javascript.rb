module Facebooker2
  module Rails
    module Helpers
      module Javascript
        def fb_concat(str)
          if ::Rails::VERSION::STRING.to_i > 2
            str
          else
            concat(str); ""
          end
        end


        def fb_html_safe(str)
          if str.respond_to?(:html_safe)
            str.html_safe
          else
            str
          end
        end
        
        def fb_connect_async_js(*args, &block)
          options = args.extract_options!
          
          app_id  = args.shift || Facebooker2.app_id
          
          fb_connect_js(app_id, options.merge(:async => true), &block)
        end

        def fb_connect_js(*args, &block)
          options = args.extract_options!
          
          app_id  = args.shift || Facebooker2.app_id

          options.reverse_merge!(
            :cookie   => true,
            :status   => true,
            :xfbml    => true,
            :oauth    => Facebooker2.oauth2,
            :locale   => "en_US"
          )

          extra_js = capture(&block) if block_given?

          init_js = <<-JAVASCRIPT
            FB.init({
              appId  : '#{app_id}',
              status : #{options[:status]}, // check login status
              cookie : #{options[:cookie]}, // enable cookies to allow the server to access the session
              xfbml  : #{options[:xfbml]},  // parse XFBML
              oauth  : #{options[:oauth]},
              channelUrl : '#{ options[:channel_url] || 'null' }'
            });
          JAVASCRIPT
          
          js_url = "connect.facebook.net/#{options[:locale]}/all.js"
          js_url << "?#{Time.now.change(:min => 0, :sec => 0, :usec => 0).to_i}" if options[:weak_cache]
          
          if options[:async]
            js = <<-JAVASCRIPT
              window.fbAsyncInit = function() {
                #{init_js}
                #{extra_js}
              };

              (function() {
                var e = document.createElement('script');
                e.src = document.location.protocol + '//#{ js_url }';
                e.async = true;
                document.getElementById('fb-root').appendChild(e);
              }());
            JAVASCRIPT
            
            js = <<-CODE
              <div id="fb-root"></div>
              <script type="text/javascript">#{ js }</script>
            CODE
          else
            js = <<-CODE
              <div id="fb-root"></div>
              <script src="#{request.protocol}#{ js_url }" type="text/javascript"></script>
            CODE
            
            if options[:cache_url]
              js << <<-CODE
                <script type="text/javascript">
                  if(typeof FB == 'undefined'){
                    document.write(unescape(\"%3Cscript src='#{options[:cache_url]}' type='text/javascript'%3E%3C/script%3E\"))
                  }
                </script>
              CODE
            end
            
            js << <<-CODE
              <script type="text/javascript">
                if(typeof FB != 'undefined'){
                  #{init_js}
                  #{extra_js}
                }
              </script>
            CODE
          end

          js = fb_html_safe(js)

          block_given? ? fb_concat(js) : js
        end
      end
    end
  end
end
