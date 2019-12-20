class PtkmsLoginController < ApplicationController

  skip_before_action:ptkms_login?
  
  def new
    # ログイン済み    
    if ptkms_current_user
      redirect_to ptkms_projects_path
    end     
  end
  
  def create
    user = PtkmsUser.find_by(name: ptkms_login_params[:name])
 
    # パスワードの認証
    if user&.authenticate(ptkms_login_params[:password])
      session[:ptkms_user_id] = user.id
      session[:ptkms_user_name] = user.name
      if user.admin
        redirect_to ptkms_projects_path, notice: '管理者でログインしました。'
      else
        redirect_to ptkms_projects_path, notice: 'ログインしました。'
      end  
    else
      redirect_to login_path, alert: '名前またはパスワードが違います。'
    end
  end
    
  def destroy
    reset_session
    redirect_to ptkms_projects_path, notice: 'ログアウトしました。'      
  end
    
  private
 
  def ptkms_login_params
    params.require(:login).permit(:name, :password)
  end    
end
