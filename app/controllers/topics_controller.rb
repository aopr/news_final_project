require 'twitterutilities'
class TopicsController < ApplicationController
before_action :set_topic, only: [:show, :edit, :update, :destroy]
  def new
    @topic = Topic.new
  end

  def create
    @topic = Topic.new(topic_params)

    if @topic.save
      redirect_to '/dashboard'
    else
      render 'new'
    end

  end

  def index
    @topics = Topic.order("position")
  end

  def show
    @topic = Topic.friendly.find(params[:id])
  end

  def trending
    @topic = Topic.friendly.find('trending')
    @stories = Story.all
    @tophashtags = Soc_med.top_tweet_hashtags
    @topkeywords = Soc_med.top_tweet_keywords
    @topheadlines = RssFeed.top_rss_keywords
    Soc_med.build_top_tweet_stories
    return if checked_today
    @@last_checked = Time.now.day
    TwitterUtilities.save_story
    FeedlyFetcher.fetch
    # Soc_med.build_favorite_tweet_stories
    # Soc_med.build_new_hotness
    Soc_med.top_retweets
    Soc_med.top_tweet_hashtags  #returns top ten hashtags to console
    # Soc_med.get_top_tw_links  #gets top twitter links w count
    # Soc_med.build_new_topic
  end

  def checked_today
    self.class.last_checked == Time.now.day
  end

  def self.last_checked
    @@last_checked ||= ""
  end

  def edit
  end

  def destroy
    @topic.destroy
    respond_to do |format|
      format.html { redirect_to '/dashboard', notice: 'Topic was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  def sort
    params[:topic].each_with_index do |id, index|
      Topic.where(id: id).update(:position => index+1)
    end
  end

private
  def topic_params
    params.require(:topic).permit(:name, :slug)
  end

  def set_topic
    @topic = Topic.friendly.find(params[:id])
  end
end
