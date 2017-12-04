module AutoCleanClassVariables
  def reset_class_variables(klass)
    klass::CLASS_VARIABLES_TO_CLEAN.each do |var|
      if klass.class_variable_defined? var
        klass.remove_class_variable var
      end
    end
  end
end
