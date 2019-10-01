class EnterpriseController < ApplicationController
  def home
  end

  def index
    @enterprise = Enterprise.find(1)
  end

  def create
    @test = params[:title]
    @recruiterId = GlobalData.find(1).user_id
    @offer = Offer.create title:params[:title], recruiter_id: @recruiterId
    redirect_to "/enterprise"
  end

  def show
    @offer = Offer.find(params[:id])
  end

  def update
    @offer = Offer.find(params[:id])
    @offer.update title: params[:title]
    @offer.update description: params[:description]
    @offer.update keywords: params[:keywords]
    redirect_to "/enterprise/#{params[:id]}"
  end

end