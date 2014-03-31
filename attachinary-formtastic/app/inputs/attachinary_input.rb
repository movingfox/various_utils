class AttachinaryInput
  include Formtastic::Inputs::Base

  def input_html_options
    options = {}
    options[:html] = {}
    options[:html][:accept]= "raw" # "image/jpeg,image/png,image/gif"
    options[:html][:class] = "attachinary-input"
    model_options = {}
    model_options[:files] = @files

    data_attachinary = (@model_options.merge(model_options)).to_json
    options[:html][:multiple] = true unless @model_options[:single]
    options[:html]["data-attachinary"] = data_attachinary

    if !options[:html][:accept] && accepted_types = @model_options[:accept]
      accept = accepted_types.map do |type|
        MIME::Types.type_for(type.to_s)[0]
      end.compact
      options[:html][:accept] = accept.join(',') unless accept.empty?
    end

    options[:cloudinary] ||= {}
    options[:cloudinary][:tags] ||= []
    options[:cloudinary][:tags]<< "#{Rails.env}_env"
    options[:cloudinary][:tags]<< Attachinary::TMPTAG
    options[:cloudinary][:tags].uniq!
    cloudinary_upload_url = Cloudinary::Utils.cloudinary_api_url("upload",
        {:resource_type=>:auto}.merge(options[:cloudinary]))
    api_key = options[:cloudinary][:api_key] || Cloudinary.config.api_key || raise("Must supply api_key")
    api_secret = options[:cloudinary][:api_secret] || Cloudinary.config.api_secret || raise("Must supply api_secret")

    cloudinary_params = Cloudinary::Uploader.build_upload_params(options[:cloudinary])
    cloudinary_params[:callback] = "http://localhost:3000/attachinary/cors"
    cloudinary_params[:signature] = Cloudinary::Utils.api_sign_request(cloudinary_params, api_secret)
    cloudinary_params[:api_key] = api_key
    data_form_data = cloudinary_params.reject{ |k, v| v.blank? }.to_json
    options[:html]["data-form-data"] = data_form_data
    data_url = "https://api.cloudinary.com/v1_1/vasilakisfil/auto/upload"
    options[:html]["data-url"] = data_url
    super.merge(options[:html])

  end

  def to_html
    @model_options = self.object.send("#{method}_metadata")
    @files = [self.object.send(method)].compact.flatten
    builder.file_field(method, input_html_options)
  end
end
