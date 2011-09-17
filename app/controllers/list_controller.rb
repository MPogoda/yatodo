class ListController < ApplicationController
  def tags
    @user = User.find_by_jid params[:jid]
    render_404 if @user.nil?
  end

  def notes
    @user = User.find_by_jid params[:jid]
    if @user.nil?
      render_404
    else
      @tag = @user.tags.find_by_name params[:tag]
      render_404 if @tag.nil?
    end
  end
end
