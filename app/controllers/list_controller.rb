class ListController < ApplicationController
  def tags
    jid = params[:jid]
    @user = User.find_by_jid jid
    render_404 if @user.nil?
  end

  def notes
    jid = params[:jid]
    @user = User.find_by_jid jid
    if @user.nil?
      render_404
    else
      @tag = @user.tags.find_by_name params[:tag]
      render_404 if @tag.nil?
    end
  end
end
