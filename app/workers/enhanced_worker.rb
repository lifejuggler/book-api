class EnhancedWorker
  include Sidekiq::Worker
  sidekiq_options :retry => 20, :dead => false
  def perform(file_num)
  end
end
