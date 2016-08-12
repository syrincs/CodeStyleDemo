# encoding: utf-8
class CkeditorsController < ApplicationController
  def upload
    input = params[:upload]
    path = File.join("system", "ckeditor", "#{SecureRandom.uuid}.#{File.extname(input.original_filename).downcase}")
    File.open(Rails.root.join("public", path), "wb"){ |file| file.write(input.read) }

    @func_num = params["CKEditorFuncNum"].to_i
    @message = ""
    @url = "/#{path}"
    render :layout => false
  end
end
