class SellersController < ApplicationController

  get '/sellers/new' do # request for form to create a new seller
    authenticate_user!
    erb :"/sellers/create_seller"
  end

  post '/sellers' do # post request to add a new seller
    authenticate_user!
    if name_blank? # checks that at least name is provided
      flash[:message] = "**** Error: Please enter at least a name ****"
      redirect to '/sellers/new'
    else
      seller = Seller.new(seller_name: params[:seller][:seller_name], user_id: current_user.id)
      if valid_date?(params[:start_date]) # checks that date information is valid
        seller.start_date = create_date_object(params[:start_date]) # creates date object if date information is valid
      else
        flash[:message] = "**** Note: Start date was not entered or was invalid. Click edit to add a start date ****"
      end
      if seller.save
        redirect to "/sellers/#{seller.id}"
      else
        flash[:message] = "Error saving.  Please try again."
        redirect to 'sellers/new'
      end
    end
  end

  get '/sellers/:id' do
    authenticate_user!
    @seller = Seller.find(params[:id])
    erb :'sellers/show_seller'
  end

  get '/sellers/:id/edit' do
    authenticate_user!
    @seller = Seller.find(params[:id])
    if @seller.user != current_user # This prevents users from editing/deleting what they did not create
      flash[:message] = "**** You do not have permission to edit this seller ****"
      redirect to "/sellers/#{@seller.id}"
    else
      erb :'sellers/edit_seller'
    end
  end

  patch '/sellers/:id' do # patch request to edit seller
    authenticate_user!
    if seller = current_user.sellers.find_by(id: params[:id])
      if name_blank? # Checks that at least name is provided
        flash[:message] = "**** Error: Please enter at least a name **** "
        redirect to "sellers/#{seller.id}/edit"
      else
        seller.update(params[:seller])
        if valid_date?(params[:start_date]) # Checks that date information is valid
          seller.start_date = create_date_object(params[:start_date]) # Creates a date object if date information is valid
        else
          seller.start_date = nil
          flash[:message] = "**** Note: Start date was not entered or was invalid. Click edit to add a start date ****"
        end
        seller.save
        flash[:message] = "**** Seller #{seller.seller_name} updated ****"
        redirect to "/sellers/#{seller.id}"
      end
    else
      flash[:message] = "**** You do not have permission to edit this seller ****"
      redirect to "/sellers/#{@seller.id}"
    end
  end

  delete '/sellers/:id/delete' do # delete request to edit seller
    seller = Seller.find(params[:id])
    flash[:message] = "**** Seller #{seller.seller_name} deleted ****"
    seller.delete
    redirect to '/users/home'
  end

  helpers do

    def valid_date?(date_data)
      date_data[:year].to_i.between?(1979, 2100) && create_date_object(date_data)
    end

    def create_date_object(date_data)
      year = date_data[:year].to_i
      month = date_data[:month].to_i
      day = date_data[:day].to_i
      Date.new(year, month, day)
    end

    def name_blank?
      params[:seller][:seller_name] == ""
    end

  end # end of helpers

end
