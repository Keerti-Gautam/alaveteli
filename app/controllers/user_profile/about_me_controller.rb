# -*- encoding : utf-8 -*-
class UserProfile::AboutMeController < ApplicationController
  before_filter :set_title
  before_filter :check_user_logged_in

  def edit ; end

  def update
    if @user.banned?
      flash[:error] = _('Banned users cannot edit their profile')
      redirect_to edit_profile_about_me_path
      return
    end

    # TODO: Use strong params to require :user key
    return redirect_to user_url(@user) unless params[:user]
    @user.about_me = params[:user][:about_me]

    unless @user.confirmed_not_spam?
      if UserSpamScorer.new.spam?(@user)
        flash[:error] = _("You can't update your profile text at this time.")
        redirect_to user_url(@user)
        return
      end
    end

    spam_profile_text =
      !@user.confirmed_not_spam? &&
      AlaveteliSpamTermChecker.new.spam?(@user.about_me)

    if spam_profile_text
      if send_exception_notifications?
        e = Exception.new("Spam profile text from user #{@user.id}")
        ExceptionNotifier.notify_exception(e, :env => request.env)
      end

      if AlaveteliConfiguration.enable_anti_spam
        flash[:error] = _("You can't update your profile text at this time.")
        redirect_to user_url(@user)
        return
      end
    end

    if @user.save
      if @user.profile_photo
        flash[:notice] = _("You have now changed the text about you on your profile.")
        redirect_to user_url(@user)
      else
        flash[:notice] = _("<p>Thanks for changing the text about you on your " \
                           "profile.</p><p><strong>Next...</strong> You can " \
                           "upload a profile photograph too.</p>")
        redirect_to set_profile_photo_url
      end
    else
      render :edit
    end
  end

  private

  def check_user_logged_in
    if authenticated_user.nil?
      flash[:error] = _("You need to be logged in to change the text about you on your profile.")
      redirect_to frontpage_url
      return
    end
  end

  def set_title
    @title = _('Change the text about you on your profile at {{site_name}}',
               :site_name => site_name)
  end
end
