module DepartmentResources
  class DirectionsController < BaseController
    before_action :set_direction, only: [:show, :edit, :update, :destroy ]
    def index      
      authorize_action(:show, @department)
      @directions = @department.direction_tree
    end
    def show
      authorize_action(:show, @direction)
    end        
    def new
      @direction = Direction.new(
        department: @department,
        name: ""
      )
      authorize_action(:create, @direction)
    end
    def create
      @direction = Direction.new(direction_params)
      if can?(:create, @direction)
        if @direction.save
          redirect_to department_directions_path(@direction.department), notice: 'Направление успешно создано'
        else
          render :new
        end
      else
        redirect_to stored_referer, alert: "Недостаточно прав для редактирования этого подразделения"
      end
    end

    def edit
      authorize_action(:edit,@direction)
    end

    def update
      if can?(:edit, @direction)
        if @direction.update(direction_params)
          redirect_to department_directions_path(@direction.department), notice: 'Подразделение успешно обновлено'
        else
          render :edit
        end
      else
        redirect_to stored_referer, alert: "Недостаточно прав для редактирования этого подразделения"
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
end