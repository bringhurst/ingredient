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
      Ingredient.ui.warn "An add was called for: " + @name
    end

    def remove(&block)
      Ingredient.ui.warn "A remove was called for: " + @name
    end

    def taste(&block)
      Ingredient.ui.warn "A taste was called for: " + @name
    end

    def nom(&block)
      Ingredient.ui.warn "A nom was called for: " + @name
    end

    def mix(&block)
      Ingredient.ui.warn "A mix was called for: " + @name
    end

    def env(name)
      @env, old = name, @env
      yield
    ensure
      @env = old
    end

  private
  end

end
