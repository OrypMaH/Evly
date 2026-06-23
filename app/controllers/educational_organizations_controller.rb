class EducationalOrganizationsController < ApplicationController
  before_action :authenticate_user!
  before_action :store_referer, only: [:create ]
  def new

  end

  def create
    @educational_organization = EducationalOrganization.new(educational_organization_params)
    if @educational_organization.save
      redirect_to stored_referer
    else
      render :new
    end
  end

  private

  def educational_organization_params
      params.require(:educational_organization).permit(:name, :federal_district, :federal_subject)
  end
end