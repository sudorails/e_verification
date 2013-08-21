class CustomersController < ApplicationController
   include ApplicationHelper
   before_filter :authenticate_user!
   load_and_authorize_resource

  def index
    @business = Business.all
    @co_applicants = CoApplicant.all
    @co_app_business = CoApplicantBusiness.all
    @customers = Customer.all
    @all_custome = (@business + @co_applicants + @co_app_business + @customers).sort_by {|a| a.created_at}.reverse
    #@all_customer = @all_customer.page(params[:page]).per(5)
    respond_to do |format|
      format.html do # index.html.erb
     		unless @all_custome.kind_of?(Array)
      			@all_customer = @all_custome.page(params[:page]).per(10)
		     else
			      @all_customer = Kaminari.paginate_array(@all_custome).page(params[:page]).per(10)
		     end
      format.json { render json: @all_customer }
    end
   end
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
    @final_no = @customer.fh_code
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
