module Spree
  module Admin
    class AdHocOptionTypesController < ResourceController
      before_action :load_product, only: [:selected]
      before_action :load_ad_hoc_option_type, only: [:add_option_value, :remove, :edit]
      before_action :load_available_option_values, only: [:edit]

      def selected
        @option_types = @product.ad_hoc_option_types
      end

      def add_option_value
        @ad_hoc_option_type.ad_hoc_option_values.create!(option_value_id: params[:option_value_id])
        redirect_to edit_admin_product_ad_hoc_option_type_url(@ad_hoc_option_type.product, @ad_hoc_option_type)
      end

      def remove
        @product = @ad_hoc_option_type.product
        @ad_hoc_option_type.destroy
        redirect_to selected_admin_product_ad_hoc_option_types_url(@product), notice: I18n.t("spree.notice_messages.option_type_removed")
      end

      protected

      def location_after_save
        selected_admin_product_ad_hoc_option_types_url(@ad_hoc_option_type.product)
      end

      private

      def load_product
        @product = Product.friendly.find(params[:product_id])
      end

      def load_ad_hoc_option_type
        @ad_hoc_option_type = AdHocOptionType.find(params[:id])
      end

      def load_available_option_values
        option_values = @ad_hoc_option_type.option_type.option_values
        selected_option_values = @ad_hoc_option_type.ad_hoc_option_values.map(&:option_value)
        @available_option_values = option_values - selected_option_values
      end
    end
  end
end
