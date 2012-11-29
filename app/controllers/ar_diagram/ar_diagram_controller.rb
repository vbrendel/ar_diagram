module ArDiagram
  class ArDiagramController < ApplicationController
    before_filter :set_module
    helper_method :css_id

    # Force load of all models
    ActiveSupport::Dependencies.autoload_paths.each do |path|
      if /\/models$/.match(path)
        Dir.glob(File.join(path, "**", "*.rb")).each do |file|
          require_dependency file
        end
      end
    end

    def index
      @views = View.all
    end

    def show
      @view = View.find(params[:id])
      @views = View.all
      @tables = available_tables @db_module

      if params[:print]
        render "show", :layout => "ar_diagram/ar_diagram_print"
      else
        render
      end
    end

    def create
      @view = View.new(params[:view])
      @view.zoom = 1
      @view.save
      redirect_to(ar_diagram_path(@view.id))
    end

    def update
      @view = View.find(params[:id])
      @view.tables.update_all(:archive => true)
      params[:tables].each do |name, table|
        t = @view.tables.find_or_initialize_by_name(model_name(name))
        t.archive = false
        t.position_x = table["x"]
        t.position_y = table["y"]
        t.save
      end
      @view.zoom = params[:zoom]
      @view.save
      @success = true
    end

    def destroy
      @view = View.find(params[:id])
      @view.destroy
      redirect_to ar_diagram_index_path
    end

    def add_table
      model = params[:model].camelize
      @table = Table.new({:name => model})
    end

    protected

    def set_module
      unless params[:set_module].nil?
        @db_module = eval(params[:set_module])
        session[:ar_diagram_module] = @db_module
      else
        @db_module = session[:ar_diagram_module] || Module
      end
    end

    def available_tables(m)
      prefix = ""
      prefix = "#{m.name}::" unless m.name == "Module"
      all_tables = [].tap do |array|
        m.constants.select do |constant_name|
          class_name = "#{prefix}#{constant_name.to_s}"
          unless [:VERSION, :Base, :Engine, :View, :Label, :Table, :Field].include?(constant_name)
            begin
              constant = eval class_name
              if not constant.nil? and constant.is_a? Class and constant.superclass == ActiveRecord::Base
                array << class_name
              end
            rescue
            end
          end
        end
      end
      (all_tables).sort
    end

    def css_id table_name
      table_name.underscore.gsub(/\//, "-")
    end

    def model_name css_id
      css_id.gsub(/\-/, "/").camelize
    end
  end
end
