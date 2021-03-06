class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :register_success]

  before_action :is_login?, only: [:user_center, :com_profile, :com_course, :com_employee, :emp_profile, :emp_course, :emp_exam]

  layout 'client/indexpages/register-layout', only: [:forget_password, :register_choose, :register_company, :register_employee, :register_success, :register_suspend]

  layout 'client/usercenter/usercenter', only: [:user_center, :com_course, :com_employee, :com_profile, :emp_course, :emp_exam, :emp_profile]

  # GET /register_choose
  def register_choose
  end

  # GET /register_employee
  def register_employee
    @user = User.new
  end

  # GET /register_company
  def register_company
    @user = User.new
    @company = Company.new
  end

  # 注册成功页面
  def register_success
  end

  #注册后待审核页面
  def register_suspend
  end

  # POST /register_employee
  def create_employee
    @user = User.new(user_params)
    # 查询邀请码
    invite_code = params[:user][:invite_code]

    # 邀请码存在且没有被使用
    if (invite_code && (code = InvitationCode.find_by_code(invite_code)) && !code.used?)
      @user.role_id = 1
      @user.company_id = code.company_id

      if @user.save
        flash.now[:success] = '注册成功'
        code.update_attribute(:used, true)
        code.update_attribute(:invited_at, Time.zone.now)

        render 'users/register_success'
      else
        flash.now[:error] = '注册失败'

        render :register_employee
      end
    else
      flash.now[:invite_code_error] = '查无此邀请码'

      render :register_employee
    end
  end


  # 忘记密码页面
  def forget_password
  end

  # 生成邮箱验证码
  def generate_email_verify_code
    email = params[:email]
    verify_code = User.generate_verify_code
    UserMailer.reset_password(email, verify_code).deliver_now
    session[:reset_password_verify_code] = verify_code

    render :json => {status: '200'}
  end

  def reset_password
    email, verify_code, password, password_confirmation = params[:email], params[:verifycode], params[:password], params[:password_confirmation]
    puts session[:reset_password_verify_code] == verify_code

    if session[:reset_password_verify_code] == verify_code
      user = User.find_by_email(email)

      if user.update({
                         :password => password,
                         :password_confirmation => password_confirmation
                     })

        redirect_to '/login'
      else
        flash.now[:reset_password_error] = '修改密码失败'

        render :forget_password
      end
    else
      flash.now[:reset_password_error] = '验证码错误'

      render :forget_password
    end
  end

  # 用户个人中心
  def user_center
    @page_tag = 'user_center'
  end

  # 公司-管理页面
  def com_profile
    @page_tag = 'com_profile'
  end

  # 公司-员工管理页面
  def com_employee
    @page_tag = 'com_employee'

    user = current_user
    company = user.company

    # 员工部分
    @employees_count = company.users.count
    @com_count= company.users.where(role_id: 2).count
    @employees = company.users

    # 邀请码部分
    @invite_codes = company.invitation_codes.where(used: false)

  end

  # 公司-课程管理页面
  def com_course
    @page_tag = 'com_course'

    lessons = Lesson.where({:company_id => current_user.company_id})
    @course_sys_json = []

    lessons.each do |lesson|
      if lesson.state == 1
        state_str = 'wait'
      elsif lesson.state == 2
        state_str = 'verified'
      elsif lesson.state == 3
        state_str = 'dev'
      else
        state_str = 'production'
      end
      @course_sys_json.push({
                                'course_sys_id': lesson.id,
                                'title': lesson.lesson_name,
                                'desc': lesson.lesson_desc,
                                'cover': lesson.lesson_cover,
                                'state': state_str,
                                'version': lesson.version,
                                'preview': lesson.preview,
                                'preview_url': lesson.preview_url
                            })
    end
  end

  # 用户-个人资料页面
  def emp_profile
    @page_tag = "emp_profile"
  end

  # 用户-我的课程页面
  def emp_course
    @page_tag = "emp_course"

    user = current_user
    @lessons = user.lessons
    courses = user.user_courses
    @total_courses_count = courses.size
    @course_finished_count = courses.where({'is_finished': true}).size
    @current_user_id = user.id
  end

  # 用户-我的考核页面
  def emp_exam
    @page_tag = "emp_exam"

    user = current_user
    @lessons = user.lessons
    courses = user.user_courses
    # 多少个课程
    @total_courses_count = courses.size
    # 已经完成的考核有多少个
    @course_finished_count = courses.where.not({'score': nil}).size
    @current_user_id = user.id
  end


  def manage_emp
    action_name = params[:do]
    emp_id = params[:emp_id]

    user = User.find(emp_id)

    case action_name
      when 'dismiss'
        user.update_attribute(:company_id, nil)
      when 'upgrade'
        user.update_attribute(:role_id, 2)
      when 'downgrade'
        user.update_attribute(:role_id, 1)
    end

    render :json => {
        :status => 'success',
        :err => nil
    }
  end

  def update_attr
    user = current_user
    user.update_columns({
                            :username => params[:user][:username],
                            :email => params[:user][:email],
                            :phone => params[:user][:phone]
                        })

    redirect_to '/users/emp-profile'
  end


  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)
    # 根据页面决定是哪种身注册方式
    @user.role_id = 1

    respond_to do |format|
      if @user.save
        # 发送邮件，等待激活
        UserMailer.account_activation(@user).deliver_now
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to emp_profile, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render emp_profile }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation, :invite_code, :phone)
  end

end
