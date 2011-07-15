Yatodo::Application.routes.draw do
  match 'faq' => 'high_voltage/pages#show', :id => 'faq', :as => :faq
  match '*jid/*tag/' => 'list#notes'
  match '*jid/' => 'list#tags'
  root :to => 'high_voltage/pages#show', :id => 'home'
end
