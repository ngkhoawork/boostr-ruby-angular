class Object
  def send_chain(arr)
    arr.inject(self, :try) {|o, a| o.send(a) }
  end

  def is_date?
    Date.strptime(self.to_s, '%d/%m/%Y')
  rescue
    false
  end
end
