Rails.application.routes.draw do
  
  root to: "ptkms_projects#index"
  
  get  '/login', to: 'ptkms_login#new'
  post '/login', to: 'ptkms_login#create'
  delete '/logout', to: 'ptkms_login#destroy'
    
  resources :ptkms_projects
  resources :ptkms_tasks
  resources :ptkms_knowledges  
  
  get     '/ptkms_task_commnets/:id/edit', to: 'ptkms_task_commnets#edit',    as: 'edit_ptkms_task_commnet'  
  patch   '/ptkms_task_commnets/:id',      to: 'ptkms_task_commnets#update'
  put     '/ptkms_task_commnets/:id',      to: 'ptkms_task_commnets#update'  
  delete  '/ptkms_task_commnets/:id',      to: 'ptkms_task_commnets#destroy', as: 'ptkms_task_commnet'
  
  get     '/ptkms_knowledge_commnets/:id/edit', to: 'ptkms_knowledge_commnets#edit',    as: 'edit_ptkms_knowledge_commnet'  
  patch   '/ptkms_knowledge_commnets/:id',      to: 'ptkms_knowledge_commnets#update'
  put     '/ptkms_knowledge_commnets/:id',      to: 'ptkms_knowledge_commnets#update'  
  delete  '/ptkms_knowledge_commnets/:id',      to: 'ptkms_knowledge_commnets#destroy', as: 'ptkms_knowledge_commnet'

end
