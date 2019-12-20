class PtkmsKnowledgeCommnetsController < ApplicationController

  def edit
  
    # 管理者権限の確認
    if(!(ptkms_current_user && ptkms_current_user.admin?))
      redirect_to ptkms_projects_path
      return
    end
      
    @ptkms_knowledge_commnet = PtkmsKnowledgeCommnet.where(id:params[:id])[0]    
    @ptkms_knowledge = PtkmsKnowledge.where(id: @ptkms_knowledge_commnet.knowledge_id)[0]
    @ptkms_project = PtkmsProject.where(id: @ptkms_knowledge.project_id)[0]
  end
  
  def update

    # 管理者権限の確認
    if(!(ptkms_current_user && ptkms_current_user.admin?))
      redirect_to ptkms_projects_path
      return
    end
      
    @ptkms_knowledge_commnet = PtkmsKnowledgeCommnet.where(id:params[:id])[0]    
    @ptkms_knowledge = PtkmsKnowledge.where(id: @ptkms_knowledge_commnet.knowledge_id)[0]
    @ptkms_project = PtkmsProject.where(id: @ptkms_knowledge.project_id)[0]     

    @ptkms_knowledge_commnet.name = common_trim(ptkms_knowledge_commnet_params[:name])  
    @ptkms_knowledge_commnet.body = ptkms_knowledge_commnet_params[:body]  
    @ptkms_knowledge_commnet.attachments = ptkms_knowledge_commnet_params[:attachments]  
    @ptkms_knowledge_commnet.updated_at = Time.zone.now
    
    if @ptkms_knowledge_commnet.valid?
      ActiveRecord::Base.transaction do         
        @ptkms_knowledge_commnet.save!   
        
        # 最終更新日
        ptkms_knowledge = PtkmsKnowledge.where(id: @ptkms_knowledge_commnet.knowledge_id)[0]
        ptkms_knowledge.updated_at = Time.zone.now
        ptkms_knowledge.save!
          
        redirect_to ptkms_knowledge_path(id: @ptkms_knowledge_commnet.knowledge_id), notice: '更新しました。'
      end
    else
      render :edit
    end   
  end  
  
  def destroy
  
    # 管理者権限の確認
    if(!(ptkms_current_user && ptkms_current_user.admin?))
      redirect_to ptkms_projects_path
      return
    end
      
    @ptkms_knowledge_commnet = PtkmsKnowledgeCommnet.where(id:params[:id])[0]    
    @ptkms_knowledge_commnet.destroy
    redirect_to ptkms_knowledge_path(id: @ptkms_knowledge_commnet.knowledge_id), alert: '削除しました。'
  end    
  
# -----------------------------
#  private
# -----------------------------    
  private
    def ptkms_knowledge_commnet_params
      params.require(:ptkms_knowledge_commnet).permit(:knowledge_id, :name, :body, attachments: [])
    end     
end

