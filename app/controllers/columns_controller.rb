class ColumnsController < ApplicationController

  before_action :authenticate_user!, only: %i[new edit create update destroy]
  before_action :set_column, only: [:show, :edit, :update]
  before_action :set_columns_have, only: [:show, :edit, :update]

  def index
    @columns = Column.all
  end

  def new
    @column = Column.new(user_id: current_user.id)
  end

  def show
  end

  def create
    @column = Column.new(column_params)
    @column.user_id = current_user.id
    if @column.save
      redirect_to(column_path(@column), notice: 'Column was created successfully.')
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @column.update(column_params)
      redirect_to(column_path(@column), notice: 'Column was successfully updated.')
    else
      render action: "edit"
    end
  end

  def destroy
    @column = Column.find(params[:id])
    @column.destroy

    redirect_to(columns_url)
  end

  protected

  def column_params
    params.require(:column).permit(:name, :description, :cover, :slug)
  end

  def set_column
    @column = Column.find_by_slug(params[:id])
  end

  def set_columns_have
    @column_already_have = current_user.columns
  end
end