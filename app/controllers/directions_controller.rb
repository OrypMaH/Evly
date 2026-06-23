class DirectionsController < ApplicationController
  before_action :authenticate_user!
  before_action :store_referer, only: [:destroy ]
  before_action :set_direction, only: [:destroy ]
  
  def destroy
    if abac_engine.can?(:delete, @direction)
      @direction.destroy
      redirect_to stored_referer, notice: "Направление удалено"
    else
      redirect_to stored_referer, alert: "Недостаточно прав для удаления этого направления"
    end
  end
  
  private

  def set_direction
    @direction = Direction.find(params[:id])
  end
  
  def direction_params
    params.require(:direction).permit(:department_id, :name, :description)
  end
end