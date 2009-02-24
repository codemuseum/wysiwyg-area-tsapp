class Html2Controller < ApplicationController
  ProtocolRegexp = %r{^[-a-z]+://}.freeze
  
  def index
    @include_host = true # FIXME Backwards compatibility with Rails 2.2.2 asset tags
    
    content = read_source_content
    
    respond_to do |format|
      format.js do 
      
        # Assuming iframe just has to write to document
        render :update do |page| page << "document.open();document.write(#{content.to_json});document.close();" end
      
        # Assuming js has to make iframe in order to write to it
        # val = <<-eos
        #   // Prevent Access Denied Errors
        #   (function() {
        #             // alert("STARTING SCRIPT");
        #     var id = #{params[:id].to_json};
        #     var DOM = tinymce.DOM;
        #     
        #             if (tinymce.isIE)
        #               iu = 'javascript:(function(){document.open();document.write(#{content.to_json});document.close();})()';
        #             else
        #               iu = 'javascript:""'
        # 
        #             // alert("CREATING FRAME");
        #             DOM.add(id + '_content', 'iframe', {id : id + '_ifr', src : iu, frameBorder : 0, style : 'border:0;width:10px;height:10px'});
        #             DOM.setStyles(id + '_ifr', {width : #{params[:w].to_i}, height : #{params[:h].to_i}});
        #     // DOM.setAttrib(id + '_ifr', 'src', u); // Avoid this call to avoid XSS
        #     
        #             // alert("STARTING TO WRITE");
        #     // Start testing on how to write to window
        #     if (!tinymce.isIE) {
        #       idoc = DOM.get(id + "_ifr").contentWindow.document;
        #       idoc.open();
        #               idoc.write(#{content.to_json});
        #               idoc.close();
        #             }
        #             //alert("DONE");
        #           })();
        # eos
        # 
        # logger.debug "OUTPUTTING SCRIPT--------------\n#{val}\n----------------"
        # 
        # render :update do |page|  page << val end
      end
    end
  end
  
  protected 
  
    def source_param
      src = params[:src]
      src = src[src.index('javascripts/tiny_mce/')+'javascripts/tiny_mce/'.length..-1]
      src, params = src.split('?', 2)
      src.gsub(/\.\./, '')
    end
    
    def read_source_content
      src = source_param
      src_dir = src[0..src.rindex('/')]
      content = File.readlines(File.join('public', 'javascripts', 'tiny_mce', src)).join('')
      content.
        gsub(/type="text\/javascript" src="/, 'type="text/javascript" src="' + compute_mce_path(src_dir)).
        gsub(/href="css\//, 'href="' + compute_mce_path(src_dir+'css/')).
        gsub(/ src="img\//, ' src="'+ compute_mce_path(src_dir+'img/'))
    end
    
    
    def compute_mce_path(source)
      src = '/javascripts/tiny_mce/' + source
      src = prepend_relative_url_root(src)
      src = prepend_asset_host(src)
      src
    end
    
    # Stolen from the privates of AssetTagHelper
    def prepend_relative_url_root(source)
      relative_url_root = ActionController::Base.relative_url_root
      if request? && @include_host && source !~ %r{^#{relative_url_root}/}
        "#{relative_url_root}#{source}"
      else
        source
      end
    end
    
    # Stolen from the privates of AssetTagHelper
    def prepend_asset_host(source)
      if @include_host && source !~ ProtocolRegexp
        host = compute_asset_host(source)
        if request? && !host.blank? && host !~ ProtocolRegexp
          host = "#{request.protocol}#{host}"
        end
        "#{host}#{source}"
      else
        source
      end
    end
    
    # Slightly modified version stolen from the privates of AssetTagHelper
    def compute_asset_host(source)
      if host = ActionController::Base.asset_host
        if host.is_a?(Proc)
          case host.arity
          when 2
            host.call(source, request)
          else
            host.call(source)
          end
        else
          (host =~ /%d/) ? host % (source.hash % 4) : host
        end
      end
    end
    
    # Backwards compatibility with privates of AssetTagHelper
    def request?
      true
    end
end
