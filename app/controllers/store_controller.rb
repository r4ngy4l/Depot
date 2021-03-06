class StoreController < ApplicationController
  before_filter :find_cart, :except => :empty_cart

  def authorize
  end

  def index
    @products = Product.find_products_for_sale
    @cart = find_cart

    if session[:counter].nil?
      session[:counter] = 1
    else
      session[:counter] = session[:counter] + 1
    end
  end

  def add_to_cart
    product = Product.find(params[:id])
    @cart = find_cart
    @current_item = @cart.add_product(product)    
    session[:counter] = 0
    respond_to do |format|
      format.js if request.xhr?
      format.html {redirect_to_index}
    end
  rescue ActiveRecord::RecordNotFound
    logger.error("Attempt to access invalid product #{params[:id]}")
    redirect_to_index "Invalid product"
  end

  def remove_from_cart
    product = Product.find(params[:id])
    @cart = find_cart
    logger.info (@cart.remove_product(product))
    respond_to do |format|
      format.js if request.xhr?
      format.html {redirect_to_index}
    end
  end

  def empty_cart
    session[:cart] = nil    
    respond_to do |format|
      format.js if request.xhr?
      format.html {redirect_to_index}
    end
  end

  def checkout
    @hide_buttons = true
    @cart = find_cart
    if @cart.items.empty?
      redirect_to_index("Your cart is empty" )
    else
      @order = Order.new
    end
  end

  def save_order
    @cart = find_cart
    @order = Order.new(params[:order])
    @order.add_line_items_from_cart(@cart)
    if @order.save
      session[:cart] = nil
      redirect_to_index(I18n.t('flash.thanks' ))
    else
      render :action => 'checkout'
    end
  end

  private

  def find_cart
    @cart = (session[:cart] ||= Cart.new)
  end

  def redirect_to_index(msg = nil)
    flash[:notice] = msg
    redirect_to :action => 'index'
  end
end
