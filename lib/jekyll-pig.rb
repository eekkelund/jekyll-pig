
require 'fileutils'
require 'json'
require 'mini_magick'

module JekyllPig
    
    class SourceGallery
        def initialize(options)
            @path = options[:path]
            @name = options[:name]
            @create_html = options[:create_html] != false
        end
        def to_s
            "gallery #{@name} at #{@path}"
        end
        def path
            @path
        end
        def name
            @name
        end
        def create_html
            @create_html
        end
    end

    class JekyllPig < Jekyll::Generator
    
        @@image_cache = {}
    
        @@pig_min_js = '(function(l,a){typeof define=="function"&&define.amd?define([],a()):typeof module=="object"&&module.exports?module.exports=a():(l.Pig=a().Pig,l.ProgressiveImage=a().ProgressiveImage)})(typeof self!="undefined"?self:exports,function(){var l=class{constructor(t,e,i){return this.existsOnPage=!1,this.aspectRatio=t.aspectRatio,this.filename=t.filename,this.index=e,this.pig=i,this.classNames={figure:`${i.settings.classPrefix}-figure`,thumbnail:`${i.settings.classPrefix}-thumbnail`,loaded:`${i.settings.classPrefix}-loaded`},this}load(){this.existsOnPage=!0,this._updateStyles(),this.pig.container.appendChild(this.getElement()),setTimeout(()=>{!this.existsOnPage||this.addAllSubElements()},100)}hide(){this.getElement()&&this.removeAllSubElements(),this.existsOnPage&&this.pig.container.removeChild(this.getElement()),this.existsOnPage=!1}getElement(){return this.element||(this.element=document.createElement(this.pig.settings.figureTagName),this.element.className=this.classNames.figure,this.pig.settings.onClickHandler!==null&&this.element.addEventListener("click",()=>{this.pig.settings.onClickHandler(this.filename)}),this._updateStyles()),this.element}addImageAsSubElement(t,e,i,n=""){let s=this[t];s||(this[t]=new Image,s=this[t],s.src=this.pig.settings.urlForSize(e,i),n.length>0&&(s.className=n),s.onload=()=>{s&&(s.className+=` ${this.classNames.loaded}`)},this.getElement().appendChild(s))}addAllSubElements(){this.addImageAsSubElement("thumbnail",this.filename,this.pig.settings.thumbnailSize,this.classNames.thumbnail),this.addImageAsSubElement("fullImage",this.filename,this.pig.settings.getImageSize(this.pig.lastWindowWidth))}removeSubElement(t){const e=this[t];e&&(e.src="",this.getElement().removeChild(e),delete this[t])}removeAllSubElements(){this.removeSubElement("thumbnail"),this.removeSubElement("fullImage")}_updateStyles(){this.getElement().style.transition=this.style.transition,this.getElement().style.width=`${this.style.width}px`,this.getElement().style.height=`${this.style.height}px`,this.getElement().style.transform=`translate3d(${this.style.translateX}px, ${this.style.translateY}px, 0)`}},a=class{constructor(){this._callbacks=[],this._running=!1}add(t){this._callbacks.length||window.addEventListener("resize",this._resize.bind(this)),this._callbacks.push(t)}disable(){window.removeEventListener("resize",this._resize.bind(this))}reEnable(){window.addEventListener("resize",this._resize.bind(this))}_resize(){this._running||(this._running=!0,window.requestAnimationFrame?window.requestAnimationFrame(this._runCallbacks.bind(this)):setTimeout(this._runCallbacks.bind(this),66))}_runCallbacks(){this._callbacks.forEach(t=>{t()}),this._running=!1}},d=class{constructor(){this.containerId="pig",this.scroller=window,this.classPrefix="pig",this.figureTagName="figure",this.spaceBetweenImages=8,this.transitionSpeed=500,this.primaryImageBufferHeight=1e3,this.secondaryImageBufferHeight=300,this.thumbnailSize=20,this.onClickHandler=null}urlForSize(t,e){return`/img/${e.toString(10)}/${t}`}getMinAspectRatio(t){return t<=640?2:t<=1280?4:t<=1920?5:6}getImageSize(t){return t<=640?100:t<=1920?250:500}createProgressiveImage(t,e,i){return new l(t,e,i)}},m=class{constructor(t,e){return this._optimizedResize=new a,this.inRAF=!1,this.isTransitioning=!1,this.minAspectRatioRequiresTransition=!1,this.minAspectRatio=null,this.latestYOffset=0,this.lastWindowWidth=window.innerWidth,this.scrollDirection="down",this.visibleImages=[],this.settings=Object.assign(new d,e),this.container=document.getElementById(this.settings.containerId),this.container||console.error(`Could not find element with ID ${this.settings.containerId}`),this.scroller=this.settings.scroller,this.images=this._parseImageData(t),this._injectStyle(this.settings.containerId,this.settings.classPrefix,this.settings.transitionSpeed),this}enable(){return this.onScroll=this._getOnScroll(),this.scroller.addEventListener("scroll",this.onScroll),this.onScroll(),this._computeLayout(),this._doLayout(),this._optimizedResize.add(()=>{this.lastWindowWidth=this.scroller===window?window.innerWidth:this.scroller.offsetWidth,this._computeLayout(),this._doLayout()}),this}disable(){return this.scroller.removeEventListener("scroll",this.onScroll),this._optimizedResize.disable(),this}_parseImageData(t){const e=[];return t.forEach((i,n)=>{const s=this.settings.createProgressiveImage(i,n,this);e.push(s)}),e}_getOffsetTop(t){let e=0;do Number.isNaN(t.offsetTop)||(e+=t.offsetTop),t=t.offsetParent;while(t);return e}_injectStyle(t,e,i){const n=`#${t} {  position: relative;}.${e}-figure {  background-color: #D5D5D5;  overflow: hidden;  left: 0;  position: absolute;  top: 0;  margin: 0;}.${e}-figure img {  left: 0;  position: absolute;  top: 0;  height: 100%;  width: 100%;  opacity: 0;  transition: ${(i/1e3).toString(10)}s ease opacity;  -webkit-transition: ${(i/1e3).toString(10)}s ease opacity;}.${e}-figure img.${e}-thumbnail {  -webkit-filter: blur(30px);  filter: blur(30px);  left: auto;  position: relative;  width: auto;}.${e}-figure img.${e}-loaded {  opacity: 1;}`,s=document.head||document.getElementsByTagName("head")[0],o=document.createElement("style");o.appendChild(document.createTextNode(n)),s.appendChild(o)}_getTransitionTimeout(){const t=1.5;return this.settings.transitionSpeed*t}_getTransitionString(){return this.isTransitioning?`${(this.settings.transitionSpeed/1e3).toString(10)}s transform ease`:"none"}_recomputeMinAspectRatio(){const t=this.minAspectRatio;this.minAspectRatio=this.settings.getMinAspectRatio(this.lastWindowWidth),t!==null&&t!==this.minAspectRatio?this.minAspectRatioRequiresTransition=!0:this.minAspectRatioRequiresTransition=!1}_computeLayout(){const t=parseInt(this.container.clientWidth,10);let e=[],i=0,n=0,s=0;this._recomputeMinAspectRatio(),!this.isTransitioning&&this.minAspectRatioRequiresTransition&&(this.isTransitioning=!0,setTimeout(()=>{this.isTransitioning=!1},this._getTransitionTimeout()));const o=this._getTransitionString();[].forEach.call(this.images,(r,u)=>{if(s+=parseFloat(r.aspectRatio),e.push(r),s>=this.minAspectRatio||u+1===this.images.length){s=Math.max(s,this.minAspectRatio);const h=(t-this.settings.spaceBetweenImages*(e.length-1))/s;e.forEach(g=>{const c=h*g.aspectRatio;g.style={width:parseInt(c,10),height:parseInt(h,10),translateX:i,translateY:n,transition:o},i+=c+this.settings.spaceBetweenImages}),e=[],s=0,n+=parseInt(h,10)+this.settings.spaceBetweenImages,i=0}}),this.totalHeight=n-this.settings.spaceBetweenImages}_doLayout(){this.container.style.height=`${this.totalHeight}px`;const t=this.scrollDirection==="up"?this.settings.primaryImageBufferHeight:this.settings.secondaryImageBufferHeight,e=this.scrollDirection==="down"?this.settings.secondaryImageBufferHeight:this.settings.primaryImageBufferHeight,i=this._getOffsetTop(this.container),n=this.scroller===window?window.innerHeight:this.scroller.offsetHeight,s=this.latestYOffset-i-t,o=this.latestYOffset-i+n+e;this.images.forEach(r=>{r.style.translateY+r.style.height<s||r.style.translateY>o?r.hide():r.load()})}_getOnScroll(){const t=this;return()=>{const i=t.scroller===window?window.pageYOffset:t.scroller.scrollTop;t.previousYOffset=t.latestYOffset||i,t.latestYOffset=i,t.scrollDirection=t.latestYOffset>t.previousYOffset?"down":"up",t.inRAF||(t.inRAF=!0,window.requestAnimationFrame(()=>{t._doLayout(),t.inRAF=!1}))}}};return{Pig:m,ProgressiveImage:l}});'
        def full_size_html(gallery_name, name, date, prev_url, next_url)
            "---\n"                                                                                                                                         \
            "layout: post\n"                                                                                                                                \
            "title: #{name}\n"                                                                                                                              \
            "date: #{date.strftime("%Y-%m-%d %H:%M:%S")}\n"                                                                                                 \
            "permalink: /assets/html/#{gallery_name}/#{name}.html\n"                                                                                        \
            "exclude: true\n"                                                                                                                               \
            "---\n"                                                                                                                                         \
            "<div><a href=\"#{prev_url}\" style=\"display:inline;\">prev</a><a href=\"#{next_url}\" style=\"display:inline; float:right\">next</a></div>\n" \
            "<img src=\"{{site.baseurl}}/assets/img/#{gallery_name}/1024/#{name}\"/>\n"                                                                                     
        end
        
        def gallery_html(id, image_data)
            "<div id='#{id}_pig'></div>\n"                                                                                                  \
            "<script src='{{site.baseurl}}/assets/js/pig.min.js'></script>\n"                                                               \
            "<script>\n"                                                                                                                    \
            "class ProgressiveImageCustom extends ProgressiveImage {\n"                                                                     \
            "    constructor(singleImageData, index, pig) {\n"                                                                              \
            "        super(singleImageData, index, pig);\n"                                                                                 \
            "        this.video = singleImageData.video;\n"                                                                                 \
            "        this.classNames.video = pig.settings.classPrefix + '-video';\n"                                                        \
            "    }\n"                                                                                                                       \
            "}\n"                                                                                                                           \
            "var #{id}_pig = new Pig(\n"                                                                                                    \
            "    #{image_data.to_json()},\n"                                                                                                \
            "    {\n"                                                                                                                       \
            "        containerId: '#{id}_pig',\n"                                                                                           \
            "        classPrefix: '#{id}_pig',\n"                                                                                           \
            "        urlForSize: function(filename, size) {\n"                                                                              \
            "            return '{{site.baseurl}}/assets/img/#{id}/' + size + '/' + filename;\n"                                            \
            "        },\n"                                                                                                                  \
            "        createProgressiveImage: (singleImageData, index, pig) => new ProgressiveImageCustom(singleImageData, index, pig),\n"   \
            "        onClickHandler: function(filename) {\n"                                                                                \
            "            window.location.href = '{{site.baseurl}}/assets/html/#{id}/' + filename + '.html';\n"                              \
            "        }\n"                                                                                                                   \
            "    }\n"                                                                                                                       \
            ").enable();\n"                                                                                                                 \
            "</script>"
        end
        
        def image_html_url(gallery_name, image_name)
            "/assets/html/#{gallery_name}/#{image_name}.html"
        end
        
        #read the image data from the _includes folder
        def get_image_data(gallery_name)
            image_data = []
            #read image_data if existing
            if File.exist?(File.join(@data_path, "#{gallery_name}.json"))
                File.open(File.join(@data_path, "#{gallery_name}.json"), 'r') { |file|
                    #get array of image data (drop 'var imageData = ' and ';')
                    image_data = JSON.parse(file.read)
                }
            end
            image_data
        end
        
        #get a list of image file names from a given path
        def get_images(path)
            patterns = ['*.jpg', '*.jpeg', '*.png'].map { |ext| File.join(path, ext) }
            Dir.glob(patterns).map { |filepath| File.basename(filepath) }
        end
        
        def get_videos(path)
            patterns = ['*.mp4', '*.mov', '*.mpg'].map { |ext| File.join(path, ext) }
            Dir.glob(patterns).map { |filepath| File.basename(filepath) }
        end
        
        def get_image(gallery_path, image_name)
            image = @@image_cache[File.join(gallery_path, image_name)]
            if image == nil
                image = MiniMagick::Image.open(File.join(gallery_path, image_name))
                @@image_cache[File.join(gallery_path, image_name)] = image
            end
            image
        end
        
        def get_image_date(gallery_path, image_name)
            image_date = nil
            begin
                image = get_image(gallery_path, image_name)
                exif_date = image.exif['DateTimeOriginal']
                if exif_date == nil
                    #no exif date, try to get from file name
                    image_date = Time.strptime(image_name, "%Y-%m-%d")
                else
                    #try to get the image date from exif
                    image_date = Time.strptime(exif_date, "%Y:%m:%d %H:%M:%S")
                end
            rescue
                #get the date from file if possible
                image_date = File.mtime(File.join(gallery_path, image_name))
            end
            image_date
        end
        
        def get_previous_url(image_data, gallery_name, image_name)
            index = image_data.index { |data| data['filename'] == image_name }
            index = index - 1
            if index < 0
                index = image_data.length - 1
            end
            image_html_url(gallery_name, image_data[index]['filename'])
        end
        
        def get_next_url(image_data, gallery_name, image_name)
            index = image_data.index { |data| data['filename'] == image_name }
            index = index + 1
            if index >= image_data.length
                index = 0
            end
            image_html_url(gallery_name, image_data[index]['filename'])
        end
        
        #create thumbnails and fullsize image assets
        def process_images(image_data, gallery_id, gallery_path, images)
            #create thumbs
            sizes = [1024, 500, 250, 100, 20]
            sizes.each { |size|
                #output path for current size
                size_out_path = File.join(@img_path, gallery_id, size.to_s)
                FileUtils.mkdir_p size_out_path unless File.exist? size_out_path
                
                #images that have already been processed for the current size
                done_images = get_images(size_out_path)
                #all images in the gallery with the ones already done taken away
                todo_images = images - done_images
                
                #function to get the source path to use for creating the given size thumbnail
                #i.e. use the 500px sized images to make the 250px versions
                source_for_size = -> (size) {
                    index = sizes.index(size)
                    source = gallery_path
                    if index != nil && index != 0
                        source = File.join(@img_path, gallery_id, sizes[index - 1].to_s)
                    end
                    source
                }
                
                #do the processing in a batch
                mog = MiniMagick::Tool::Mogrify.new
                mog.resize("x#{size}>")
                mog.sampling_factor('4:2:0')
                mog.colorspace('sRGB')
                mog.interlace('Plane')
                mog.strip()
                mog.quality('75')
                mog.path(size_out_path)
                source_path = source_for_size.call(size)
                todo_images.each { |todo| mog << File.join(source_path, todo) }
                mog.call
            }
        end
        
        def process_videos(gallery, videos)
            video_out_path = File.join(@img_path, gallery.name, "video")
            FileUtils.mkdir_p video_out_path unless File.exist? video_out_path
            
            done_videos = get_videos(video_out_path)
            todo_videos = videos - done_videos
            
            todo_videos.each { |todo| FileUtils.cp(File.join(gallery.path, todo),video_out_path) }
            
            mog = MiniMagick::Tool::Mogrify.new
            mog.format('jpg')
            #take a screenshot of first frame
            todo_videos.each { |todo| mog << File.join(gallery.path, todo) + "[0]" }
            mog.call
        end
        
        #create full size html page for a given image
        def process_image(image_data, gallery_id, gallery_path, image_name)
            full_size_html_path = File.join(@html_path, gallery_id, image_name + ".html")
            #create full size html if it doesn't exist
            if not File.exist? full_size_html_path
                #get image date
                image_date = get_image_date(gallery_path, image_name)
                #create full size html text
                full_size_html = full_size_html(gallery_id, image_name, image_date, 
                                                get_previous_url(image_data, gallery_id, image_name), 
                                                get_next_url(image_data, gallery_id, image_name))
                File.open(full_size_html_path, 'w') { |file| 
                    file.write(full_size_html) 
                }
            end
        end
        
        def get_paths
            @assets_path = File.join(@site.source, "assets")
            @js_path = File.join(@assets_path, "js")
            @data_path = File.join(@site.source, "_data")
            @img_path = File.join(@assets_path, "img")
            @html_path = File.join(@assets_path, "html")
            @includes_path = File.join(@site.source, "_includes")
        end
        
        def get_galleries
            galleries = []
            config_galleries = Jekyll.configuration({})['galleries']
            if config_galleries != nil
                config_galleries.each do |gallery|
                    full_path = File.join(@site.source, gallery['path'])
                    if File.directory?(full_path)
                        galleries << SourceGallery.new({path:full_path, name:gallery['name'], create_html:gallery['create_html']})
                    end
                end
            else
                default_gallery_path = File.join(@site.source, 'gallery')
                if File.directory?(default_gallery_path)
                    galleries << SourceGallery.new({path:default_gallery_path, name:'gallery', create_html: true})
                end
            end
            galleries
        end
        
        def make_output_paths
            FileUtils.mkdir_p @assets_path unless File.exist? @assets_path
            FileUtils.mkdir_p @js_path unless File.exist? @js_path
            FileUtils.mkdir_p @img_path unless File.exist? @img_path
            FileUtils.mkdir_p @html_path unless File.exist? @html_path
            FileUtils.mkdir_p @includes_path unless File.exist? @includes_path
            FileUtils.mkdir_p @data_path unless File.exist? @data_path
        end
        
        def augment_image_data(gallery, image_data, images, videos) 
            images.each do |image_name|
                #append data to image_data array if it's not already there
                if not image_data.any? { |data| data['filename'] == image_name }
                    basename = File.basename(image_name, File.extname(image_name))
                    video = videos.grep(/(#{basename})\.(mpg|mov|mp4)/).first
                    #get image date
                    image_date = get_image_date(gallery.path, image_name)
                    image = get_image(gallery.path, image_name)
                    image_data << 
                        {
                        'datetime' => image_date.to_s,
                        'filename' => image_name,
                        'aspectRatio' => image.width.to_f / image.height,
                        'video' => video
                        }
                end
            end
        end
        
        def generate(site)
            @site = site
            get_paths()
            make_output_paths()
            galleries = get_galleries()
            galleries.each do |gallery|
                
                #make gallery specific html and image output paths
                html_output_path = File.join(@html_path, gallery.name)
                if gallery.create_html
                  FileUtils.mkdir_p html_output_path unless File.exist? html_output_path
                end
                img_output_path = File.join(@img_path, gallery.name)
                FileUtils.mkdir_p img_output_path unless File.exist? img_output_path
                
                #write pig.min.js to js path
                if not File.exist? File.join(@js_path, 'pig.min.js')
                    File.open(File.join(@js_path, 'pig.min.js'), 'w') { |file| file.write(@@pig_min_js) }
                end
                #first get screenshot from video
                videos = get_videos(gallery.path)
                process_videos(gallery, videos)
                
                #get image data from _data
                image_data = get_image_data(gallery.name)
                old_image_data = image_data.clone
                
                #get images from gallery
                images = get_images(gallery.path)
                
                #add any additional images to image_data
                augment_image_data(gallery, image_data, images, videos)
                
                #sort image data
                image_data = image_data.sort_by { |data| data['datetime'] }
                
                #create thumbs
                process_images(image_data, gallery.name, gallery.path, images)
                images.each do |image_name|
                    if gallery.create_html
                        #create html assets for each image
                        process_image(image_data, gallery.name, gallery.path, image_name)
                    end
                end
                
                if image_data != old_image_data
                    #write image_data
                    File.open(File.join(@data_path, "#{gallery.name}.json"), 'w') { |file|
                        file.write(image_data.to_json)
                    }
                    
                    #save this gallery's includable content
                    File.open(File.join(@includes_path, "#{gallery.name}.html"), 'w') { |file|
                        file.write(gallery_html(gallery.name, image_data))
                    }
                end
            end
        end
    end
end
