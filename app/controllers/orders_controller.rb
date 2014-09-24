class OrdersController < ApplicationController
  before_action :set_order, only: [:show, :edit, :update, :destroy]

  # GET /orders
  # GET /orders.json
  def index
     if params[:sortbyAsc]
         @orders = Order.order(params[:sortbyAsc]+' ASC')
     elsif params[:sortbyDesc]
         @orders = Order.order(params[:sortbyDesc]+' DESC')
     elsif params[:findbyId]
         @orders = Order.where('user_id='+params[:findbyId])
     elsif params[:findbyStatus]
         @orders = Order.where('status='+params[:findbyStatus])
     else
         @orders = Order.all
     end

    # TODO separate this into a new action, or something...
    @num_opened = Order.where("status=0").size
    @num_closed = Order.where("status=1").size
    @users = User.all
  end

  # GET /orders/1
  # GET /orders/1.json
  def show
  end

  # GET /orders/new
  def new
    @order = Order.new
  end

  # GET /orders/1/edit
  def edit
  end

  # POST /orders
  # POST /orders.json
  def create
    puts order_params['product_id']
    @order = Order.new(order_params)
    @order.user_id = current_user.id
    @order.create_product_specific_params

    respond_to do |format|
      if @order.save
        format.html { redirect_to @order, notice: 'Order was successfully created.' }
        format.json { render :show, status: :created, location: @order }
      else
        format.html { render :new }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /orders/1
  # PATCH/PUT /orders/1.json
  def update
    respond_to do |format|
      if @order.update(order_params)
        format.html { redirect_to @order, notice: 'Order was successfully updated.' }
        format.json { render :show, status: :ok, location: @order }
      else
        format.html { render :edit }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /orders/1
  # DELETE /orders/1.json
  def destroy
    @order.destroy
    respond_to do |format|
      format.html { redirect_to orders_url, notice: 'Order was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      params.require(:order).permit(:price, :quantity, :units, :department, :comment, :url, :ordered_from, :product_id)
    end
end
