class FastWorker
  include Sidekiq::Worker
  sidekiq_options :retry => 20, :dead => false
  def perform(new_num)
  end
end
