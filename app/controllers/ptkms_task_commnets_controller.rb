class PtkmsTaskCommnetsController < ApplicationController

  def edit
  
    # 管理者権限の確認
    if(!(ptkms_current_user && ptkms_current_user.admin?))
      redirect_to ptkms_projects_path
      return
    end
      
    @ptkms_task_commnet = PtkmsTaskCommnet.where(id:params[:id])[0]    
    @ptkms_task = PtkmsTask.where(id: @ptkms_task_commnet.task_id)[0]
    @ptkms_project = PtkmsProject.where(id: @ptkms_task.project_id)[0]
  end
  
  def update
  
    # 管理者権限の確認
    if(!(ptkms_current_user && ptkms_current_user.admin?))
      redirect_to ptkms_projects_path
      return
    end
      
    @ptkms_task_commnet = PtkmsTaskCommnet.where(id:params[:id])[0]
    @ptkms_task = PtkmsTask.where(id: @ptkms_task_commnet.task_id)[0]
    @ptkms_project = PtkmsProject.where(id: @ptkms_task.project_id)[0]       


    @ptkms_task_commnet.name = common_trim(ptkms_task_commnet_params[:name])  
    @ptkms_task_commnet.body = ptkms_task_commnet_params[:body]  
    @ptkms_task_commnet.attachments = ptkms_task_commnet_params[:attachments]  
    @ptkms_task_commnet.updated_at = Time.zone.now
    
    if @ptkms_task_commnet.valid?
      ActiveRecord::Base.transaction do         
        @ptkms_task_commnet.save!
        
        # 最終更新日
        ptkms_task = PtkmsTask.where(id: @ptkms_task_commnet.task_id)[0]
        ptkms_task.updated_at = Time.zone.now
        ptkms_task.save!
        
        redirect_to ptkms_task_path(id: @ptkms_task_commnet.task_id), notice: '更新しました。'
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
      
    @ptkms_task_commnet = PtkmsTaskCommnet.where(id:params[:id])[0]    
    @ptkms_task_commnet.destroy
    redirect_to ptkms_task_path(id: @ptkms_task_commnet.task_id), alert: '削除しました。'
  end    
  
# -----------------------------
#  private
# -----------------------------    
  private
    def ptkms_task_commnet_params
      params.require(:ptkms_task_commnet).permit(:task_id, :name, :body, attachments: [])
    end     
end
