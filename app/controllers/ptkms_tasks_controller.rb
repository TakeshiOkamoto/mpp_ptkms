class PtkmsTasksController < ApplicationController
  before_action :set_ptkms_task, only: [:show, :edit, :update, :destroy]
  
  before_action :ptkms_get_priority_combobox  
  helper_method :common_convert_nbsp, :ptkms_get_priority_from_id, :ptkms_get_name_from_data
  
  # GET /ptkms_tasks
  def index  
    if params[:project_id].present?
      # 通常時
      @ptkms_project =  PtkmsProject.where(id: params[:project_id])
    else
      # 検索時
      if params[:q].present?
        @ptkms_project =  PtkmsProject.where(id: params[:q][:project_id])
      else
        redirect_to ptkms_projects_path
        return
      end   
    end
         
    if @ptkms_project.present?    
      if params[:q].blank?
        # 初期表示は非表示プロジェクトは表示しない
        @q = PtkmsTask.where(project_id: @ptkms_project[0].id, show: true).order(priority: "ASC",updated_at: "DESC")
      else
        @q = PtkmsTask.where(project_id: @ptkms_project[0].id).order(priority: "ASC",updated_at: "DESC")
      end  
      
      # 空白除去 ※全角空白を半角空白に変換含む
      if params[:q].present?
        params[:q][:title_cont]= common_trim(params[:q][:title_cont])
      end  
      
      @q = @q.ransack(params[:q])  
      @ptkms_tasks = @q.result(distinct: true).page(params[:page]).per(25)  
      
      # 登録者、最終発言者の配列を取得する
      @db_data = PtkmsTask.find_by_sql([' SELECT ' +
                                       '  ptkms_tasks.id,' +
                                       '  (SELECT ptkms_task_commnets.name FROM ptkms_task_commnets WHERE ptkms_task_commnets.task_id = ptkms_tasks.id  ORDER BY ptkms_task_commnets.id ASC LIMIT 1) as name1,' +
                                       '  (SELECT ptkms_task_commnets.name FROM ptkms_task_commnets WHERE ptkms_task_commnets.task_id = ptkms_tasks.id  ORDER BY ptkms_task_commnets.id DESC LIMIT 1) as name2,' +
                                       '  (SELECT count(id) FROM ptkms_task_commnets WHERE ptkms_task_commnets.task_id = ptkms_tasks.id) as cnt ' +
                                       ' FROM ptkms_tasks  ' +
                                       ' WHERE ' +
                                       '  ptkms_tasks.project_id = ?' +
                                       ' ORDER BY' +                                    
                                       '  ptkms_tasks.priority ASC',
                                       @ptkms_project[0].id.to_s]) 
                                            
    else
      redirect_to ptkms_projects_path
    end           
  end

  # GET /ptkms_tasks/1
  def show
    @ptkms_project =  PtkmsProject.where(id: @ptkms_task.project_id)
    @ptkms_task_commnets = PtkmsTaskCommnet.where(task_id: @ptkms_task.id)
   
    # 新規コメント用
    @ptkms_task_commnet = PtkmsTaskCommnet.new
    @ptkms_task_commnet.task_id = @ptkms_task.id
    @ptkms_task_commnet.name = session[:ptkms_task_commnet_name]  
    @ptkms_task_commnet.body = session[:ptkms_task_commnet_body]  
  end

  # GET /ptkms_tasks/new
  def new  
    @ptkms_project =  PtkmsProject.where(id: params[:project_id])
    
    # 不正処理
    if @ptkms_project.present?
      @ptkms_task = PtkmsTask.new
      @ptkms_task.project_id = params[:project_id] 

      @ptkms_task_commnet = PtkmsTaskCommnet.new      
    else
      redirect_to ptkms_projects_path
    end   
  end

  # GET /ptkms_tasks/1/edit
  def edit
    
    # 管理者権限の確認
    if(!(ptkms_current_user && ptkms_current_user.admin?))
      redirect_to ptkms_projects_path
      return
    end
      
    @ptkms_project =  PtkmsProject.where(id: @ptkms_task.project_id)      
  end

  # POST /ptkms_tasks
  def create
    
    # *** コメントの書き込み
    if params[:ptkms_task_commnet].present?
    
      @ptkms_task_commnet = PtkmsTaskCommnet.new  
      @ptkms_task_commnet.task_id = params[:ptkms_task_commnet][:task_id]  
      @ptkms_task_commnet.name = common_trim(params[:ptkms_task_commnet][:name])
      @ptkms_task_commnet.body = params[:ptkms_task_commnet][:body]
      @ptkms_task_commnet.attachments = params[:ptkms_task_commnet][:attachments]
      
      if @ptkms_task_commnet.valid?
        ActiveRecord::Base.transaction do 
          @ptkms_task_commnet.save!
        
          # 最終更新日
          ptkms_task = PtkmsTask.where(id: @ptkms_task_commnet.task_id)[0]
          ptkms_task.updated_at = Time.zone.now
          ptkms_task.save!
                  
          ptkms_task = PtkmsTask.where(id: @ptkms_task_commnet.task_id)[0]
          redirect_to ptkms_tasks_path(project_id: ptkms_task.project_id), notice: '返信しました。'
        end  
      else                               
        session[:ptkms_task_commnet_name] = @ptkms_task_commnet.name
        session[:ptkms_task_commnet_body] = @ptkms_task_commnet.body
        session[:ptkms_task_commnet_attachments] = @ptkms_task_commnet.attachments        
        session[:ptkms_task_commnet_errors] = @ptkms_task_commnet.errors.full_messages  
        
        redirect_to ptkms_task_path(id: @ptkms_task_commnet.task_id)
      end  
      
    # *** 通常の処理  
    else     
      @ptkms_task = PtkmsTask.new(ptkms_task_params)    
      @ptkms_project =  PtkmsProject.where(id: @ptkms_task.project_id)
      
      # 不正処理
      if @ptkms_project.blank?
        redirect_to ptkms_projects_path
        return
      end
      
      # 文字列の整形
      @ptkms_task.title= common_trim(@ptkms_task.title)
      @ptkms_task_commnet = PtkmsTaskCommnet.new      
      @ptkms_task_commnet.name = common_trim(params[:ptkms_task][:ptkms_task_commnet][:name])
      @ptkms_task_commnet.body = params[:ptkms_task][:ptkms_task_commnet][:body]    
      @ptkms_task_commnet.attachments = params[:ptkms_task][:ptkms_task_commnet][:attachments]  
       
      # バリデーションの実行
      @ptkms_task.valid?
      @ptkms_task_commnet.valid?    
              
      # エラーならば、エラーを表示する
      if(!@ptkms_task.valid? || !@ptkms_task_commnet.valid?)
        render :new 
        return    
      end   
      
      # トランザクション    
      ActiveRecord::Base.transaction do
        @ptkms_task.save!
        @ptkms_task_commnet.task_id = @ptkms_task.id
        @ptkms_task_commnet.save!
        redirect_to ptkms_tasks_path(project_id: @ptkms_task.project_id), notice: '登録しました。'
      end
    end  
  end

  # PATCH/PUT /ptkms_tasks/1
  def update    
  
    # 管理者権限の確認
    if(!(ptkms_current_user && ptkms_current_user.admin?))
      redirect_to ptkms_projects_path
      return
    end
      
    @ptkms_project =  PtkmsProject.where(id: ptkms_task_params[:project_id])
  
    # 不正処理
    if @ptkms_project.blank?
      redirect_to ptkms_projects_path
      return
    end  
    
    respond_to do |format|
      @ptkms_task.title = common_trim(ptkms_task_params[:title])
      @ptkms_task.priority = ptkms_task_params[:priority]
      @ptkms_task.show = ptkms_task_params[:show] 
      @ptkms_task.updated_at = Time.zone.now 
      if @ptkms_task.save
        format.html { redirect_to ptkms_tasks_path(project_id: @ptkms_task.project_id), notice: '更新しました。' }
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /ptkms_tasks/1
  def destroy    
  
    # 管理者権限の確認
    if(!(ptkms_current_user && ptkms_current_user.admin?))
      redirect_to ptkms_projects_path
      return
    end
      
    # トランザクション
    ActiveRecord::Base.transaction do
      @ptkms_task.destroy!
      ptkms_task_commnets = PtkmsTaskCommnet.where(task_id: @ptkms_task.id)       
      ptkms_task_commnets.each { |a|
        a.destroy! 
      }       
      redirect_to ptkms_tasks_path(project_id: @ptkms_task.project_id), alert: "「#{@ptkms_task.title}」を削除しました。"
    end 
  end

# -----------------------------
#  private
# -----------------------------  
  private
    def set_ptkms_task
      @ptkms_task = PtkmsTask.find(params[:id])
      
      # 文字列の整形
      @ptkms_task.title= common_trim(@ptkms_task.title)
    end

    def ptkms_task_params
      params.require(:ptkms_task).permit(:project_id, :title, :priority, :show)
    end   
    
# -----------------------------
#  ヘルパーメソッド
# -----------------------------
  
  # コンボボックス用 - 優先度
  def ptkms_get_priority_combobox()
    @ptkms_priority_list = []
    @ptkms_priority_list.push(['緊急',1])
    @ptkms_priority_list.push(['告知',2])
    @ptkms_priority_list.push(['高',3])
    @ptkms_priority_list.push(['中',4])
    @ptkms_priority_list.push(['低',5])
  end  
      
  # idから優先度を取得する 
  def ptkms_get_priority_from_id(id)
     @ptkms_priority_list.each_with_index do |obj,i|
       if(obj[1] == id)
         return obj[0]
       end  
     end
     return "";
  end      
end
