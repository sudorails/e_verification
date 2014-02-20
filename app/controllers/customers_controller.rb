class CustomersController < ApplicationController
   include ApplicationHelper
   before_filter :authenticate_user!
   layout 'print_layout', :only => :print_customer
   load_and_authorize_resource

  def index
    @business = Business.without_status('ready_for_verification')
    @co_applicants = CoApplicant.without_status('ready_for_verification')
    @co_app_business = CoApplicantBusiness.without_status('ready_for_verification')
    @customers = Customer.without_status('ready_for_verification')
    filename = "customers.xls"
    @all_custome = (@business + @co_applicants + @co_app_business + @customers).sort_by {|a| a.created_at}.reverse
    #@all_customer = @all_customer.page(params[:page]).per(5)
    respond_to do |format|
      format.html do # index.html.erb
    		unless @all_custome.kind_of?(Array)
     			@all_customer = @all_custome.page(params[:page]).per(25)
		    else
			    @all_customer = Kaminari.paginate_array(@all_custome).page(params[:page]).per(25)
		    end
      format.json { render json: @all_customer }
      #format.xls { headers["Content-Disposition"] = "attachment; filename=\"#{filename}\"" }
      format.xls do
      render :xls => @all_custome,
             :columns => [ :application_status, :applicant_name, :address, :status ],
             :headers => %w[ Application_Status Applicant_Name Address Status ]
      end
    end
  end
