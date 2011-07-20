module Helpers
  def file_size(n)
    if n < 1024
      return "%i B" % n
    elsif n < 1024 ** 2
      return "%i KB" % (n / 1024)
    elsif n < 1024 ** 3
      return "%i MB" % (n / 1024 ** 2)
    end
  end
end
