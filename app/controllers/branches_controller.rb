class BranchesController < ApplicationController
  def index
   @branches = Branch.all
  end

  def new
   @branch = Branch.new
  end

  def create
   @branch = Branch.create(params[:branch])
   if @branch.save
    redirect_to new_customer_path, :notice => "branch saved Successfully."
   end
  end


end