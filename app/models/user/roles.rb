# frozen_string_literal: true

class User
  # 用户权限相关
  module Roles
    extend ActiveSupport::Concern

    # 是否是管理员
    def admin?
      Setting.has_admin?(email)
    end

    # 是否有 Wiki 维护权限
    def wiki_editor?
      self.admin? || verified == true
    end

    # 回帖大于 150 的才有酷站的发布权限
    def site_editor?
      self.admin? || replies_count >= 100
    end

    # 是否可以发专栏
    def column_editor?
      # 开关为关时，不能发专栏
      return false if Setting.column_enabled.blank?
      # 只有白名单用户可以发专栏
      return false if Setting.column_user_white_list.nil?
      if Setting.column_user_white_list.split(Setting.SEPARATOR_REGEXP).include? login
        return true
      end
    end

    # 是否能发帖
    def newbie?
      return false if verified?
      t = Setting.newbie_limit_time.to_i
      return false if t == 0
      created_at > t.seconds.ago or !avatar?
    end

    def roles?(role)
      case role
        when :admin then admin?
        when :wiki_editor then wiki_editor?
        when :site_editor then site_editor?
        when :column_editor then column_editor?
        when :member then self.normal?
      else false
      end
    end

    # 用户的账号类型
    def level
      if admin?
        "admin"
      elsif verified?
        "vip"
      elsif blocked?
        "blocked"
      elsif newbie?
        "newbie"
      else
        "normal"
      end
    end

    def level_name
      I18n.t("common.#{level}_user")
    end
  end
end
