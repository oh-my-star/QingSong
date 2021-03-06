Rails.application.routes.draw do

  # 后台管理系统的控制器
  namespace :admin do
    root 'users#index'
    get 'sessions/create'
    get 'login' => 'login_and_register#login' #登录页
    post 'login' => 'sessions#create' #登录操作
    get 'logout' => 'sessions#destroy' #注销
    get 'register' => 'login_and_register#register' #注册页
    post 'register' => 'admin_users#create'
    get 'notices' => 'notices#index'
    get 'company/active/:company_id' => 'companies#active'
    resources :users
    resources :lessons
    resources :companies
    end

  root 'static_pages#index'
  get 'login' => 'sessions#login'
  post 'login' => 'sessions#create'
  get 'logout' => 'sessions#destroy'
  get 'register-choose' => 'users#register_choose'
  get 'register-success' => 'users#register_success'
  get 'register-suspend' => 'users#register_suspend'
  get 'register-employee' => 'users#register_employee'
  post 'register-employee' => 'users#create_employee'
  get 'register-company' => 'users#register_company'
  post 'register-company' => 'companies#create_company'
  get '/company/send-verify-code' => 'companies#send_verify_code'
  get 'forget-password' => 'users#forget_password'
  get 'send-email-verify-code' => 'users#generate_email_verify_code'
  post 'reset-password' => 'users#reset_password'

  #后台页面
  get '/users/user-center' => 'users#user_center'
  get '/users/com-profile' => 'users#com_profile'
  get '/users/com-employee' => 'users#com_employee'
  get '/users/com-course' => 'users#com_course'
  get '/users/emp-profile' => 'users#emp_profile'
  get '/users/emp-course' => 'users#emp_course'
  get '/users/emp-exam' => 'users#emp_exam'
  get '/get-invite-code' => 'invitation_codes#generate_invitation_code'
  get '/users/manage-emp' => 'users#manage_emp'
  patch '/companies/update-attr' => 'companies#update_attr'
  post '/verify-invite-code' => 'invitation_codes#verify_invitation_code'
  patch '/users/update-attr' => 'users#update_attr'

  # sys
  get '/course-sys/:sys_name/:json_filename/:type/:status/:company_id/:course_id/:course_sort' => 'sys#course_sys'
  get '/sys/load-course' => 'sys#load_course'
  get '/public/course-sys/*file_url.*type' => 'sys#load_file'

  post '/sys/save-unfinished-page' => 'sys#save_unfinished_page'
  post '/sys/load-unfinished-page' => 'sys#load_unfinished_page'
  get '/sys/send-score' => 'sys#send_score'
  post '/sys/apply-new-lesson-system' => 'sys#apply_new_course_system'
  get '/sys/get-lesson-users' => 'sys#get_lesson_users'
  post 'sys/send-distribute' => 'sys#send_distribute'
  post '/sys/publish-preview-system' => 'sys#public_preview_system'

  # 注意resources 后面是有个s的，没有加s生成的url不一样
  resources :scores
  resources :roles
  resources :lessons
  # resources :users
  resources :account_activations, only: [:edit]
  resources :invitation_codes
  # resources :companies

end