class ReportsController < ApplicationController
include ApplicationHelper
  def index
   @start_date = params[:start_date] || Date.today-5
   @end_date = params[:end_date] || Date.today
   if params[:start_date] && params[:end_date] 
     @customers = Customer.where("created_at >= ? and created_at <= ?", @start_date, @end_date) 
    respond_to do |format|
      format.html
      format.csv #{ send_data @customers.to_csv }
      format.xls #{ send_data @customers.to_csv(col_sep: "\t") }
      #format.xls do
      #render :xls => @customers
      #end
    end
  end
 end
end
