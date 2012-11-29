ArDiagram::Engine.routes.draw do
  resources :ar_diagram, :path => "", :path_names => { :new => "" } do
    member do
      post :add_table, :format => :js, :as => "add_table"
    end
  end
end
