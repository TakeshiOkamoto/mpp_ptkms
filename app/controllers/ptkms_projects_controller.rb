class PtkmsProjectsController < ApplicationController
  before_action :set_ptkms_project, only: [:show, :edit, :update, :destroy]
  
  helper_method :common_convert_nbsp, :ptkms_get_count_from_data
  
  # GET /ptkms_projects
  def index  
  
    if params[:q].blank?
      # 初期表示は非表示プロジェクトは表示しない
      @q = PtkmsProject.where(show: true).order(p_end: "DESC",updated_at: "DESC")
    else
      @q = PtkmsProject.order(p_end: "DESC",updated_at: "DESC")
    end  
    
    # 空白除去 ※全角空白を半角空白に変換含む
    if params[:q].present?
      params[:q][:name_cont]= common_trim(params[:q][:name_cont])
    end  
    
    @q = @q.ransack(params[:q])  
    @ptkms_projects = @q.result(distinct: true).page(params[:page]).per(25)
    
    # タスク/ナレッジ数を取得する
    sql = " SELECT " + 
          "   id,task,knowledge " +
          " FROM  " +
          "   (SELECT " +
          "      ptkms_projects.id as id,count(ptkms_tasks.project_id) as task " +
          "    FROM  ptkms_projects " +
          "    LEFT JOIN  " +
          "      ptkms_tasks ON ptkms_projects.id = ptkms_tasks.project_id " +
          "    GROUP BY " +
          "      ptkms_projects.id " +
          "    ORDER BY " +
          "     ptkms_projects.id ASC " +
          "   ) AS X   " +
          " INNER JOIN  " +
          "   (SELECT " +
          "      ptkms_projects.id as dmy,count(ptkms_knowledges.project_id) as knowledge " +
          "    FROM  ptkms_projects " +
          "    LEFT JOIN  " +
          "      ptkms_knowledges ON ptkms_projects.id = ptkms_knowledges.project_id  " +
          "    GROUP BY " +
          "      ptkms_projects.id " +
          "    ORDER BY " +
          "      ptkms_projects.id ASC  " +
          "   ) AS Z " +
          " ON X.id = Z.dmy "
    @db_data = PtkmsProject.find_by_sql([sql])           
  end

  # GET /ptkms_projects/1
  def show
  end

  # GET /ptkms_projects/new
  def new
  
    # 管理者権限の確認
    if(!(ptkms_current_user && ptkms_current_user.admin?))
      redirect_to ptkms_projects_path
      return
    end
      
    @ptkms_project = PtkmsProject.new
  end

  # GET /ptkms_projects/1/edit
  def edit
  
    # 管理者権限の確認
    if(!(ptkms_current_user && ptkms_current_user.admin?))
      redirect_to ptkms_projects_path
      return
    end  
    
  end

  # POST /ptkms_projects
  def create
  
    # 管理者権限の確認
    if(!(ptkms_current_user && ptkms_current_user.admin?))
      redirect_to ptkms_projects_path
      return
    end
      
    @ptkms_project = PtkmsProject.new(ptkms_project_params)

    # 文字列の整形
    ptkms_project_formatting()    
      
    respond_to do |format|
      begin
        if @ptkms_project.save
          format.html { redirect_to ptkms_projects_path, notice: '登録しました。' }
        else
          format.html { render :new }
        end
      rescue => error 
         redirect_to ptkms_projects_path, alert: '不正な入力が発生しました。' 
         return
      end          
    end
  end

  # PATCH/PUT /ptkms_projects/1
   def update
   
    # 管理者権限の確認
    if(!(ptkms_current_user && ptkms_current_user.admin?))
      redirect_to ptkms_projects_path
      return
    end
       
    respond_to do |format|
      begin
        @ptkms_project.name = common_trim(ptkms_project_params[:name])
        @ptkms_project.client_name = common_trim(ptkms_project_params[:client_name])
        @ptkms_project.p_start = ptkms_project_params[:p_start]
        @ptkms_project.p_end = ptkms_project_params[:p_end]
        @ptkms_project.info = ptkms_project_params[:info]
        @ptkms_project.show = ptkms_project_params[:show]

        if @ptkms_project.save
          format.html { redirect_to ptkms_projects_path, notice: '更新しました。' }
        else
          format.html { render :edit }
        end
      rescue => error 
         redirect_to ptkms_projects_path, alert: '不正な入力が発生しました。' 
         return
      end      
    end
  end

  # DELETE /ptkms_projects/1
  def destroy
  
    # 管理者権限の確認
    if(!(ptkms_current_user && ptkms_current_user.admin?))
      redirect_to ptkms_projects_path
      return
    end
      
    # プロジェクトに紐づくタスク/ナレッジも削除する
    ActiveRecord::Base.transaction do
       @ptkms_project.destroy!

       # タスク
       tasks = PtkmsTask.where(project_id: @ptkms_project.id)       
       tasks.each { |a|
         commnets = PtkmsTaskCommnet.where(task_id: a.id)  
         commnets.each { |b|
           b.destroy! 
         }
         a.destroy! 
       } 
       
       # ナレッジ
       knowledges = PtkmsKnowledge.where(project_id: @ptkms_project.id)       
       knowledges.each { |a|
         commnets = PtkmsKnowledgeCommnet.where(knowledge_id: a.id)  
         commnets.each { |b|
           b.destroy! 
         }
         a.destroy! 
       } 
              
      redirect_to ptkms_projects_path, alert: "「#{@ptkms_project.name}」を削除しました。"
    end
  end

# -----------------------------
#  private
# -----------------------------    
  private
    def set_ptkms_project
      @ptkms_project = PtkmsProject.find(params[:id])
      
      # 文字列の整形
      ptkms_project_formatting()    
    end

    def ptkms_project_params
      params.require(:ptkms_project).permit(:name, :client_name, :p_start, :p_end, :info, :show)
    end
    
    # 文字列の整形
    def ptkms_project_formatting()    
      # 空白除去 ※全角空白を半角空白に変換含む
      @ptkms_project.name = common_trim(@ptkms_project.name)  
      @ptkms_project.client_name = common_trim(@ptkms_project.client_name)      
    end        

# -----------------------------
#  ヘルパーメソッド
# -----------------------------
  # idからタスク/ナレッジを取得する
  def ptkms_get_count_from_data(id)
    result = {};    
    @db_data.each { |obj| 
      if obj['id'] == id                 
        result['task'] = obj['task'] 
        result['knowledge'] = obj['knowledge']         
        return result
      end  
    }
    return result
  end      
end
