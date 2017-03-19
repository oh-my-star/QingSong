class SysController < ApplicationController

  layout false

  def course_sys
    @course_sys_name = params[:sys_name]
    @company_id = params[:company_id]
    @json_filename = params[:json_filename]
    @course_sort = params[:course_sort]
    @type = params[:type]
    @course_id = params[:course_id]

    @lesson_sys = Lesson.find_by_lesson_name @course_sys_name
    @course_json_content = get_file_content @company_id, @course_sys_name, @json_filename
  end

  # 如果请求类型(type) 是 page ,那么从课程系统的 pages 文件夹下获取filename所指定的文件内容,
  # 如果是 part ,则从 parts 文件夹下获取filename所指定文件的内容
  def load_course
    type = params[:type]
    filename = params[:filename]
    company_id = params[:company_id]
    course_sys_name = params[:course_sys_name]
    html_content = read_course_file company_id, course_sys_name, filename, type
    render html: html_content.html_safe
  end

  # public/course-sys/2/preview/JinSanQi/assets/img/login/logo.png
  def load_file
    file_url = params[:file_url]
    type = params[:type]
    filename = file_url.split('/')[-1]
    if type == 'css'
      file_type = 'text/css'
      send_file "public/course_sys/#{file_url}.#{type}", filename: "#{filename}", type: "#{file_type}"
    else
      send_file "public/course_sys/#{file_url}.#{type}", filename: "#{filename}"
    end
  end

  def save_unfinished_page
    html_content = params[:html]
    course_id = params[:course_file_id]
    step = params[:step]
    action = params[:action]
    progress = params[:progress]

    if UserCourse.save({
                           :html_file => html_content,
                           :course_id => course_id,
                           :step => step,
                           :action => action,
                           :progress => progress
                       })
      render :json => {status: 'success'}
    else
      render :json => {status: 'failed'}
    end
  end

  def load_unfinished_page
    course_id = params[:course_file_id]
    @user_course = UserCourse.find_by({
                                          :course_id => course_id,
                                          :user_id => current_user.id
                                      })
    render :json => {
        :html => @user_course.html_file,
        :progress => @user_course.progress,
        :action => @user_course.action,
        :step => @user_course.step
    }
  end

  def send_score
    course_id = params[:course_file_id]
    score = params[:score]

    user_course = UserCourse.find_by({
                                         :course_id => course_id,
                                         :user_id => current_user.id
                                     })

    user_course.update(:score => score)
  end

end