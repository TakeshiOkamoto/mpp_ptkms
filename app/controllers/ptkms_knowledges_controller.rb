class PtkmsKnowledgesController < ApplicationController
  before_action :set_ptkms_knowledge, only: [:show, :edit, :update, :destroy]

  helper_method :common_convert_nbsp, :ptkms_get_name_from_data
  
  # GET /ptkms_knowledges
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
        @q = PtkmsKnowledge.where(project_id: @ptkms_project[0].id, show: true).order(updated_at: "DESC")
      else
        @q = PtkmsKnowledge.where(project_id: @ptkms_project[0].id).order(updated_at: "DESC")
      end  
      
      # 空白除去 ※全角空白を半角空白に変換含む
      if params[:q].present?
        params[:q][:title_cont]= common_trim(params[:q][:title_cont])
      end  
      
      @q = @q.ransack(params[:q])  
      @ptkms_knowledges = @q.result(distinct: true).page(params[:page]).per(25)  
      
      # 登録者、最終発言者の配列を取得する
      @db_data = PtkmsKnowledge.find_by_sql([' SELECT ' +
                                       '  ptkms_knowledges.id,' +
                                       '  (SELECT ptkms_knowledge_commnets.name FROM ptkms_knowledge_commnets WHERE ptkms_knowledge_commnets.knowledge_id = ptkms_knowledges.id  ORDER BY ptkms_knowledge_commnets.id ASC LIMIT 1) as name1,' +
                                       '  (SELECT ptkms_knowledge_commnets.name FROM ptkms_knowledge_commnets WHERE ptkms_knowledge_commnets.knowledge_id = ptkms_knowledges.id  ORDER BY ptkms_knowledge_commnets.id DESC LIMIT 1) as name2,' +
                                       '  (SELECT count(id) FROM ptkms_knowledge_commnets WHERE ptkms_knowledge_commnets.knowledge_id = ptkms_knowledges.id) as cnt ' +
                                       ' FROM   ptkms_knowledges' +
                                       ' WHERE ' +
                                       '  ptkms_knowledges.project_id = ?' +
                                       ' ORDER BY' +                                    
                                       '  ptkms_knowledges.updated_at DESC',
                                       @ptkms_project[0].id.to_s]) 
                                            
    else
      redirect_to ptkms_knowledges_path
    end         
  end

  # GET /ptkms_knowledges/1
  def show
    @ptkms_project =  PtkmsProject.where(id: @ptkms_knowledge.project_id)
    @ptkms_knowledge_commnets = PtkmsKnowledgeCommnet.where(knowledge_id: @ptkms_knowledge.id)
   
    # 新規コメント用
    @ptkms_knowledge_commnet = PtkmsKnowledgeCommnet.new
    @ptkms_knowledge_commnet.knowledge_id = @ptkms_knowledge.id
    @ptkms_knowledge_commnet.name = session[:ptkms_knowledge_commnet_name]  
    @ptkms_knowledge_commnet.body = session[:ptkms_knowledge_commnet_body]    
  end

  # GET /ptkms_knowledges/new
  def new
    @ptkms_project =  PtkmsProject.where(id: params[:project_id])
    
    # 不正処理
    if @ptkms_project.present?
      @ptkms_knowledge = PtkmsKnowledge.new
      @ptkms_knowledge.project_id = params[:project_id] 

      @ptkms_knowledge_commnet = PtkmsKnowledgeCommnet.new      
    else
      redirect_to ptkms_knowledges_path
    end   
  end

  # GET /ptkms_knowledges/1/edit
  def edit
  
    # 管理者権限の確認
    if(!(ptkms_current_user && ptkms_current_user.admin?))
      redirect_to ptkms_projects_path
      return
    end
      
    @ptkms_project =  PtkmsProject.where(id: @ptkms_knowledge.project_id)     
  end

  # POST /ptkms_knowledges
  def create
    # *** コメントの書き込み
    if params[:ptkms_knowledge_commnet].present?
    
      @ptkms_knowledge_commnet = PtkmsKnowledgeCommnet.new  
      @ptkms_knowledge_commnet.knowledge_id = params[:ptkms_knowledge_commnet][:knowledge_id]  
      @ptkms_knowledge_commnet.name = common_trim(params[:ptkms_knowledge_commnet][:name])
      @ptkms_knowledge_commnet.body = params[:ptkms_knowledge_commnet][:body]
      @ptkms_knowledge_commnet.attachments = params[:ptkms_knowledge_commnet][:attachments]
      
      if @ptkms_knowledge_commnet.valid?        
        ActiveRecord::Base.transaction do         
          @ptkms_knowledge_commnet.save!
          
          # 最終更新日
          ptkms_knowledge = PtkmsKnowledge.where(id: @ptkms_knowledge_commnet.knowledge_id)[0]
          ptkms_knowledge.updated_at = Time.zone.now
          ptkms_knowledge.save!
          
          ptkms_knowledge = PtkmsKnowledge.where(id: @ptkms_knowledge_commnet.knowledge_id)[0]
          redirect_to ptkms_knowledges_path(project_id: ptkms_knowledge.project_id), notice: '返信しました。'          
        end
      else                               
        session[:ptkms_knowledge_commnet_name] = @ptkms_knowledge_commnet.name
        session[:ptkms_knowledge_commnet_body] = @ptkms_knowledge_commnet.body
        session[:ptkms_knowledge_commnet_attachments] = @ptkms_knowledge_commnet.attachments        
        session[:ptkms_knowledge_commnet_errors] = @ptkms_knowledge_commnet.errors.full_messages  
        
        redirect_to ptkms_knowledge_path(id: @ptkms_knowledge_commnet.knowledge_id)
      end  
      
    # *** 通常の処理  
    else     
      @ptkms_knowledge = PtkmsKnowledge.new(ptkms_knowledge_params)    
      @ptkms_project =  PtkmsProject.where(id: @ptkms_knowledge.project_id)
      
      # 不正処理
      if @ptkms_project.blank?
        redirect_to ptkms_projects_path
        return
      end
      
      # 文字列の整形
      @ptkms_knowledge.title= common_trim(@ptkms_knowledge.title)
      @ptkms_knowledge_commnet = PtkmsKnowledgeCommnet.new      
      @ptkms_knowledge_commnet.name = common_trim(params[:ptkms_knowledge][:ptkms_knowledge_commnet][:name])
      @ptkms_knowledge_commnet.body = params[:ptkms_knowledge][:ptkms_knowledge_commnet][:body]    
      @ptkms_knowledge_commnet.attachments = params[:ptkms_knowledge][:ptkms_knowledge_commnet][:attachments]  
       
      # バリデーションの実行
      @ptkms_knowledge.valid?
      @ptkms_knowledge_commnet.valid?    
              
      # エラーならば、エラーを表示する
      if(!@ptkms_knowledge.valid? || !@ptkms_knowledge_commnet.valid?)
        render :new 
        return    
      end   
      
      # トランザクション    
      ActiveRecord::Base.transaction do
        @ptkms_knowledge.save!
        @ptkms_knowledge_commnet.knowledge_id = @ptkms_knowledge.id
        @ptkms_knowledge_commnet.save!
        redirect_to ptkms_knowledges_path(project_id: @ptkms_knowledge.project_id), notice: '登録しました。'
      end
    end  
  end

  # PATCH/PUT /ptkms_knowledges/1
  def update
    
    # 管理者権限の確認
    if(!(ptkms_current_user && ptkms_current_user.admin?))
      redirect_to ptkms_projects_path
      return
    end
      
    @ptkms_project =  PtkmsProject.where(id: ptkms_knowledge_params[:project_id])   
    
    # 不正処理
    if @ptkms_project.blank?
      redirect_to ptkms_projects_path
      return
    end  
    
    respond_to do |format|
      @ptkms_knowledge.title = common_trim(ptkms_knowledge_params[:title])
      @ptkms_knowledge.show = ptkms_knowledge_params[:show]   
      @ptkms_knowledge.updated_at = Time.zone.now   
      if @ptkms_knowledge.save
        format.html { redirect_to ptkms_knowledges_path(project_id: @ptkms_knowledge.project_id), notice: '更新しました。' }
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /ptkms_knowledges/1
  def destroy
  
    # 管理者権限の確認
    if(!(ptkms_current_user && ptkms_current_user.admin?))
      redirect_to ptkms_projects_path
      return
    end
      
    # トランザクション
    ActiveRecord::Base.transaction do
      @ptkms_knowledge.destroy!
      ptkms_knowledge_commnets = PtkmsKnowledgeCommnet.where(knowledge_id: @ptkms_knowledge.id)       
      ptkms_knowledge_commnets.each { |a|
        a.destroy! 
      }       
      redirect_to ptkms_knowledges_path(project_id: @ptkms_knowledge.project_id), alert: "「#{@ptkms_knowledge.title}」を削除しました。"
    end 
  end

# -----------------------------
#  private
# -----------------------------  
  private
    def set_ptkms_knowledge
      @ptkms_knowledge = PtkmsKnowledge.find(params[:id])
    end

    def ptkms_knowledge_params
      params.require(:ptkms_knowledge).permit(:project_id, :title, :show)
    end
    

end
