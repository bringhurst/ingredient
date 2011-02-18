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
      @env             = nil
    end

    def add(opts = nil)
      Ingredient.ui.warn "An add was called"
    end

    def remove(opts = nil)
      Ingredient.ui.warn "A remove was called"
    end

    def taste(opts = nil)
      Ingredient.ui.warn "A taste was called"
    end

    def nom(opts = nil)
      Ingredient.ui.warn "A nom was called"
    end

    def mix(opts = nil)
      Ingredient.ui.warn "A mix was called"
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
