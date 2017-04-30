class HomeController < ApplicationController
  def index
    @excellent_topics = Topic.excellent.recent.fields_for_list.limit(30).to_a
    @suggest_topics = Topic.without_hide_nodes.suggest.fields_for_list.limit(4).to_a
    @latest_topics = Topic.recent.without_hide_nodes.with_replies_or_likes.fields_for_list.limit(30).to_a
    @job_node = Node.find(Node.job_id)
    @job_topics = @job_node.topics.last_actived.without_hide_nodes.fields_for_list.limit(4).to_a
    @question_node = Node.find(Node.questions_id)
    @question_topics = @question_node.topics.last_actived.without_hide_nodes.fields_for_list.limit(30).to_a
    @users = User.normal.without_team.hot.limit(500).select { |user| user.topics.excellent.size >= 8 and user.level != "admin" }
  end

  def uploads
    return render_404 if Rails.env.production?

    # This is a temporary solution for help generate image thumb
    # that when you use :file upload_provider and you have no Nginx image_filter configurations.
    # DO NOT use this in production environment.
    format, version = params[:format].split('!')
    filename = [params[:path], format].join('.')
    pragma = request.headers['Pragma'] == 'no-cache'
    thumb = Homeland::ImageThumb.new(filename, version, pragma: pragma)
    if thumb.exists?
      send_file thumb.outpath, type: 'image/jpeg', disposition: 'inline'
    else
      render plain: 'File not found', status: 404
    end
  end

  def api
    redirect_to '/api-doc/'
  end

  def error_404
    render_404
  end

  def markdown
  end
end
