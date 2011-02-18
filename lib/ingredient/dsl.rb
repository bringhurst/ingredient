module Ingredient
  class Dsl
    def self.evaluate(ingredientfile)
      builder = new
      builder.instance_eval(Ingredient.read_file(ingredientfile.to_s), ingredientfile.to_s, 1)
      #builder.to_definition(lockfile, unlock)
    end

    def initialize
      @adds            = []
      @removes         = []
      @tastes          = []
      @noms            = []
      @name            = nil
      @desc            = nil
      @env             = nil
    end

    def name(name)
      @name = name
      Ingredient.ui.warn "This ingredient has been named: " + @name
    end

    def description(desc)
      @desc = desc
      Ingredient.ui.warn "This ingredient has been described as: " + @desc
    end

    def add(&block)
      Ingredient.ui.warn "An add was found in: " + @name
    end

    def remove(&block)
      Ingredient.ui.warn "A remove was found in: " + @name
    end

    def method_missing(meth, *args, &block)
      m = meth.to_s
      if m =~ /^taste_(.+)$/
        _handle_test(:taste, $1, &block)
      elsif m =~ /^nom_(.+)$/
        _handle_test(:nom, $1, &block)
      else
        super # You *must* call super if you don't handle the
              # method, otherwise you'll mess up Ruby's method
              # lookup.
        end
    end
  private
    def _handle_test(type, attrs, &block)
      Ingredient.ui.warn "A test was found in: " + @name
      Ingredient.ui.warn "Test type is: " + type.to_s
      Ingredient.ui.warn "Test name is: " + attrs

      #tc = Test::Unit::TestCase.new
      #tc.instance_eval block

      #Test::Unit::UI::Console::TestRunner.run(tc)
    end
  end
end
