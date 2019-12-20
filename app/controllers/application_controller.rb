class ApplicationController < ActionController::Base

# このプロジェクト固有のメソッド名には先頭に"ptkms_"が付与されています。

  helper_method :ptkms_current_user
  before_action :ptkms_login?
  
# -----------------------------
#  ログイン系
# -----------------------------
  def ptkms_current_user
    @ptkms_current_user ||= PtkmsUser.find_by(id: session[:ptkms_user_id]) if session[:ptkms_user_id]
  end
     
  def ptkms_login?
    if ptkms_current_user.blank?
      redirect_to login_path
    end  
  end
        
# -----------------------------
#  メソッド
# -----------------------------
  # 空白除去 ※全角空白を半角空白に変換含む
  def common_trim(str)
    str.gsub("　"," ").strip  
  end
  
# -----------------------------
#  ヘルパーメソッド
# -----------------------------
  # 空白(スペース)とタブを&nbsp;に変換
  # ※<a href=""></a>の「a 」の空白は変換しないようにする 
  def common_convert_nbsp(str)
    result = ""
    preflg = false
    
    str.chars { |s|
      
      # 空白
      if (s == " ") && (!preflg)
        result += "&nbsp;"
      # タブ  
      elsif (s == "	") 
        result += "&nbsp;&nbsp;"
      else
        result += s
      end   
     
      if s == "a"
        preflg = true
      else
        preflg = false
      end 
   }
   result  
  end   

# -----------------------------
#  ヘルパーメソッド
# -----------------------------
  # idから登録者/最終発言者を取得する
  def ptkms_get_name_from_data(id)
    result = {};    
    @db_data.each { |obj| 
      if obj['id'] == id        

        # 件数
        if obj['cnt'].present?
          result['cnt'] = obj['cnt'].to_s(:delimited)   
        else
          result['cnt'] =  "破損"
        end  
              
        result['name1'] = obj['name1'] 
        result['name2'] = obj['name2']         
        return result
      end  
    }
    return result
  end  
end