end

 def old_pending_customers
 end

  def completed_customers_today
    @customers = Customer.where('DATE(created_at) = ? and status = ?', Date.today, 'verified')
    @business = Business.where('DATE(created_at) = ? and status = ?', Date.today, 'verified')
    @co_applicants = CoApplicant.where('DATE(created_at) = ? and status = ?', Date.today, 'verified')
    @co_applicant_business = CoApplicantBusiness.where('DATE(created_at) = ? and status = ?', Date.today, 'verified')
    @all_customers_today = @customers + @co_applicants + @co_applicant_business + @business
  end


  def in_progress_today
    @customers = Customer.where('DATE(created_at) = ? and status = ?', Date.today, 'awaiting_to_get_verified')
    @business = Business.where('DATE(created_at) = ? and status = ?', Date.today, 'awaiting_to_get_verified')
    @co_applicants = CoApplicant.where('DATE(created_at) = ? and status = ?', Date.today, 'awaiting_to_get_verified')
    @co_applicant_business = CoApplicantBusiness.where('DATE(created_at) = ? and status = ?', Date.today, 'awaiting_to_get_verified')
    @all_customers_today = @customers + @co_applicants + @co_applicant_business + @business
  end

  def daily_customers
    @customers = Customer.where('DATE(created_at) = ?', Date.today)
    @business = Business.where('DATE(created_at) = ?', Date.today)
    @co_applicants = CoApplicant.where('DATE(created_at) = ?', Date.today)
    @co_applicant_business = CoApplicantBusiness.where('DATE(created_at) = ?', Date.today)
    @all_customers_today = @customers + @co_applicants + @co_applicant_business + @business
  end

  def assigned_data_today
    @customers = CustomerVerification.where('DATE(created_at) = ?', Date.today)
    @business = BusinessVerification.where('DATE(created_at) = ?', Date.today)
    @co_applicants = CoApplicantVerification.where('DATE(created_at) = ?', Date.today)
    @co_applicant_business = ClientVerification.where('DATE(created_at) = ?', Date.today)
    @all_customers_today = @customers + @co_applicants + @co_applicant_business + @business

  end

  def daily_pending_customers
    @customers = Customer.where('DATE(created_at) = ? and status = ?', Date.today, 'submitted')
    @co_applicants = CoApplicant.where('DATE(created_at) = ? and status = ?', Date.today, 'submitted')
    @business = Business.where('DATE(created_at) = ? and status = ?', Date.today, 'submitted')
    @co_applicant_business = CoApplicantBusiness.where('DATE(created_at) = ? and status = ?', Date.today, 'submitted')
    @all_customers_today = @customers + @co_applicants + @co_applicant_business + @business
  end

  def search
    @business = Business.all
    @co_applicants = CoApplicant.all
    @co_app_business = CoApplicantBusiness.all
    @customers = Customer.all
    @customer_search = (@business + @co_applicants + @co_app_business + @customers).find.(:applicant_name, 'iLIKE', "%#{search}%")
  end

  def customer_search
   @start_date = params[:start] || Date.today-5
   @end_date = params[:end] || Date.today
   @customer_results = Customer.where("created_at >= ? and created_at <= ?", @start_date, @end_date)
  end

  def cust_residential
   @all_customer = residential
  end

  def cust_business
   @all_customer_business = business
  end

  def cust_pending
   @cust_pending = pending_filter
  end

  def cust_in_progress
   @cust_in_progress = in_progress_filter
  end

  def cust_completed
   @cust_completed = completed_filter
  end

  def cust_ready
   @cust_ready = inqueue_filter
  end

  # GET /customers/1
  # GET /customers/1.json
  def show
    @customer = Customer.find(params[:id])
    @google_address = @customer
    @customer_verification = @customer.customer_verification
    @business = Business.new
    @co_applicant = CoApplicant.new
    @application_ref_no = @customer.application_ref_no

   #authorize! :show, @customer

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @customer }
    end
  end

  # GET /customers/new
  # GET /customers/new.json

  def new
    @customer = Customer.new
    @work_servey = WorkServey.new
     if Customer.any?
       @new_no = Customer.last.application_ref_no.to_i
       @final_no = (@new_no+1)
     else
       @final_no = 1001
       @date = Time.now
       @current_date = @date.strftime("%B %d, %Y")
     end
  end


  # GET /customers/1/edit
  def edit
    @customer = Customer.find(params[:id])
    @final_no = @customer.application_ref_no
  end

  # POST /customers
  # POST /customers.json
  def create
    @customer = Customer.new(params[:customer])

    respond_to do |format|
      if @customer.save
        format.html { redirect_to @customer, notice: 'Customer was successfully created.' }
        #format.html { redirect_to new_work_servey_path(:customer_id => @customer.id), notice: 'Customer was successfully created.' }
        format.json { render json: @customer, status: :created, location: @customer }
      else
        format.html { render action: "new" }
        format.json { render json: @customer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /customers/1
  # PUT /customers/1.json

  def update
    @customer = Customer.find(params[:id])

    respond_to do |format|
     if @customer.update_attributes(params[:customer])
        #@customer.progress!
        format.html { redirect_to @customer, notice: 'Customer was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @customer.errors, status: :unprocessable_entity }
      end
    end
  end

  def print_customer
    @print_customer = Customer.find(params[:customer_id])
  end

 def customer_verification
   @customer = Customer.find(params[:customer_id])
   @tab = Tab.find(:all)
   @verification = CustomerVerification.create(params[:customer_verification])
    @verification.user_id = current_user.id
    @verification.customer_id = @customer.id

     if @verification.save
        @verification.customer.submit!
        @user = User.find_by_role('super_user')
        #VerificationMailer.verification_confirmation(@user).deliver
        redirect_to @customer, :notice =>"record has been send for verification"
    end
  end

  def customer_work_servey_verification
   @work_servey = WorkServey.find(params[:work_servey_id])
   @tab = Tab.find(:all)
   @verification = WorkServeyVerification.create(params[:work_servey_verification])

    @verification.user_id = current_user.id
    @verification.work_servey_id = @work_servey.id

     if @verification.save
        @verification.work_servey.submit!
        @user = User.find_by_role('super_user')
          #VerificationMailer.verification_confirmation(@user).deliver
        redirect_to @work_servey, :notice =>"record has been send for verification"
    end
  end

  def accept
    @customer = Customer.find(params[:customer_id])
    @customer.accept!

       if @customer.update_attributes(params[:customer])
         redirect_to root_url, :notice => 'Status was successfully updated.'
       else
         render action: "edit"
         render json: @customer.errors, status: :unprocessable_entity
       end
  end

  def re_indicated
    @customer = Customer.find(params[:customer_id])
    @customer.re_indicated!

       if @customer.update_attributes(params[:customer])
         redirect_to root_url, :notice => 'Status was successfully updated.'
       else
         render action: "edit"
         render json: @customer.errors, status: :unprocessable_entity
     end
  end


  # DELETE /customers/1
  # DELETE /customers/1.json
  def destroy
    @customer = Customer.find(params[:id])
    @customer.destroy

    respond_to do |format|
      format.html { redirect_to customers_url }
      format.json { head :no_content }
    end
  end
end
