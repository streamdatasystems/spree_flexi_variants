module SpreeFlexiVariants
  class Engine < Rails::Engine
    require 'spree/core'
    isolate_namespace Spree
    engine_name 'spree_flexi_variants'

    config.autoload_paths += %W(#{config.root}/lib)

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), "../../app/**/*_decorator*.rb")) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end

      # Spree::Core::Environment::Calculators.class_eval do
      #   attr_accessor :product_customization_types
      # end
    end

    config.to_prepare(&method(:activate).to_proc)

    initializer "spree.flexi_variants.preferences", after: "spree.environment" do |app|
      SpreeFlexiVariants::Config = Spree::FlexiVariantsConfiguration.new
    end

    initializer "spree.flexi_variants.assets.precompile" do |app|
        app.config.assets.precompile += ['spree/frontend/spree_flexi_variants_exclusions.js','spree/backend/orders/flexi_configuration.js'] # ,'spree/frontend/spree-flexi-variants.*' # removed for now until we need the styles
    end

    initializer "spree.flexi_variants.register.calculators" do |app|
      ExtendedSpreeCalculators = Struct.new(*app.config.spree.calculators.members, :product_customization_types) unless app.config.spree.calculators.respond_to?(:product_customization_types)
      extended_calculators = ExtendedSpreeCalculators.new(*app.config.spree.calculators.to_h.values)
      extended_calculators.product_customization_types ||= []
      extended_calculators.product_customization_types += [
                                                                    Spree::Calculator::Engraving,
                                                                    Spree::Calculator::AmountTimesConstant,
                                                                    # Spree::Calculator::ProductArea,
                                                                    # Spree::Calculator::CustomizationImage,
                                                                    Spree::Calculator::NoCharge
                                                                   ]
      app.config.spree.calculators = extended_calculators
    end
  end
end
