class Customers::PointsController < ApplicationController
  before_action :authenticate_customer!

  def new
    @point = Point.new
  end

  def create
    @point = Point.new(point_params)
    @point.customer_id = current_customer.id

    if @point.save
      redirect_to user_path(current_customer), notice: "You have created point successfully."
    end
    @tag = params[:point][:tag_ids]
    if @tag.present?  #投稿されたtag.id情報が送られた場合
        @point.save_genres(@tag)  #point.rbのメソッドを呼び出す
    else
      render :new
    end
  end

  def index
    #tagによる絞り込み機能　と　sortによる並び替え
    @points = params[:tag_id].present? ? Tag.find(params[:tag_id]).points.order(params[:sort]) : Point.all.order(params[:sort])
    #byebug
    #ページネーションの記述
    @points = @points.page(params[:page]).per(10)
  end

  def show
    @point = Point.find(params[:id])
    @point_comment = PointComment.new
  end

  def edit
    @point = Point.find(params[:id])
    if @point.customer_id != current_customer.id
      redirect_to points_path
    end
  end

  def update
    @point = Point.find(params[:id])
    if @point.update(point_params)
      @point.tags.destroy_all
      @tag = params[:point][:tag_ids]
      if @tag.present?  #投稿されたtag.id情報が送られた場合
        @point.save_genres(@tag)  #point.rbのメソッドを呼び出す
      end
      redirect_to point_path(@point), notice: "You have updated point successfully."
    else
      render "edit"
    end
  end

  def destroy
    @point = Point.find(params[:id])
    @point.destroy
    redirect_to points_path
  end

  def search
    @points = Point.search(params[:keyword]).page(params[:page]).per(10)
    @keyword = params[:keyword]
    render "index"
  end

  private

  def point_params
    params.require(:point).permit(:name, :body, :rate, :lat, :lng, tag_ids: [])
  end
end
