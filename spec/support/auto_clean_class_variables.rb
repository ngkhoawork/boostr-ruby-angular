module AutoCleanClassVariables
  def reset_class_variables(klass, arr)
    arr.each do |var|
      if klass.class_variable_defined? var
        klass.remove_class_variable var
      end
    end
  end
end
