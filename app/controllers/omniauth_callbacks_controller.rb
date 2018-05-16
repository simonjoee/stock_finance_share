class OmniauthCallbacksController < ApplicationController


  def wechat
    auth = request.env['omniauth.auth']       # 引入回调数据 HASH
    data = auth.info                          # https://github.com/skinnyworm/omniauth-wechat-oauth2
    identify = Identify.find_by(provider: auth.provider, uid: auth.uid)

    if identify                               # 判断是否是已经注册的用户
      @user = identify.user                   # true 则通过 identify直接调去
    else                                      # false 则注册新用户
      i = Devise.friendly_token[0,20]
      user = User.create!(
        if User.find_by_username(data.nickname).nil?
          username: data.nickname,
        else
          username: data.nickname + "-" + rand(999).to_s,
        end
        openid: auth.extra.raw_info.openid,
        email:  "#{auth.extra.raw_info.openid}@holdle.com",       # 因为devise 的缘故,邮箱暂做成随机
        avatar: data.headimgurl,
        password: i,                                              # 密码随机
        password_confirmation: i
      )
      identify = Identify.create(
        provider: auth.provider,
        uid: auth.uid,
        user_id: user.id
      )
      @user = user
    end

    sign_in_and_redirect @user, :event => :authentication
  end

  # def wechat
  #   @user = User.from_wechat(request.env["omniauth.auth"], current_user)
  #   if @user.persisted?
  #       sign_in_and_redirect @user, :event => :authentication
  #   else
  #       session["devise.user_data"] = request.env["omniauth.auth"]
  #       redirect_to new_user_registration_path
  #   end
  # end

end
