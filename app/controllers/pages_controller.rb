class PagesController < ApplicationController
  def index
  end

  def styleguide
  end

  def snapshot
    Snapshot.generate_snapshots(current_user.company)

    render text: "Snapshot taken"
  end
end
