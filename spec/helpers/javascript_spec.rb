require "spec_helper"
describe Facebooker2::Rails::Helpers::Javascript, :type=>:helper do
  include Facebooker2::Rails::Helpers
  include Facebooker2
  describe "fb_connect_async_js" do
    it "loads with defaults" do
      js = fb_connect_async_js '12345'
      js.gsub(/\s+/, ' ').should == <<-JAVASCRIPT.gsub!(/\s+/, ' ')
          <div id="fb-root"></div>
          <script type="text/javascript">
            window.fbAsyncInit = function() {
              FB.init({
                appId  : '12345',
                status : true, // check login status
                cookie : true, // enable cookies to allow the server to access the session
                xfbml  : true,  // parse XFBML
                oauth  : true,
                channelUrl : 'null'
              });
              
            };

            (function() {
              var e = document.createElement('script'); 
              e.src = document.location.protocol + '//connect.facebook.net/en_US/all.js';
              e.async = true;
              document.getElementById('fb-root').appendChild(e);
            }());
          </script>
      JAVASCRIPT
    end
    
    it "disables cookies" do
      js = fb_connect_async_js '12345', :cookie => false
      js.include?("cookie : false").should be_true, js
    end
    
    it "disables checking login status" do
      js = fb_connect_async_js '12345', :status => false
      js.include?("status : false").should be_true, js
    end
    
    it "disables xfbml parsing" do
      js = fb_connect_async_js '12345', :xfbml => false
      js.include?("xfbml  : false").should be_true, js
    end
    
    it "adds a channel url" do
      js = fb_connect_async_js '12345', :channel_url => 'http://channel.url'
      js.include?("channelUrl : 'http://channel.url'").should be_true, js
    end
    
    it "changes the default locale" do
      js = fb_connect_async_js '12345', :locale => 'fr_FR'
      js.include?("//connect.facebook.net/fr_FR/all.js").should be_true, js
    end

    it "supports oauth" do
      Facebooker2.oauth2=true
      js = fb_connect_async_js '12345'
      js.include?("oauth").should be_true, js
    end

    # Can't get this to work!
    # it "adds extra js" do
    #   helper.output_buffer = ""
    #   fb_connect_async_js do
    #     "FB.Canvas.setAutoResize();"
    #   end
    #   helper.output_buffer.include?("FB.Canvas.setAutoResize();").should be_true, helper.output_buffer
    # end
    
  end
end