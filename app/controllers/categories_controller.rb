# encoding: utf-8
class CategoriesController < ApplicationController
  layout :determine_layout
  
  load_and_authorize_resource
  before_filter :save_brandsmodells, only: :show

  def index
    @categories = @categories.roots
   end

  def show
    @subcategories = @category.children.order(:position)
    @offers = @category.offers.approved.ordered(order).page(params[:offers_page]).per_page(12)
  end

  def create
    if @category.save
      redirect_to_parent_or_index notice: _("Category created!")
    else
      render "new"
    end
  end

  def update
    if @category.update_attributes(params[:category])
      redirect_to_parent_or_index notice: _("Category updated!")
    else
      render "edit"
    end
  end

  def destroy
    @category.destroy
    redirect_to_parent_or_index notice: _("Category deleted!")
  end

  protected

  def save_brandsmodells
    brandsmodells_file = Rails.root.join("public", "brandsmodells.json")
    if File.exist?(brandsmodells_file)
      # regenerate json file after 7 days
      file_too_old = (Time.now - File.stat(brandsmodells_file).mtime).to_i / 86400.0 >= 7
      write_brandsmodells_to_json(brandsmodells_file) if file_too_old
    else
      write_brandsmodells_to_json(brandsmodells_file)
    end
  end

  def write_brandsmodells_to_json(file)
    brandsmodells = Brand.joins(:modells).select("DISTINCT modells.id AS modell_id", "brands.name AS brandname", "modells.name AS modellname")
    File.open(file, "w") do |f|
      f.puts brandsmodells.to_json
    end
  end

  def redirect_to_parent_or_index(options)
    redirect_to categories_path(root_id: @category.parent_id), options
  end

  def category_params
    params.require(:category).permit(:name, :position, :parent_id, :descriptiongroup_id)
  end
end
