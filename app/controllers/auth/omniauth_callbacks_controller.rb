# frozen_string_literal: true

module Auth
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def self.provides_callback_for(*providers)
      providers.each do |provider|
        class_eval %{
          def #{provider}
            if not current_user.blank?
              current_user.bind_service(request.env["omniauth.auth"])#Add an auth to existing
              redirect_to account_setting_path, notice: "成功绑定了 #{provider} 帐号。"
            else
              @user = User.find_or_create_for_#{provider}(request.env["omniauth.auth"])
              if @user == nil
                redirect_to new_user_session_path, notice: "#{provider.capitalize} 信息和现有账号存在冲突，如果想绑定 #{provider.capitalize}，请用原账号登录，再到设置页面绑定。"
                return
              end
              if @user.persisted?
                @user.skip_confirmation!
                if @user.email.include?("@example.com")
                  flash[:notice] = t('devise.sessions.add_email')
                else
                  flash[:notice] = t('devise.sessions.signed_in')
                end
                sign_in_and_redirect @user, event: :authentication
              else
                redirect_to new_user_registration_url
              end
            end
          end
        }
      end
    end

    provides_callback_for :github, :twitter, :douban, :google

    # This is solution for existing accout want bind Google login but current_user is always nil
    # https://github.com/intridea/omniauth/issues/185
    def handle_unverified_request
      true
    end
  end
end
