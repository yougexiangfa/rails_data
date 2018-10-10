class Datum::Admin::DataListsController < Datum::Admin::BaseController
  before_action :set_data_list, only: [:show, :edit, :update, :rebuild, :destroy]

  def index
    query = params.permit(:type).reverse_merge type: 'DataExport'
    @data_lists = DataList.default_where(query)
  end

  def new
    @data_list = DataList.new(type: params[:type])
  end

  def create
    @data_list = DataList.new(data_list_params)
    @data_list.save

    redirect_to data_lists_url(type: @data_list.type)
  end

  def show
  end

  def edit
  end

  def update
    @data_list.update(data_list_params)
    redirect_to data_lists_url(type: @data_list.type)
  end

  def add_item
    @data_list = DataList.new
  end

  def remove_item

  end

  def rebuild
    @data_list.rebuild!

    redirect_back fallback_location: data_lists_url
  end

  def just_run

  end

  def destroy
    @data_list.destroy
    redirect_to data_lists_url, notice: 'Export file was successfully destroyed.'
  end

  private
  def set_data_list
    @data_list = DataList.find params[:id]
  end

  def data_list_params
    result = params[:data_list].permit(
      :type,
      :title,
      :comment,
      :data_table,
      :export_excel,
      :export_pdf,
      parameters: [:key, :value]
    )
    _params = result['parameters']&.values&.map { |i|  {i['key'] => i['value'] } }
    _params = Array(_params).to_combined_hash
    result['parameters'] = _params
    result
  end

end